import 'package:flutter/material.dart';
import 'package:web_scraping_with_flutter/core/config/constants.dart';

// ─── Portal category enum ────────────────────────────────────────────────────

enum PortalCategory { all, bangla, english, finance }

extension PortalCategoryLabel on PortalCategory {
  String get label {
    switch (this) {
      case PortalCategory.all:
        return 'All';
      case PortalCategory.bangla:
        return 'বাংলা';
      case PortalCategory.english:
        return 'English';
      case PortalCategory.finance:
        return 'Finance';
    }
  }

  IconData get icon {
    switch (this) {
      case PortalCategory.all:
        return Icons.grid_view_rounded;
      case PortalCategory.bangla:
        return Icons.language_rounded;
      case PortalCategory.english:
        return Icons.abc_rounded;
      case PortalCategory.finance:
        return Icons.monetization_on_rounded;
    }
  }
}

// ─── Scraping strategy enum ──────────────────────────────────────────────────

enum ScrapingStrategy {
  html,       // HTML DOM scraping
  rss,        // RSS XML feed
  restApi,    // REST API (JSON)
  sitemap,    // Sitemap XML
}

// ─── Portal configuration ────────────────────────────────────────────────────

class PortalConfig {
  const PortalConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.category,
    required this.baseUrl,
    required this.scrapeUrl,
    required this.strategy,
    required this.screenRoute,
    this.headers = const {},
    this.cssSelectors = const {},
    this.rssItemTag = 'item',
    this.allowBadCertificates = false,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final PortalCategory category;
  final String baseUrl;
  final String scrapeUrl;
  final ScrapingStrategy strategy;
  final String screenRoute;
  final Map<String, String> headers;
  final Map<String, String> cssSelectors;
  final String rssItemTag;
  final bool allowBadCertificates;

  Map<String, String> get effectiveHeaders {
    if (headers.isNotEmpty) return headers;
    return {
      'User-Agent': AppConstants.userAgent,
      'Accept': 'text/html,application/xhtml+xml;q=0.9,*/*;q=0.8',
    };
  }
}

// ─── Portal registry ─────────────────────────────────────────────────────────

class PortalRegistry {
  PortalRegistry._();

  static const List<PortalConfig> all = [
    // Finance
    PortalConfig(
      id: 'bajus',
      title: 'Bajus Gold & Silver',
      description: 'Live gold & silver prices',
      icon: Icons.monetization_on_rounded,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
      category: PortalCategory.finance,
      baseUrl: 'https://www.bajus.org',
      scrapeUrl: 'https://www.bajus.org/gold-price',
      strategy: ScrapingStrategy.html,
      screenRoute: '/bajus',
      allowBadCertificates: true,
      cssSelectors: {
        'goldRows': '.gold-table tbody tr',
        'silverRows': '.silver-table tbody tr',
        'product': 'h6',
        'description': 'td p',
        'price': '.price',
      },
    ),

    // Bangla news
    PortalConfig(
      id: 'kalerkantho',
      title: 'Kaler Kantho',
      description: 'কালের কণ্ঠ — Latest from RSS',
      icon: Icons.newspaper_rounded,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      category: PortalCategory.bangla,
      baseUrl: 'https://www.kalerkantho.com',
      scrapeUrl: 'https://www.kalerkantho.com/rss.xml',
      strategy: ScrapingStrategy.rss,
      screenRoute: '/kalerkantho',
      rssItemTag: 'item',
    ),
    PortalConfig(
      id: 'prothomalo',
      title: 'Prothom Alo',
      description: 'প্রথম আলো — Top stories',
      icon: Icons.article_rounded,
      gradientColors: [Color(0xFFE51A1B), Color(0xFFC62828)],
      category: PortalCategory.bangla,
      baseUrl: 'https://www.prothomalo.com',
      scrapeUrl: 'https://www.prothomalo.com/api/v1/stories',
      strategy: ScrapingStrategy.restApi,
      screenRoute: '/prothomalo',
      headers: {
        'Accept': 'application/json',
        'User-Agent': AppConstants.userAgent,
      },
    ),
    PortalConfig(
      id: 'banglanews24',
      title: 'Bangla News 24',
      description: 'বাংলানিউজ২৪ — Breaking news',
      icon: Icons.rss_feed_rounded,
      gradientColors: [Color(0xFF1E88E5), Color(0xFF00ACC1)],
      category: PortalCategory.bangla,
      baseUrl: 'https://www.banglanews24.com',
      scrapeUrl: 'https://www.banglanews24.com/',
      strategy: ScrapingStrategy.html,
      screenRoute: '/banglanews24',
      cssSelectors: {
        'latestTab': '#home-tab-pane',
        'popularTab': '#profile-tab-pane',
        'listItem': 'li.list-group-item',
        'link': 'a',
      },
    ),
    PortalConfig(
      id: 'ittefaq',
      title: 'Ittefaq',
      description: 'ইত্তেফাক — Latest news',
      icon: Icons.feed_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
      category: PortalCategory.bangla,
      baseUrl: 'https://www.ittefaq.com.bd',
      scrapeUrl: 'https://www.ittefaq.com.bd/latest-news',
      strategy: ScrapingStrategy.html,
      screenRoute: '/ittefaq',
      allowBadCertificates: true,
      cssSelectors: {
        'infoBlock': 'div.info',
        'title': 'h2.title a.link_overlay, a',
        'description': 'div.summery, p',
      },
    ),
    PortalConfig(
      id: 'tbsnews',
      title: 'TBS News বাংলা',
      description: 'The Business Standard',
      icon: Icons.business_center_rounded,
      gradientColors: [Color(0xFF059669), Color(0xFF065F46)],
      category: PortalCategory.bangla,
      baseUrl: 'https://www.tbsnews.net',
      scrapeUrl: 'https://www.tbsnews.net/bangla',
      strategy: ScrapingStrategy.html,
      screenRoute: '/tbsnews',
      cssSelectors: {
        'card': '.card',
        'title': 'h3 a',
        'description': '.card-section p',
        'date': '.date',
        'image': 'img',
      },
    ),
    PortalConfig(
      id: 'jugantor',
      title: 'Jugantor',
      description: 'যুগান্তর — National & World',
      icon: Icons.public_rounded,
      gradientColors: [Color(0xFF0066CC), Color(0xFF0044AA)],
      category: PortalCategory.bangla,
      baseUrl: 'https://www.jugantor.com',
      scrapeUrl: 'https://www.jugantor.com/news_sitemap.xml',
      strategy: ScrapingStrategy.sitemap,
      screenRoute: '/jugantor',
    ),
    PortalConfig(
      id: 'samakal',
      title: 'Samakal',
      description: 'সমকাল — Current affairs',
      icon: Icons.newspaper_rounded,
      gradientColors: [Color(0xFF00897B), Color(0xFF00695C)],
      category: PortalCategory.bangla,
      baseUrl: 'https://samakal.com',
      scrapeUrl: 'https://samakal.com/latest/news',
      strategy: ScrapingStrategy.html,
      screenRoute: '/samakal',
      cssSelectors: {
        'articleLink': 'a[href*="/article/"]',
      },
    ),
    PortalConfig(
      id: 'manabzamin',
      title: 'Manabzamin',
      description: 'মানবজমিন — In-depth news',
      icon: Icons.article_rounded,
      gradientColors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
      category: PortalCategory.bangla,
      baseUrl: 'https://www.mzamin.com',
      scrapeUrl: 'https://www.mzamin.com',
      strategy: ScrapingStrategy.html,
      screenRoute: '/manabzamin',
      cssSelectors: {
        'articleLink': 'a[href*="/article/"]',
      },
    ),
    PortalConfig(
      id: 'bdnews24',
      title: 'bdnews24',
      description: 'বিডি নিউজ২৪ — Breaking news',
      icon: Icons.rss_feed_rounded,
      gradientColors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
      category: PortalCategory.bangla,
      baseUrl: 'https://bdnews24.com',
      scrapeUrl: 'https://bdnews24.com',
      strategy: ScrapingStrategy.html,
      screenRoute: '/bdnews24',
    ),
    PortalConfig(
      id: 'jagonews24',
      title: 'Jago News 24',
      description: 'যাগো নিউজ২৪ — All news',
      icon: Icons.newspaper_rounded,
      gradientColors: [Color(0xFFE65100), Color(0xFFBF360C)],
      category: PortalCategory.bangla,
      baseUrl: 'https://www.jagonews24.com',
      scrapeUrl: 'https://www.jagonews24.com/all-news',
      strategy: ScrapingStrategy.html,
      screenRoute: '/jagonews24',
    ),
    PortalConfig(
      id: 'somoynews',
      title: 'Somoy News',
      description: 'সময় টিভি — Latest news',
      icon: Icons.play_circle_rounded,
      gradientColors: [Color(0xFFC62828), Color(0xFF8E0000)],
      category: PortalCategory.bangla,
      baseUrl: 'https://www.somoynews.tv',
      scrapeUrl: 'https://www.somoynews.tv/latest-news',
      strategy: ScrapingStrategy.html,
      screenRoute: '/somoynews',
    ),
    PortalConfig(
      id: 'banglatribune',
      title: 'Bangla Tribune',
      description: 'বাংলা ট্রিবিউন — Breaking news',
      icon: Icons.public_rounded,
      gradientColors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
      category: PortalCategory.bangla,
      baseUrl: 'https://www.banglatribune.com',
      scrapeUrl: 'https://www.banglatribune.com/national',
      strategy: ScrapingStrategy.html,
      screenRoute: '/banglatribune',
    ),
    PortalConfig(
      id: 'dhakapost',
      title: 'Dhaka Post',
      description: 'ঢাকা পোস্ট — Latest news',
      icon: Icons.feed_rounded,
      gradientColors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
      category: PortalCategory.bangla,
      baseUrl: 'https://dhakapost.com',
      scrapeUrl: 'https://dhakapost.com',
      strategy: ScrapingStrategy.html,
      screenRoute: '/dhakapost',
    ),
    PortalConfig(
      id: 'dailyinqilab',
      title: 'Daily Inqilab',
      description: 'দৈনিক ইনকিলাব — National news',
      icon: Icons.article_rounded,
      gradientColors: [Color(0xFF00695C), Color(0xFF004D40)],
      category: PortalCategory.bangla,
      baseUrl: 'https://www.dailyinqilab.com',
      scrapeUrl: 'https://www.dailyinqilab.com',
      strategy: ScrapingStrategy.html,
      screenRoute: '/dailyinqilab',
    ),

    // English news
    PortalConfig(
      id: 'dailystar',
      title: 'The Daily Star',
      description: 'English — Top stories',
      icon: Icons.star_rounded,
      gradientColors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
      category: PortalCategory.english,
      baseUrl: 'https://bangla.thedailystar.net',
      scrapeUrl: 'https://bangla.thedailystar.net/news/bangladesh',
      strategy: ScrapingStrategy.html,
      screenRoute: '/dailystar',
      cssSelectors: {
        'articleLink': 'a[href*="/news-"]',
      },
    ),
    PortalConfig(
      id: 'dhakatribune',
      title: 'Dhaka Tribune',
      description: 'English — Bangladesh news',
      icon: Icons.newspaper_rounded,
      gradientColors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
      category: PortalCategory.english,
      baseUrl: 'https://www.dhakatribune.com',
      scrapeUrl: 'https://www.dhakatribune.com/latest',
      strategy: ScrapingStrategy.html,
      screenRoute: '/dhakatribune',
    ),
    PortalConfig(
      id: 'newagebd',
      title: 'New Age',
      description: 'English — National & World',
      icon: Icons.language_rounded,
      gradientColors: [Color(0xFFAD1457), Color(0xFF880E4F)],
      category: PortalCategory.english,
      baseUrl: 'https://newagebd.net',
      scrapeUrl: 'https://newagebd.net',
      strategy: ScrapingStrategy.html,
      screenRoute: '/newagebd',
    ),
  ];

  /// Get portals filtered by category.
  static List<PortalConfig> byCategory(PortalCategory category) {
    if (category == PortalCategory.all) return all;
    return all.where((p) => p.category == category).toList(growable: false);
  }

  /// Find a portal by its ID.
  static PortalConfig? byId(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
