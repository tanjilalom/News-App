# Changelog

All notable changes to **BD News Hub** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Planned (Next Steps)
- [ ] Bookmark/favorite articles with Hive storage
- [ ] Infinite scroll / pagination for all portals
- [ ] Portal-specific search (filter by source)
- [ ] Push notifications for breaking news
- [ ] Share article as image card
- [ ] Web platform support
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Firebase Crashlytics / Sentry integration
- [ ] Rate limiting per portal (configurable)
- [ ] Analytics dashboard (most-read articles)
- [ ] Accessibility improvements (screen reader, font scaling)

---

## [2.0.0] - 2026-04-12

### 🎉 Major Refactoring — From Tutorial Project to Portfolio App

#### Added
- **8 new news portals** (total: 18)
  - Bangla: bdnews24, Jago News 24, Somoy News, Bangla Tribune, Dhaka Post, Daily Inqilab
  - English: Dhaka Tribune, New Age
- **Cross-portal search** — search across all 18 portals with live progress indicators
- **Dark mode** — full light/dark theme with `ThemeMode.system` default
- **Offline caching** — Hive-based 30-minute TTL cache (`CacheService`)
- **Share articles** — `share_plus` integration on every article card
- **61 passing tests** (37 unit + 24 widget)
  - `test/utils/text_utils_test.dart` — TextUtils
  - `test/utils/external_link_opener_test.dart` — URL normalization
  - `test/models/news_item_test.dart` — NewsItem model + copyWith
  - `test/config/portal_config_test.dart` — Portal config validation
  - `test/widgets/news_list_tile_test.dart` — Shared card widget
  - `test/widgets/error_state_widget_test.dart` — Error UI
  - `test/widget_test.dart` — HomePage integration tests

#### Architecture
- **Riverpod state management** (`flutter_riverpod` 2.6)
  - `NewsNotifier` — per-portal news fetching state
  - `SearchNotifier` — cross-portal search state
  - `themeModeProvider` — light/dark toggle
- **Centralized portal config** (`lib/core/config/portals.dart`)
  - All URLs, colors, icons, CSS selectors in one file
  - `ScrapingStrategy` enum (HTML / RSS / REST API / Sitemap)
- **Centralized scraper service** (`lib/core/services/news_scraper.dart`)
  - 20+ parsing strategies — one per portal
  - Automatic strategy routing based on portal config
- **Shared widget library**
  - `NewsListTile` — unified news card (replaces ~400 lines of duplication)
  - `ShimmerLoader` — animated skeleton loading
  - `UpdatedChip` — consistent timestamp display
  - `PortalAppBar` — gradient app bar with curved bottom
  - `ErrorStateWidget` — error UI with retry

#### Changed
- Migrated from `setState()` to Riverpod
- All 10 original screens refactored to use `NewsListTile`
- Theme now accepts `ThemeMode` parameter for light/dark
- `LoadingShimmerWidget` → `ShimmerLoader` (renamed + enhanced)
- `HomePage` now uses centralized `PortalRegistry` config

#### Dependencies Added
- `flutter_riverpod` 2.6.1 — state management
- `hive` 2.2.3 + `hive_flutter` 1.1.0 — offline storage
- `share_plus` 10.1.4 — article sharing
- `collection` 1.18.0 — utility functions
- `build_runner` 2.4.14 + `riverpod_generator` 2.4.0 — code generation

#### Dependencies Removed
- Removed unused `win32` dependency

---

## [1.0.0] - Initial Release

### Added
- 10 news portals with web scraping
  - Bajus (Gold/Silver prices)
  - Prothom Alo (REST API)
  - Kaler Kantho (RSS)
  - BanglaNews24, Ittefaq, TBS News, Jugantor, Samakal, Manabzamin, The Daily Star
- Category filtering (All / বাংলা / English / Finance)
- Pull-to-refresh on all screens
- Gradient portal cards with animations
- Basic error handling with retry

### Tech Stack
- `http` + `html` — web scraping
- `google_fonts` — Poppins + NotoSansBengali
- `cached_network_image` — image caching
- `url_launcher` — external links
- `intl` — date formatting

---

## Version History Summary

| Version | Date | Portals | Key Feature |
|---------|------|---------|-------------|
| 1.0.0 | - | 10 | Initial scraping app |
| 2.0.0 | 2026-04-12 | 18 | Riverpod, Hive, search, dark mode, tests |
| Unreleased | - | 18 | Bookmarks, pagination, push notifications |

---

*Current Branch Status: ✅ Zero errors, 0 warnings, 61 tests passing*
