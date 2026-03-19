import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:web_scraping_with_flutter/core/models/news_item.dart';
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/core/utils/external_link_opener.dart';
import 'package:web_scraping_with_flutter/core/utils/text_utils.dart';
import 'package:web_scraping_with_flutter/core/widgets/error_state_widget.dart';
import 'package:web_scraping_with_flutter/core/widgets/loading_shimmer_widget.dart';
import 'package:web_scraping_with_flutter/core/widgets/portal_app_bar.dart';

/// Uses Prothom Alo's public REST API:
///   GET /api/v1/stories?fields=...&section=bangladesh&limit=20
class ProthomAloNewsScreen extends StatefulWidget {
  const ProthomAloNewsScreen({super.key});

  @override
  State<ProthomAloNewsScreen> createState() => _ProthomAloNewsScreenState();
}

class _ProthomAloNewsScreenState extends State<ProthomAloNewsScreen> {
  static const _baseUrl = 'https://www.prothomalo.com';
  static const _accentColor = Color(0xFFE51A1B);

  // Multiple category APIs for richer content
  static const _sectionApis = [
    '$_baseUrl/api/v1/stories?fields=id,headline,slug,sections,published-at,author-name&section=bangladesh&limit=15',
    '$_baseUrl/api/v1/stories?fields=id,headline,slug,sections,published-at,author-name&section=politics&limit=10',
    '$_baseUrl/api/v1/stories?fields=id,headline,slug,sections,published-at,author-name&section=world&limit=10',
  ];

  final http.Client _client = http.Client();

  List<NewsItem> _items = const [];
  bool _isLoading = true;
  bool _hasError = false;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  String _formatTimestamp(int millisSinceEpoch) {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(millisSinceEpoch);
      return DateFormat('MMM dd, yyyy – hh:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  Future<void> _fetchNews() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final seenIds = <String>{};
      final items = <NewsItem>[];

      for (final apiUrl in _sectionApis) {
        final response = await _client
            .get(Uri.parse(apiUrl), headers: {
              'Accept': 'application/json',
              'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
            })
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) continue;

        final json = jsonDecode(utf8.decode(response.bodyBytes));
        final stories = (json['stories'] as List?) ?? [];

        for (final story in stories) {
          final id = story['id']?.toString() ?? '';
          final headline = TextUtils.cleanText(story['headline']?.toString() ?? '');
          final slug = story['slug']?.toString() ?? '';
          final publishedAt = story['published-at'] as int? ?? 0;
          final author = TextUtils.cleanText(story['author-name']?.toString() ?? '');

          if (headline.isEmpty || slug.isEmpty || !seenIds.add(id)) continue;

          // Extract section display name
          final sections = story['sections'] as List? ?? [];
          final sectionName = sections.isNotEmpty
              ? TextUtils.cleanText(
                  sections.first['display-name']?.toString() ?? '')
              : '';

          final url = '$_baseUrl/$slug';
          final time = publishedAt > 0 ? _formatTimestamp(publishedAt) : '';

          items.add(NewsItem(
            title: headline,
            url: url,
            time: time,
            category: sectionName,
            description: author.isNotEmpty ? 'by $author' : '',
          ));
        }
      }

      // Sort by newest first (url contains no date, but published-at order is preserved per API)
      if (!mounted) return;
      setState(() {
        _items = items;
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PortalAppBar(
        title: Text(
          'প্রথম আলো',
          style: GoogleFonts.notoSansBengali(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        subtitle: const Text('Prothom Alo — Latest'),
        gradientColors: const [Color(0xFFE51A1B), Color(0xFFC62828)],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _isLoading ? null : _fetchNews,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _items.isEmpty) {
      return const LoadingShimmerWidget();
    }
    if (_hasError && _items.isEmpty) {
      return ErrorStateWidget(
        accentColor: _accentColor,
        onRetry: _fetchNews,
        message: 'প্রথম আলো লোড করতে ব্যর্থ',
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchNews,
      color: _accentColor,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        itemCount: _items.length + (_lastUpdated != null ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (_lastUpdated != null && index == 0) {
            return _UpdatedChip(
              timestamp: TextUtils.formatTimestamp(_lastUpdated!),
              count: _items.length,
            );
          }
          final item = _items[_lastUpdated != null ? index - 1 : index];
          return _ProthomAloCard(
            item: item,
            onTap: () => openExternalLink(context, item.url),
          );
        },
      ),
    );
  }
}

// ─── Card ───────────────────────────────────────────────────────────────────

class _ProthomAloCard extends StatelessWidget {
  const _ProthomAloCard({required this.item, required this.onTap});

  final NewsItem item;
  final VoidCallback onTap;

  static const _accent = Color(0xFFE51A1B);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(color: _accent, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.category.isNotEmpty) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.category,
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _accent,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              item.title,
              style: GoogleFonts.notoSansBengali(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.description,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (item.time.isNotEmpty) ...[
                  Icon(Icons.access_time_rounded,
                      size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.time,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'পড়ুন',
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _accent,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: _accent),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdatedChip extends StatelessWidget {
  const _UpdatedChip({required this.timestamp, required this.count});
  final String timestamp;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.update_rounded, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text('Updated $timestamp',
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
        const Spacer(),
        Text('$count articles',
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}
