import 'dart:convert';

import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:web_scraping_with_flutter/core/config/constants.dart';
import 'package:web_scraping_with_flutter/core/config/portals.dart';
import 'package:web_scraping_with_flutter/core/models/news_item.dart';
import 'package:web_scraping_with_flutter/core/utils/app_http_client.dart';
import 'package:web_scraping_with_flutter/core/utils/external_link_opener.dart';
import 'package:web_scraping_with_flutter/core/utils/text_utils.dart';

/// Centralized news scraper service.
class NewsScraperService {
  late final http.Client _client;
  late final http.Client _lenientClient;

  NewsScraperService() {
    _client = http.Client();
    _lenientClient = createAppHttpClient(allowBadCertificates: true);
  }

  void dispose() {
    _client.close();
    _lenientClient.close();
  }

  /// Scrape articles from a portal based on its config.
  Future<List<NewsItem>> scrapePortal(PortalConfig portal) async {
    switch (portal.strategy) {
      case ScrapingStrategy.html:
        return _scrapeHtml(portal);
      case ScrapingStrategy.rss:
        return _scrapeRss(portal);
      case ScrapingStrategy.restApi:
        return _scrapeRestApi(portal);
      case ScrapingStrategy.sitemap:
        return _scrapeSitemap(portal);
    }
  }

  // ─── HTML scraping ─────────────────────────────────────────────────────────

  Future<List<NewsItem>> _scrapeHtml(PortalConfig portal) async {
    final response = await _getClient(portal)
        .get(Uri.parse(portal.scrapeUrl), headers: portal.effectiveHeaders)
        .timeout(AppConstants.httpTimeout);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final document = parser.parse(utf8.decode(response.bodyBytes));
    final seen = <String>{};
    final articles = <NewsItem>[];

    // Portal-specific HTML parsers
    switch (portal.id) {
      case 'banglanews24':
        articles.addAll(_parseBanglaNews24(document, portal.baseUrl, seen));
      case 'ittefaq':
        articles.addAll(_parseIttefaq(document, portal.baseUrl, seen));
      case 'samakal':
        articles.addAll(_parseSamakal(document, portal.baseUrl, seen));
      case 'manabzamin':
        articles.addAll(_parseManabzamin(document, portal.baseUrl, seen));
      case 'dailystar':
        articles.addAll(_parseDailyStar(document, portal.baseUrl, seen));
      case 'tbsnews':
        articles.addAll(_parseTbsNews(document, portal.baseUrl, seen));
      case 'bdnews24':
        articles.addAll(_parseBdnews24(document, portal.baseUrl, seen));
      case 'jagonews24':
        articles.addAll(_parseJagoNews24(document, portal.baseUrl, seen));
      case 'somoynews':
        articles.addAll(_parseSomoyNews(document, portal.baseUrl, seen));
      case 'banglatribune':
        articles.addAll(_parseBanglaTribune(document, portal.baseUrl, seen));
      case 'dhakapost':
        articles.addAll(_parseDhakaPost(document, portal.baseUrl, seen));
      case 'dailyinqilab':
        articles.addAll(_parseDailyInqilab(document, portal.baseUrl, seen));
      case 'dhakatribune':
        articles.addAll(_parseDhakaTribune(document, portal.baseUrl, seen));
      case 'newagebd':
        articles.addAll(_parseNewAgeBd(document, portal.baseUrl, seen));
      default:
        articles.addAll(_parseGenericHtml(document, portal.baseUrl, seen));
    }

    return articles.take(AppConstants.maxArticlesPerPortal).toList();
  }

  List<NewsItem> _parseBanglaNews24(
      dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    final latestTab = document.querySelector('#home-tab-pane');
    if (latestTab != null) {
      for (final el in latestTab.querySelectorAll('li.list-group-item')) {
        final link = el.querySelector('a');
        final url = normalizeExternalUrl(link?.attributes['href'] ?? '', baseUrl: baseUrl);
        final title = TextUtils.cleanText(link?.text ?? '');
        final time = TextUtils.cleanText(el.querySelector('time, .time, small')?.text ?? '');
        if (url != null && title.isNotEmpty && seen.add(url)) {
          items.add(NewsItem(title: title, url: url, time: time));
        }
      }
    }
    return items;
  }

  List<NewsItem> _parseIttefaq(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final block in document.querySelectorAll('div.info')) {
      final titleEl = block.querySelector('h2.title a.link_overlay, a');
      final descEl = block.querySelector('div.summery, p');
      final url = normalizeExternalUrl(titleEl?.attributes['href'] ?? '', baseUrl: baseUrl);
      final title = TextUtils.cleanText(titleEl?.text ?? '');
      if (url != null && title.isNotEmpty && seen.add(url)) {
        items.add(NewsItem(
          title: title,
          url: url,
          description: TextUtils.cleanText(descEl?.text ?? ''),
        ));
      }
    }
    return items;
  }

  List<NewsItem> _parseSamakal(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final anchor in document.querySelectorAll('a[href*="/article/"]')) {
      final url = normalizeExternalUrl(anchor.attributes['href'] ?? '', baseUrl: baseUrl);
      final title = TextUtils.cleanText(anchor.text);
      if (url != null && title.length >= 8 && seen.add(url)) {
        final timeEl = anchor.parent?.querySelector('time, .time, [class*="time"]');
        items.add(NewsItem(title: title, url: url, time: TextUtils.cleanText(timeEl?.text ?? '')));
      }
    }
    return items;
  }

  List<NewsItem> _parseManabzamin(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final anchor in document.querySelectorAll('a[href*="/article/"]')) {
      final url = normalizeExternalUrl(anchor.attributes['href'] ?? '', baseUrl: baseUrl);
      final title = TextUtils.cleanText(anchor.text);
      if (url != null && title.length >= 8 && seen.add(url)) {
        final catEl = anchor.parent?.parent?.querySelector('[class*="cat"],[class*="section"]');
        items.add(NewsItem(title: title, url: url, category: TextUtils.cleanText(catEl?.text ?? '')));
      }
    }
    return items;
  }

  List<NewsItem> _parseDailyStar(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final anchor in document.querySelectorAll('a[href*="/news-"]')) {
      final href = anchor.attributes['href'] ?? '';
      if (href.isEmpty) continue;
      final url = href.startsWith('http') ? href : '$baseUrl$href';
      final title = TextUtils.cleanText(anchor.text);
      if (title.length < 8 || !seen.add(url)) continue;

      final pathParts = Uri.tryParse(url)?.pathSegments ?? [];
      String category = '';
      if (pathParts.length >= 2) {
        final seg = pathParts[pathParts.length - 2];
        if (!seg.startsWith('news-') && seg.isNotEmpty) {
          category = seg.replaceAll('-', ' ');
        }
      }
      items.add(NewsItem(title: title, url: url, category: category));
    }
    return items;
  }

  List<NewsItem> _parseTbsNews(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final card in document.querySelectorAll('.card')) {
      final titleEl = card.querySelector('h3 a');
      if (titleEl == null) continue;

      final url = normalizeExternalUrl(titleEl.attributes['href'] ?? '', baseUrl: baseUrl);
      if (url == null || !seen.add(url)) continue;

      final descEl = card.querySelector('.card-section p');
      final dateEl = card.querySelector('.date');
      final imgEl = card.querySelector('img');

      var imageUrl = imgEl?.attributes['data-src'] ?? imgEl?.attributes['src'] ?? '';
      if (imageUrl.startsWith('//')) imageUrl = 'https:$imageUrl';

      var time = '';
      var category = '';
      final dateText = dateEl?.text.trim() ?? '';
      final parts = dateText.split('|');
      if (parts.length > 1) {
        time = parts[0].trim();
        category = parts[1].trim();
      } else {
        time = dateText;
      }

      items.add(NewsItem(
        title: TextUtils.cleanText(titleEl.text),
        url: url,
        description: TextUtils.cleanText(descEl?.text ?? ''),
        time: time,
        category: category,
        imageUrl: imageUrl,
      ));
    }
    return items;
  }

  List<NewsItem> _parseGenericHtml(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final anchor in document.querySelectorAll('a[href]')) {
      final href = anchor.attributes['href'] ?? '';
      if (href.isEmpty) continue;
      final url = href.startsWith('http') ? href : '$baseUrl$href';
      final title = TextUtils.cleanText(anchor.text);
      if (title.length < 8 || !seen.add(url)) continue;
      items.add(NewsItem(title: title, url: url));
    }
    return items;
  }

  // ─── RSS parsing ───────────────────────────────────────────────────────────

  Future<List<NewsItem>> _scrapeRss(PortalConfig portal) async {
    final response = await _client
        .get(Uri.parse(portal.scrapeUrl))
        .timeout(AppConstants.httpTimeout);

    if (response.statusCode != 200) {
      throw Exception('RSS feed error: ${response.statusCode}');
    }

    final document = parser.parse(utf8.decode(response.bodyBytes));
    final seen = <String>{};
    final items = <NewsItem>[];

    for (final element in document.querySelectorAll(portal.rssItemTag)) {
      final rawLink = element.querySelector('link')?.text.trim() ?? '';
      final fallbackLink = element.querySelector('guid')?.text.trim() ?? '';
      final link = rawLink.startsWith('http') ? rawLink : fallbackLink;
      if (link.isEmpty || !seen.add(link)) continue;

      final title = TextUtils.cleanText(element.querySelector('title')?.text ?? 'No Title');
      final pubDate = _formatRssDate(element.querySelector('pubDate')?.text);
      final description = TextUtils.cleanText(element.querySelector('description')?.text ?? '');

      items.add(NewsItem(
        title: title,
        url: link,
        time: pubDate,
        description: description,
      ));
    }

    return items.take(AppConstants.maxArticlesPerPortal).toList();
  }

  String _formatRssDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(dateString);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (_) {
      return dateString;
    }
  }

  // ─── REST API parsing ──────────────────────────────────────────────────────

  Future<List<NewsItem>> _scrapeRestApi(PortalConfig portal) async {
    final items = <NewsItem>[];
    final seen = <String>{};

    // Prothom Alo multi-section API endpoints
    final apiUrls = switch (portal.id) {
      'prothomalo' => [
          '${portal.baseUrl}/api/v1/stories?fields=id,headline,slug,sections,published-at,author-name&section=bangladesh&limit=15',
          '${portal.baseUrl}/api/v1/stories?fields=id,headline,slug,sections,published-at,author-name&section=politics&limit=10',
          '${portal.baseUrl}/api/v1/stories?fields=id,headline,slug,sections,published-at,author-name&section=world&limit=10',
        ],
      _ => [portal.scrapeUrl],
    };

    for (final apiUrl in apiUrls) {
      final response = await _client
          .get(Uri.parse(apiUrl), headers: portal.effectiveHeaders)
          .timeout(AppConstants.httpTimeout);

      if (response.statusCode != 200) continue;

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final stories = (json['stories'] as List?) ?? [];

      for (final story in stories) {
        final id = story['id']?.toString() ?? '';
        final headline = TextUtils.cleanText(story['headline']?.toString() ?? '');
        final slug = story['slug']?.toString() ?? '';
        final publishedAt = story['published-at'] as int? ?? 0;
        final author = TextUtils.cleanText(story['author-name']?.toString() ?? '');

        if (headline.isEmpty || slug.isEmpty || !seen.add(id)) continue;

        final sections = story['sections'] as List? ?? [];
        final sectionName = sections.isNotEmpty
            ? TextUtils.cleanText(sections.first['display-name']?.toString() ?? '')
            : '';

        final url = '${portal.baseUrl}/$slug';
        final time = publishedAt > 0 ? _formatApiTimestamp(publishedAt) : '';

        items.add(NewsItem(
          title: headline,
          url: url,
          time: time,
          category: sectionName,
          description: author.isNotEmpty ? 'by $author' : '',
        ));
      }
    }

    return items.take(AppConstants.maxArticlesPerPortal).toList();
  }

  String _formatApiTimestamp(int millis) {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(millis);
      return DateFormat('MMM dd, yyyy – hh:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  // ─── Sitemap parsing ───────────────────────────────────────────────────────

  Future<List<NewsItem>> _scrapeSitemap(PortalConfig portal) async {
    final response = await _client
        .get(Uri.parse(portal.scrapeUrl))
        .timeout(AppConstants.httpTimeout);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final document = parser.parse(utf8.decode(response.bodyBytes));
    final seen = <String>{};
    final items = <NewsItem>[];

    for (final urlEl in document.querySelectorAll('url')) {
      final loc = urlEl.querySelector('loc')?.text.trim() ?? '';
      if (loc.isEmpty || !seen.add(loc)) continue;

      final rawTitle = urlEl.querySelector('title')?.text.trim() ?? '';
      final title = TextUtils.cleanText(rawTitle);
      if (title.length < 4) continue;

      final pubDateRaw = urlEl.querySelector('publication_date, pubdate, lastmod')?.text.trim() ?? '';
      final time = pubDateRaw.isNotEmpty ? _formatSitemapDate(pubDateRaw) : '';
      final category = TextUtils.cleanText(urlEl.querySelector('keywords')?.text ?? '');

      items.add(NewsItem(title: title, url: loc, time: time, category: category));
    }

    return items.take(AppConstants.maxArticlesPerPortal).toList();
  }

  String _formatSitemapDate(String raw) {
    try {
      return DateFormat('MMM dd, yyyy – hh:mm a').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  // ─── New portal parsers ──────────────────────────────────────────────────────

  List<NewsItem> _parseBdnews24(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final anchor in document.querySelectorAll('a[href*="/bangladesh/"], a[href*="/world/"], a[href*="/politics/"]')) {
      final href = anchor.attributes['href'] ?? '';
      if (href.isEmpty) continue;
      final url = href.startsWith('http') ? href : '$baseUrl$href';
      final title = TextUtils.cleanText(anchor.text);
      if (title.length < 10 || !seen.add(url)) continue;
      final timeEl = anchor.parent?.querySelector('time, .time, .date');
      items.add(NewsItem(title: title, url: url, time: TextUtils.cleanText(timeEl?.text ?? '')));
    }
    return items;
  }

  List<NewsItem> _parseJagoNews24(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final anchor in document.querySelectorAll('a[href]')) {
      final href = anchor.attributes['href'] ?? '';
      if (href.isEmpty || !href.contains('/news/') && !href.contains('/details/')) continue;
      final url = href.startsWith('http') ? href : '$baseUrl$href';
      final title = TextUtils.cleanText(anchor.text);
      if (title.length < 10 || !seen.add(url)) continue;
      items.add(NewsItem(title: title, url: url));
    }
    return items;
  }

  List<NewsItem> _parseSomoyNews(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final anchor in document.querySelectorAll('a[href*="/news/"], a[href*="/news-details/"]')) {
      final href = anchor.attributes['href'] ?? '';
      if (href.isEmpty) continue;
      final url = href.startsWith('http') ? href : '$baseUrl$href';
      final title = TextUtils.cleanText(anchor.text);
      if (title.length < 10 || !seen.add(url)) continue;
      final timeEl = anchor.parent?.querySelector('time, .time, .date');
      items.add(NewsItem(title: title, url: url, time: TextUtils.cleanText(timeEl?.text ?? '')));
    }
    return items;
  }

  List<NewsItem> _parseBanglaTribune(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final article in document.querySelectorAll('article, .news-list-item, .news-item')) {
      final anchor = article.querySelector('a[href]');
      if (anchor == null) continue;
      final href = anchor.attributes['href'] ?? '';
      final url = href.startsWith('http') ? href : '$baseUrl$href';
      final titleEl = article.querySelector('h2, h3, .title');
      final title = TextUtils.cleanText(titleEl?.text ?? anchor.text);
      if (title.length < 10 || !seen.add(url)) continue;
      final timeEl = article.querySelector('time, .time, .date');
      items.add(NewsItem(title: title, url: url, time: TextUtils.cleanText(timeEl?.text ?? '')));
    }
    if (items.isEmpty) {
      for (final anchor in document.querySelectorAll('a[href*="/news/"]')) {
        final url = normalizeExternalUrl(anchor.attributes['href'] ?? '', baseUrl: baseUrl);
        final title = TextUtils.cleanText(anchor.text);
        if (url != null && title.length >= 10 && seen.add(url)) {
          items.add(NewsItem(title: title, url: url));
        }
      }
    }
    return items;
  }

  List<NewsItem> _parseDhakaPost(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final anchor in document.querySelectorAll('a[href*="/article/"], a[href*="/news/"]')) {
      final href = anchor.attributes['href'] ?? '';
      if (href.isEmpty) continue;
      final url = href.startsWith('http') ? href : '$baseUrl$href';
      final title = TextUtils.cleanText(anchor.text);
      if (title.length < 10 || !seen.add(url)) continue;
      items.add(NewsItem(title: title, url: url));
    }
    return items;
  }

  List<NewsItem> _parseDailyInqilab(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final anchor in document.querySelectorAll('a[href]')) {
      final href = anchor.attributes['href'] ?? '';
      if (href.isEmpty) continue;
      final url = href.startsWith('http') ? href : '$baseUrl$href';
      final title = TextUtils.cleanText(anchor.text);
      if (title.length < 10 || !seen.add(url)) continue;
      final timeEl = anchor.parent?.querySelector('time, .time, .date');
      items.add(NewsItem(title: title, url: url, time: TextUtils.cleanText(timeEl?.text ?? '')));
    }
    return items;
  }

  List<NewsItem> _parseDhakaTribune(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final anchor in document.querySelectorAll('a[href*="/latest/"], a[href*="/article/"], a[href*="/news/"]')) {
      final href = anchor.attributes['href'] ?? '';
      if (href.isEmpty) continue;
      final url = href.startsWith('http') ? href : '$baseUrl$href';
      final title = TextUtils.cleanText(anchor.text);
      if (title.length < 10 || !seen.add(url)) continue;
      final timeEl = anchor.parent?.querySelector('time, .time, .date');
      items.add(NewsItem(title: title, url: url, time: TextUtils.cleanText(timeEl?.text ?? '')));
    }
    return items;
  }

  List<NewsItem> _parseNewAgeBd(dynamic document, String baseUrl, Set<String> seen) {
    final items = <NewsItem>[];
    for (final anchor in document.querySelectorAll('a[href*="/news/"], a[href*="/article/"]')) {
      final href = anchor.attributes['href'] ?? '';
      if (href.isEmpty) continue;
      final url = href.startsWith('http') ? href : '$baseUrl$href';
      final title = TextUtils.cleanText(anchor.text);
      if (title.length < 10 || !seen.add(url)) continue;
      items.add(NewsItem(title: title, url: url));
    }
    return items;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  http.Client _getClient(PortalConfig portal) {
    return portal.allowBadCertificates ? _lenientClient : _client;
  }
}
