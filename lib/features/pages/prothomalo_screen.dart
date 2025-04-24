import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<NewsItem> newsItems = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    const url = 'https://www.prothomalo.com/collection/latest';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final articles = document.querySelectorAll('.news_with_item');

      final List<NewsItem> extractedItems = [];

      for (var article in articles) {
        final titleElement = article.querySelector('.headline-title');
        final anchor = titleElement?.querySelector('a');
        final title = anchor?.text.trim() ?? 'No title';
        final link = anchor?.attributes['href'] ?? '';

        if (title.isNotEmpty && link.isNotEmpty) {
          extractedItems.add(NewsItem(
            title: title,
            url: 'https://www.prothomalo.com$link',
          ));
        }
      }

      setState(() {
        newsItems = extractedItems;
      });
    } else {
      print('❌ Failed to fetch news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('প্রথম আলো খবর')),
      body: newsItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          final item = newsItems[index];
          return ListTile(
            title: Text(item.title),
            subtitle: Text(item.url),
            onTap: () {
              // open in browser or WebView
            },
          );
        },
      ),
    );
  }
}


class NewsItem {
  final String title;
  final String url;

  NewsItem({required this.title, required this.url});
}
