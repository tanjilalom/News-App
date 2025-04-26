/*
// scraper_services.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

// bypass SSL validation
HttpClient getCustomHttpClient() {
  final httpClient = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  return httpClient;
}

Future<void> fetchQuotes() async {
  // const url = 'http://quotes.toscrape.com';
  const url = 'https://www.techlandbd.com/pc-components/processor';

  try {
    //final ioClient = IOClient(getCustomHttpClient());
    // final response = await ioClient.get(Uri.parse(url));

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final quoteElements = document.querySelectorAll('div.caption');

      debugPrint(quoteElements.toString());

      setState(() {
        _quotes = quoteElements.map((e) {
          final text = e.querySelector('div.name')?.text ?? "";

          final author = e.querySelector('span.price-new')?.text ?? "";

          debugPrint("-----------${author.toString()}");
          //final author = e.querySelector('span.price-new')?.text ?? '';
          //return '$text — $author';
          return '$text - $author';
        }).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _quotes = ['Failed to load quotes: ${response.statusCode}'];
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _quotes = ['Error fetching quotes: $e'];
      _isLoading = false;
    });
  }
}

Future<Map<String, dynamic>> fetchRSS() async {
  const url = 'https://www.kalerkantho.com/rss.xml';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final document = parse(utf8.decode(response.bodyBytes));

      final channelTitle =
          document.querySelector('channel > title')?.text ?? 'Unknown Channel';

      final items = document.querySelectorAll('item').map((e) {
        final title = e.querySelector('title')?.text ?? 'No Title';
        final pubDate = e.querySelector('pubDate')?.text ?? 'No Date';
        final link = e.querySelector('link')?.text ?? '';
        print("+++++++++++++++ $link");
        return {
          'title': title,
          'pubDate': pubDate,
          'link': link,
        };
      }).toList();

      return {
        'channelTitle': channelTitle,
        'items': items,
      };
    } else {
      throw Exception('Failed to load RSS feed');
    }
  } catch (e) {
    throw Exception('Error fetching RSS: $e');
  }
}

Future<Map<String, dynamic>> fetchNewsPortal() async {

  const url = 'https://www.prothomalo.com/collection/latest';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parse(utf8.decode(response.bodyBytes));

      final channelTitle = document.querySelector('channel > title')?.text ?? 'Unknown Channel';

      // Find meta tag with name="brand_name"
      final metaTag = document.querySelector('meta[name="brand_name"]');
      final content = metaTag?.attributes['content'] ?? 'Not found';

      debugPrint(content);



      final news = document.querySelectorAll('div.w8MVw').map((e) {
        final headline =
            e.querySelector('h3.headline-title   _1d6-d')?.text ?? "";
        final postedTime =
            e.querySelector('time.published-at fw8bp')?.text ?? "";

        debugPrint("-----------${headline.toString()}");
        debugPrint("-----------${postedTime.toString()}");
        //final author = e.querySelector('span.price-new')?.text ?? '';
        //return '$text — $author';
        return {'headline': headline, 'postedTime': postedTime};
      }).toList();

      return {
        'channelTitle': channelTitle,
        'items': news,
      };
    } else {
      throw Exception('Failed to load feed');
    }
  } catch (e) {
    throw Exception('Failed to load feed');
  }
}
*/
