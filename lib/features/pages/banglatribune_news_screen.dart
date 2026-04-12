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
import 'package:web_scraping_with_flutter/core/widgets/news_list_tile.dart';
import 'package:web_scraping_with_flutter/core/widgets/portal_app_bar.dart';
import 'package:web_scraping_with_flutter/core/widgets/shimmer_loader.dart';

class BanglaTribuneScreen extends StatefulWidget {
  const BanglaTribuneScreen({super.key});

  @override
  State<BanglaTribuneScreen> createState() => _BanglaTribuneScreenState();
}

class _BanglaTribuneScreenState extends State<BanglaTribuneScreen> {
  static const _baseUrl = 'https://www.banglatribune.com';
  static const _accentColor = Color(0xFF2E7D32);
  static const _pageUrl = 'https://www.banglatribune.com/national';

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
    setState(() { _isLoading = true; _hasError = false; });
    try {
      final response = await _client.get(Uri.parse(_pageUrl), headers: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

      final document = parse(utf8.decode(response.bodyBytes));
      final seen = <String>{};
      final items = <NewsItem>[];

      for (final article in document.querySelectorAll('article, .news-list-item, .news-item')) {
        final anchor = article.querySelector('a[href]');
        if (anchor == null) continue;
        final href = anchor.attributes['href'] ?? '';
        final url = href.startsWith('http') ? href : '$_baseUrl$href';
        final titleEl = article.querySelector('h2, h3, .title');
        final title = TextUtils.cleanText(titleEl?.text ?? anchor.text);
        if (title.length < 10 || !seen.add(url)) continue;
        final timeEl = article.querySelector('time, .time, .date');
        items.add(NewsItem(title: title, url: url, time: TextUtils.cleanText(timeEl?.text ?? '')));
      }
      if (items.isEmpty) {
        for (final anchor in document.querySelectorAll('a[href*="/news/"]')) {
          final url = normalizeExternalUrl(anchor.attributes['href'] ?? '', baseUrl: _baseUrl);
          final title = TextUtils.cleanText(anchor.text);
          if (url != null && title.length >= 10 && seen.add(url)) {
            items.add(NewsItem(title: title, url: url));
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _items = items.take(30).toList();
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _hasError = true; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: PortalAppBar(
          title: Text('বাংলা ট্রিবিউন',
              style: GoogleFonts.notoSansBengali(
                  fontWeight: FontWeight.w700, fontSize: 22, color: Colors.white)),
          subtitle: const Text('banglatribune.com'),
          gradientColors: const [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _isLoading ? null : _fetchNews)
          ],
        ),
        body: _buildBody(),
      );

  Widget _buildBody() {
    if (_isLoading && _items.isEmpty) return const ShimmerLoader();
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
            return UpdatedChip(timestamp: _lastUpdated!, count: _items.length);
          }
          final item = _items[_lastUpdated != null ? i - 1 : i];
          return NewsListTile(
              item: item, accentColor: _accentColor, bengaliFont: true,
              onTap: () => openExternalLink(ctx, item.url),
              onShare: () => NewsListTile.shareArticle(item.url, title: item.title));
        },
      ),
    );
  }
}
