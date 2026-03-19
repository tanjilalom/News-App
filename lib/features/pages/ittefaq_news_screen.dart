import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/core/utils/app_http_client.dart';
import 'package:web_scraping_with_flutter/core/utils/external_link_opener.dart';
import 'package:web_scraping_with_flutter/core/widgets/portal_app_bar.dart';

class IttefaqNewsScreen extends StatefulWidget {
  const IttefaqNewsScreen({super.key});

  @override
  State<IttefaqNewsScreen> createState() => _IttefaqNewsScreenState();
}

class _IttefaqNewsScreenState extends State<IttefaqNewsScreen> {
  static const _channelTitle = 'Ittefaq News';
  static const _baseUrl = 'https://www.ittefaq.com.bd';
  static const _url = '$_baseUrl/latest-news';

  late final http.Client _client;

  List<_IttefaqArticle> _newsList = const [];
  bool _isLoading = true;
  bool _hasError = false;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _client = createAppHttpClient(allowBadCertificates: true);
    _fetchIttefaqNews();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _fetchIttefaqNews() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _client
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to load page: ${response.statusCode}');
      }

      final document = html_parser.parse(response.body);
      final seenLinks = <String>{};
      final items = <_IttefaqArticle>[];

      for (final block in document.querySelectorAll('div.info')) {
        final titleElement = block.querySelector('h2.title a.link_overlay, a');
        final descElement = block.querySelector('div.summery, p');
        final url = normalizeExternalUrl(
          titleElement?.attributes['href'] ?? '',
          baseUrl: _baseUrl,
        );
        final title = _cleanText(titleElement?.text ?? '');

        if (url == null || title.isEmpty || !seenLinks.add(url)) {
          continue;
        }

        items.add(
          _IttefaqArticle(
            title: title,
            link: url,
            description: _cleanText(descElement?.text ?? ''),
            pubDate:
                DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now()),
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _newsList = items;
        _isLoading = false;
        _lastUpdated = DateTime.now();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
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
          _channelTitle,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _fetchIttefaqNews,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _fetchIttefaqNews,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount:
                        _newsList.length + (_lastUpdated != null ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_lastUpdated != null && index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Icon(Icons.update,
                                  size: 16, color: Colors.grey[600]),
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
                        );
                      }

                      final item =
                          _newsList[_lastUpdated != null ? index - 1 : index];
                      return _NewsCard(
                        title: item.title,
                        date: item.pubDate,
                        description: item.description,
                        onTap: () => _openNews(item.link),
                      );
                    },
                  ),
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
            'Error loading news.',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchIttefaqNews,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _IttefaqArticle {
  const _IttefaqArticle({
    required this.title,
    required this.link,
    required this.description,
    required this.pubDate,
  });

  final String title;
  final String link;
  final String description;
  final String pubDate;
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
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
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
      ),
    );
  }
}
