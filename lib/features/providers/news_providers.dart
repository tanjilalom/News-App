import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_scraping_with_flutter/core/config/constants.dart';
import 'package:web_scraping_with_flutter/core/config/portals.dart';
import 'package:web_scraping_with_flutter/core/models/news_item.dart';
import 'package:web_scraping_with_flutter/core/services/cache_service.dart';
import 'package:web_scraping_with_flutter/core/services/news_scraper.dart';

// ─── Scraper service provider ────────────────────────────────────────────────

final scraperServiceProvider = Provider<NewsScraperService>((ref) {
  final service = NewsScraperService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ─── News state ──────────────────────────────────────────────────────────────

class NewsState {
  const NewsState({
    this.articles = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.lastUpdated,
    this.hasMore = false,
    this.page = 1,
  });

  final List<NewsItem> articles;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final DateTime? lastUpdated;
  final bool hasMore;
  final int page;

  NewsState copyWith({
    List<NewsItem>? articles,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    DateTime? lastUpdated,
    bool? hasMore,
    int? page,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

// ─── News provider for a single portal ───────────────────────────────────────

class NewsNotifier extends StateNotifier<NewsState> {
  NewsNotifier(this.ref, this.portal) : super(const NewsState());

  final Ref ref;
  final PortalConfig portal;
  DateTime? _lastRefresh;

  bool get _canRefresh {
    if (_lastRefresh == null) return true;
    return DateTime.now().difference(_lastRefresh!) >= AppConstants.refreshCooldown;
  }

  Future<void> fetch({bool refresh = false, bool append = false}) async {
    if (state.isLoading) return;
    if (refresh && !_canRefresh) return;

    // Serve from cache if not a forced refresh
    if (!refresh && cacheService.isCacheFresh()) {
      final cached = cacheService.getArticles(portal.id);
      if (cached.isNotEmpty) {
        state = state.copyWith(
          articles: cached,
          lastUpdated: cacheService.getCacheTimestamp(),
          isLoading: false,
          hasError: false,
        );
        return;
      }
    }

    state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');

    try {
      final scraper = ref.read(scraperServiceProvider);
      final articles = await scraper.scrapePortal(portal);

      if (!refresh && !append) {
        // Cache the fresh data
        await cacheService.saveArticles(portal.id, articles);
      }

      _lastRefresh = DateTime.now();

      state = state.copyWith(
        articles: append ? [...state.articles, ...articles] : articles,
        isLoading: false,
        hasError: articles.isEmpty,
        errorMessage: articles.isEmpty ? 'No articles found' : '',
        lastUpdated: DateTime.now(),
        hasMore: articles.length >= AppConstants.defaultPageSize,
        page: append ? state.page + 1 : 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  void clear() {
    state = const NewsState();
  }
}

/// Creates a news notifier for the given portal.
final newsProvider = StateNotifierProvider.family<NewsNotifier, NewsState, PortalConfig>(
  (ref, portal) => NewsNotifier(ref, portal),
);

// ─── Search state ────────────────────────────────────────────────────────────

class SearchState {
  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.searchedPortals = 0,
    this.totalPortals = 0,
  });

  final String query;
  final List<SearchResultEntry> results;
  final bool isSearching;
  final int searchedPortals;
  final int totalPortals;

  SearchState copyWith({
    String? query,
    List<SearchResultEntry>? results,
    bool? isSearching,
    int? searchedPortals,
    int? totalPortals,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      searchedPortals: searchedPortals ?? this.searchedPortals,
      totalPortals: totalPortals ?? this.totalPortals,
    );
  }
}

class SearchResultEntry {
  const SearchResultEntry(this.portal, this.article);
  final PortalConfig portal;
  final NewsItem article;
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this.ref) : super(const SearchState());

  final Ref ref;

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const SearchState();
      return;
    }

    state = SearchState(
      query: trimmed,
      results: [],
      isSearching: true,
      searchedPortals: 0,
      totalPortals: PortalRegistry.all.length,
    );

    final scraper = ref.read(scraperServiceProvider);
    final allResults = <SearchResultEntry>[];

    for (final portal in PortalRegistry.all) {
      try {
        final articles = await scraper.scrapePortal(portal);
        final matches = articles.where((a) {
          final titleLower = a.title.toLowerCase();
          final q = trimmed.toLowerCase();
          return titleLower.contains(q) ||
              a.description.toLowerCase().contains(q) ||
              a.category.toLowerCase().contains(q);
        }).toList();

        for (final match in matches) {
          allResults.add(SearchResultEntry(portal, match));
        }
      } catch (_) {
        // Skip failed portals
      }

      state = state.copyWith(
        searchedPortals: state.searchedPortals + 1,
        results: List.from(allResults),
      );
    }

    state = state.copyWith(
      isSearching: false,
      results: allResults,
    );
  }

  void clear() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(ref),
);

// ─── Theme mode provider ─────────────────────────────────────────────────────

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
