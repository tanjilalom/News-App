// news_screen.dart

import 'package:flutter/material.dart';
import 'package:web_scraping_with_flutter/networks/scraper_services.dart'; // Import scraper_services

class RSSFeedWidget extends StatefulWidget {
  final String rssUrl;

  const RSSFeedWidget({super.key, required this.rssUrl});

  @override
  State<RSSFeedWidget> createState() => _RSSFeedWidgetState();
}

class _RSSFeedWidgetState extends State<RSSFeedWidget> {
  String? _channelTitle;
  List<Map<String, String>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final data = await fetchRSS(widget.rssUrl);
      setState(() {
        _channelTitle = data['channelTitle'];
        _items = List<Map<String, String>>.from(data['items']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _channelTitle = 'Error loading feed';
        _items = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_channelTitle ?? 'Loading...'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadFeed();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(item['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(item['pubDate'] ?? '',
                          style: const TextStyle(color: Colors.grey)),
                    ),
                    onTap: () {
                      final link = item['link'];
                      if (link != null && link.isNotEmpty) {

                        debugPrint('Tapped link: $link');
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
