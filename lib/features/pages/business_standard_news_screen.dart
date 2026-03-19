import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/core/utils/external_link_opener.dart';
import 'package:web_scraping_with_flutter/core/widgets/portal_app_bar.dart';

class TBSNewsScreen extends StatefulWidget {
  const TBSNewsScreen({super.key});

  @override
  State<TBSNewsScreen> createState() => _TBSNewsScreenState();
}

class _TBSNewsScreenState extends State<TBSNewsScreen> {
  final NewsScraperService _service = NewsScraperService();
  late Future<List<TBSNewsModel>> futureNews;

  @override
  void initState() {
    super.initState();
    futureNews = _service.fetchNews();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _refreshNews() async {
    setState(() {
      futureNews = _service.fetchNews();
    });
    await futureNews;
  }

  Future<void> _openNews(String url) {
    return openExternalLink(context, url, baseUrl: NewsScraperService.baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PortalAppBar(
        title: Text(
          'TBS News বাংলা',
          style: GoogleFonts.notoSansBengali(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshNews,
          ),
        ],
      ),
      body: FutureBuilder<List<TBSNewsModel>>(
        future: futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
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
                ],
              ),
            );
          }

          final newsList = snapshot.data ?? const <TBSNewsModel>[];

          return RefreshIndicator(
            onRefresh: _refreshNews,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: newsList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final news = newsList[index];
                return InkWell(
                  onTap: () => _openNews(news.articleUrl),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (news.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: news.imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, _) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                              errorWidget: (context, _, __) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        if (news.imageUrl.isNotEmpty) const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.title,
                                style: GoogleFonts.notoSansBengali(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                news.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      news.time,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (news.category.isNotEmpty)
                                    Text(
                                      news.category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blueGrey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class TBSNewsModel {
  const TBSNewsModel({
    required this.title,
    required this.description,
    required this.articleUrl,
    required this.category,
    required this.time,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String articleUrl;
  final String category;
  final String time;
  final String imageUrl;
}

class NewsScraperService {
  static const String baseUrl = 'https://www.tbsnews.net';

  final http.Client _client = http.Client();

  void dispose() {
    _client.close();
  }

  Future<List<TBSNewsModel>> fetchNews() async {
    final response = await _client
        .get(Uri.parse('$baseUrl/bangla'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load TBS news: ${response.statusCode}');
    }

    final document = parse(utf8.decode(response.bodyBytes));
    final newsCards = document.querySelectorAll('.card');
    final seenUrls = <String>{};
    final articles = <TBSNewsModel>[];

    for (final card in newsCards) {
      try {
        final titleElement = card.querySelector('h3 a');
        if (titleElement == null) {
          continue;
        }

        final articleUrl = normalizeExternalUrl(
          titleElement.attributes['href'] ?? '',
          baseUrl: baseUrl,
        );
        if (articleUrl == null || !seenUrls.add(articleUrl)) {
          continue;
        }

        final descElement = card.querySelector('.card-section p');
        final dateElement = card.querySelector('.date');
        final imageElement = card.querySelector('img');

        var imageUrl = imageElement?.attributes['data-src'] ??
            imageElement?.attributes['src'] ??
            '';
        if (imageUrl.startsWith('//')) {
          imageUrl = 'https:$imageUrl';
        }

        var time = '';
        var category = '';
        final dateText = dateElement?.text.trim() ?? '';
        final parts = dateText.split('|');
        if (parts.length > 1) {
          time = parts[0].trim();
          category = parts[1].trim();
        } else {
          time = dateText;
        }

        articles.add(
          TBSNewsModel(
            title: titleElement.text.trim(),
            description: descElement?.text.trim() ?? '',
            articleUrl: articleUrl,
            category: category,
            time: time,
            imageUrl: imageUrl,
          ),
        );
      } catch (error) {
        debugPrint('Error parsing news card: $error');
      }
    }

    return articles;
  }
}
