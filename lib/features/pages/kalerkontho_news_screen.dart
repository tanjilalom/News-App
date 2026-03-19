import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/core/utils/external_link_opener.dart';
import 'package:web_scraping_with_flutter/core/widgets/portal_app_bar.dart';

class KalerKonthoNewsScreen extends StatefulWidget {
  const KalerKonthoNewsScreen({super.key});

  @override
  State<KalerKonthoNewsScreen> createState() => _KalerKonthoNewsScreenState();
}

class _KalerKonthoNewsScreenState extends State<KalerKonthoNewsScreen> {
  static const _feedUrl = 'https://www.kalerkantho.com/rss.xml';

  final http.Client _client = http.Client();
  final String _channelTitle = 'Kaler Kantho News';

  List<_RssNewsItem> _items = const [];
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
      final response = await _client
          .get(Uri.parse(_feedUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('RSS feed error: ${response.statusCode}');
      }

      final document = parse(utf8.decode(response.bodyBytes));
      final seenLinks = <String>{};
      final items = <_RssNewsItem>[];

      for (final element in document.querySelectorAll('item')) {
        final rawLink = element.querySelector('link')?.text.trim() ?? '';
        final fallbackLink = element.querySelector('guid')?.text.trim() ?? '';
        final link = rawLink.startsWith('http') ? rawLink : fallbackLink;

        if (link.isEmpty || !seenLinks.add(link)) {
          continue;
        }

        items.add(
          _RssNewsItem(
            title: element.querySelector('title')?.text.trim() ?? 'No Title',
            pubDate: _formatDate(element.querySelector('pubDate')?.text),
            link: link,
            description:
                _cleanText(element.querySelector('description')?.text ?? ''),
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _items = items;
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      _showErrorSnackBar(error.toString());
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'No Date';
    }

    try {
      final date =
          DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(dateString);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (_) {
      return dateString;
    }
  }

  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red[400],
      ),
    );
  }

  Future<void> _openNews(String url) {
    return openExternalLink(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PortalAppBar(
        title: Text(
          _channelTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _fetchNews,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3366FF)),
            )
          : _hasError
              ? _buildErrorUI()
              : RefreshIndicator(
                  onRefresh: _fetchNews,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      if (_lastUpdated != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.update,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Updated ${DateFormat('MMM dd, hh:mm a').format(_lastUpdated!)}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _NewsCard(
                              title: item.title,
                              date: item.pubDate,
                              description: item.description,
                              onTap: () => _openNews(item.link),
                            );
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorUI() {
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
              backgroundColor: AppColors.brandBlue,
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
}

class _RssNewsItem {
  const _RssNewsItem({
    required this.title,
    required this.pubDate,
    required this.link,
    required this.description,
  });

  final String title;
  final String pubDate;
  final String link;
  final String description;
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.title,
    required this.date,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String date;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7367F0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Read',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF7367F0),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Color(0xFF7367F0),
                      ),
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
