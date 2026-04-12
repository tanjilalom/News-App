import 'package:hive_flutter/hive_flutter.dart';
import 'package:web_scraping_with_flutter/core/config/constants.dart';
import 'package:web_scraping_with_flutter/core/models/news_item.dart';

/// Hive cache service for offline article storage.
class CacheService {
  static const _boxName = 'news_cache';
  static const _metaBoxName = 'news_meta';
  static const _cacheTimestampKey = 'cache_timestamp';

  Box<Map>? _cacheBox;
  Box<DateTime>? _metaBox;

  /// Initialize Hive and open boxes.
  Future<void> init() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox<Map>(_boxName);
    _metaBox = await Hive.openBox<DateTime>(_metaBoxName);
  }

  /// Save articles for a given portal ID.
  Future<void> saveArticles(String portalId, List<NewsItem> items) async {
    if (_cacheBox == null) return;
    final data = items.map((item) => {
      'title': item.title,
      'url': item.url,
      'time': item.time,
      'category': item.category,
      'imageUrl': item.imageUrl,
      'isPopular': item.isPopular,
      'description': item.description,
    }).toList();
    await _cacheBox!.put(portalId, {'articles': data});
    await _metaBox?.put(_cacheTimestampKey, DateTime.now());
  }

  /// Retrieve cached articles for a given portal ID.
  List<NewsItem> getArticles(String portalId) {
    if (_cacheBox == null) return [];
    final raw = _cacheBox!.get(portalId);
    if (raw == null) return [];

    final articlesRaw = raw['articles'];
    if (articlesRaw == null) return [];
    final articles = articlesRaw as List;

    return articles.map((e) {
      final map = e as Map;
      return NewsItem(
        title: map['title'] as String? ?? '',
        url: map['url'] as String? ?? '',
        time: map['time'] as String? ?? '',
        category: map['category'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        isPopular: map['isPopular'] as bool? ?? false,
        description: map['description'] as String? ?? '',
      );
    }).toList();
  }

  /// Check if the cache is still fresh.
  bool isCacheFresh() {
    final timestamp = _metaBox?.get(_cacheTimestampKey);
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < AppConstants.cacheExpiry;
  }

  /// Get the last cache timestamp.
  DateTime? getCacheTimestamp() {
    return _metaBox?.get(_cacheTimestampKey);
  }

  /// Clear all cached data.
  Future<void> clear() async {
    await _cacheBox?.clear();
    await _metaBox?.clear();
  }

  /// Close boxes.
  Future<void> close() async {
    await _cacheBox?.close();
    await _metaBox?.close();
  }
}

/// Global cache service instance.
final cacheService = CacheService();
