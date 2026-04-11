import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:web_scraping_with_flutter/core/models/news_item.dart';
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/core/utils/external_link_opener.dart';
import 'package:web_scraping_with_flutter/core/widgets/portal_app_bar.dart';

class BanglaNews24Screen extends StatefulWidget {
  const BanglaNews24Screen({super.key});

  @override
  State<BanglaNews24Screen> createState() => _BanglaNews24ScreenState();
}

class _BanglaNews24ScreenState extends State<BanglaNews24Screen>
    with SingleTickerProviderStateMixin {
  static const _baseUrl = 'https://www.banglanews24.com';

  final http.Client _client = http.Client();

  late final TabController _tabController;
  List<NewsItem> _latestNews = const [];
  List<NewsItem> _popularNews = const [];
  bool _isLoading = true;
  bool _hasError = false;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchNews();
  }

  @override
  void dispose() {
    _client.close();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchNews() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _client
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to load news (${response.statusCode})');
      }

      final document = parse(utf8.decode(response.bodyBytes));
      final latestNews = <NewsItem>[];
      final popularNews = <NewsItem>[];
      final seenLatest = <String>{};
      final seenPopular = <String>{};

      final latestTab = document.querySelector('#home-tab-pane');
      if (latestTab != null) {
        _collectTabItems(
          container: latestTab,
          target: latestNews,
          seenLinks: seenLatest,
          isPopular: false,
        );
      }

      if (latestNews.isEmpty) {
        for (final section in document.querySelectorAll('.position-relative')) {
          final linkElement = section.querySelector('a.stretched-link, a');
          final titleElement = section.querySelector('h5, h3, p.fs-5, p');
          final url = normalizeExternalUrl(
            linkElement?.attributes['href'] ?? '',
            baseUrl: _baseUrl,
          );
          final title = _cleanText(titleElement?.text ?? '');

          if (url == null || title.isEmpty || !seenLatest.add(url)) {
            continue;
          }

          latestNews.add(
            NewsItem(
              title: title,
              url: url,
              time: '',
              isPopular: false,
            ),
          );
        }
      }

      final popularTab = document.querySelector('#profile-tab-pane');
      if (popularTab != null) {
        _collectTabItems(
          container: popularTab,
          target: popularNews,
          seenLinks: seenPopular,
          isPopular: true,
        );
      }

      if (latestNews.length < 5 && popularNews.isNotEmpty) {
        latestNews.addAll(
          popularNews.where((item) => seenLatest.add(item.url)).take(10),
        );
      }
      if (popularNews.isEmpty && latestNews.isNotEmpty) {
        popularNews.addAll(
          latestNews
              .where((item) => seenPopular.add(item.url))
              .take(10)
              .map((item) => item.copyWith(isPopular: true)),
        );
      }

      if (!mounted) return;
      setState(() {
        _latestNews = latestNews.take(20).toList(growable: false);
        _popularNews = popularNews.take(20).toList(growable: false);
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      _showErrorSnackbar(error.toString());
    }
  }

  void _collectTabItems({
    required dynamic container,
    required List<NewsItem> target,
    required Set<String> seenLinks,
    required bool isPopular,
  }) {
    for (final item in container.querySelectorAll('li.list-group-item')) {
      final linkElement = item.querySelector('a');
      final url = normalizeExternalUrl(
        linkElement?.attributes['href'] ?? '',
        baseUrl: _baseUrl,
      );
      final title = _cleanText(linkElement?.text ?? '');
      final time = _cleanText(
        item.querySelector('time, .time, small')?.text ?? '',
      );

      if (url == null || title.isEmpty || !seenLinks.add(url)) {
        continue;
      }

      target.add(
        NewsItem(
          title: title,
          url: url,
          time: time,
          isPopular: isPopular,
        ),
      );
    }
  }

  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _fetchNews,
        ),
      ),
    );
  }

  Future<void> _openNews(String url) {
    return openExternalLink(context, url, baseUrl: _baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PortalAppBar(
        title: Text(
          'BanglaNews24',
          style: GoogleFonts.notoSansBengali(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        gradientColors: const [Color(0xFF1E88E5), Color(0xFF00ACC1)],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _fetchNews,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.notoSansBengali(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.notoSansBengali(
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Latest News'),
            Tab(text: 'Popular News'),
          ],
        ),
      ),
      body: _isLoading && _latestNews.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
            )
          : _hasError && _latestNews.isEmpty
              ? _buildErrorState()
              : Column(
                  children: [
                    if (_lastUpdated != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Row(
                          children: [
                            Icon(Icons.update,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Updated ${_formatTimestamp(_lastUpdated!)}',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildNewsList(_latestNews),
                          _buildNewsList(_popularNews),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load news',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchNews,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(List<NewsItem> newsItems) {
    if (newsItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No news available',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNews,
      color: const Color(0xFF1E88E5),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: newsItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = newsItems[index];
          return _NewsCard(
            title: item.title,
            time: item.time,
            isPopular: item.isPopular,
            onTap: () => _openNews(item.url),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime value) {
    final month = _monthLabel(value.month);
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final meridiem = value.hour >= 12 ? 'PM' : 'AM';
    return '$month ${value.day}, $hour:$minute $meridiem';
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.title,
    required this.time,
    required this.isPopular,
    required this.onTap,
  });

  final String title;
  final String time;
  final bool isPopular;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSansBengali(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (time.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  if (isPopular) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7043).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_up,
                            size: 14,
                            color: Color(0xFFFF7043),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Popular',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFF7043),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
