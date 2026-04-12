import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:web_scraping_with_flutter/core/models/news_item.dart';
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/core/utils/external_link_opener.dart';
import 'package:web_scraping_with_flutter/core/utils/text_utils.dart';
import 'package:web_scraping_with_flutter/core/widgets/news_list_tile.dart';
import 'package:web_scraping_with_flutter/core/widgets/error_state_widget.dart';
import 'package:web_scraping_with_flutter/core/widgets/shimmer_loader.dart';
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
      return const ShimmerLoader();
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
            return UpdatedChip(
              timestamp: _lastUpdated!,
              count: _items.length,
            );
          }
          final item = _items[_lastUpdated != null ? index - 1 : index];
          return NewsListTile(
            item: item,
            onTap: () => openExternalLink(context, item.url),
            accentColor: _accentColor,
            bengaliFont: true,
            showDescription: item.description.isNotEmpty,
            onShare: () => NewsListTile.shareArticle(item.url, title: item.title),
          );
        },
      ),
    );
  }
}
