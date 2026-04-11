import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:web_scraping_with_flutter/core/models/news_item.dart';
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/core/utils/external_link_opener.dart';
import 'package:web_scraping_with_flutter/core/utils/text_utils.dart';
import 'package:web_scraping_with_flutter/core/widgets/error_state_widget.dart';
import 'package:web_scraping_with_flutter/core/widgets/loading_shimmer_widget.dart';
import 'package:web_scraping_with_flutter/core/widgets/portal_app_bar.dart';

// ─── Samakal (HTML scraping) ──────────────────────────────────────────────────

class SamakalNewsScreen extends StatefulWidget {
  const SamakalNewsScreen({super.key});

  @override
  State<SamakalNewsScreen> createState() => _SamakalNewsScreenState();
}

class _SamakalNewsScreenState extends State<SamakalNewsScreen> {
  static const _baseUrl = 'https://samakal.com';
  static const _pageUrl = 'https://samakal.com/latest/news';
  static const _accentColor = Color(0xFF00897B);

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

  Future<void> _fetchNews() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final response = await _client.get(Uri.parse(_pageUrl), headers: {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml;q=0.9,*/*;q=0.8',
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

      final document = parse(utf8.decode(response.bodyBytes));
      final seenLinks = <String>{};
      final items = <NewsItem>[];

      for (final anchor in document.querySelectorAll('a[href*="/article/"]')) {
        final href = anchor.attributes['href'] ?? '';
        if (href.isEmpty) continue;
        final url = href.startsWith('http') ? href : '$_baseUrl$href';
        final title = TextUtils.cleanText(anchor.text);
        if (title.length < 8 || !seenLinks.add(url)) continue;
        final timeEl = anchor.parent
            ?.querySelector('time, .time, [class*="time"], [class*="date"]');
        items.add(NewsItem(
            title: title, url: url, time: TextUtils.cleanText(timeEl?.text ?? '')));
      }

      if (!mounted) return;
      setState(() {
        _items = items.take(30).toList();
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: PortalAppBar(
          title: Text('সমকাল',
              style: GoogleFonts.notoSansBengali(
                  fontWeight: FontWeight.w700, fontSize: 22, color: Colors.white)),
          subtitle: const Text('Samakal News'),
          gradientColors: const [Color(0xFF00897B), Color(0xFF00695C)],
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _isLoading ? null : _fetchNews)
          ],
        ),
        body: _buildBody(),
      );

  Widget _buildBody() {
    if (_isLoading && _items.isEmpty) {
      return const LoadingShimmerWidget();
    }
    if (_hasError && _items.isEmpty) {
      return ErrorStateWidget(accentColor: _accentColor, onRetry: _fetchNews);
    }
    return RefreshIndicator(
      onRefresh: _fetchNews,
      color: _accentColor,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: _items.length + (_lastUpdated != null ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          if (_lastUpdated != null && i == 0) {
            return _UpdatedChip(
                timestamp: TextUtils.formatTimestamp(_lastUpdated!),
                count: _items.length);
          }
          final item = _items[_lastUpdated != null ? i - 1 : i];
          return _NewsCard(
              item: item,
              accentColor: _accentColor,
              onTap: () => openExternalLink(ctx, item.url));
        },
      ),
    );
  }
}

// ─── Shared card widget ───────────────────────────────────────────────────────

class _NewsCard extends StatelessWidget {
  const _NewsCard(
      {required this.item, required this.accentColor, required this.onTap});

  final NewsItem item;
  final Color accentColor;
  final VoidCallback onTap;

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
          border: Border(left: BorderSide(color: accentColor, width: 4)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.category.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(item.category,
                    style: GoogleFonts.notoSansBengali(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accentColor)),
              ),
              const SizedBox(height: 8),
            ],
            Text(item.title,
                style: GoogleFonts.notoSansBengali(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.4)),
            const SizedBox(height: 10),
            Row(
              children: [
                if (item.time.isNotEmpty) ...[
                  Icon(Icons.access_time_rounded,
                      size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(item.time,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis),
                  ),
                ] else
                  const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('পড়ুন',
                        style: GoogleFonts.notoSansBengali(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accentColor)),
                    const SizedBox(width: 3),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 10, color: accentColor),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Updated chip ─────────────────────────────────────────────────────────────

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
