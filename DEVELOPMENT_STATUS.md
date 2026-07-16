# 📋 Development Status — BD News Hub v2.0.0

> **Last Updated:** April 12, 2026
> **Branch Status:** ✅ Clean — 0 errors, 0 warnings, 61 tests passing
> **Current Version:** 2.0.0+1

---

## ✅ Completed (Shipped)

| Feature | Status | Files |
|---------|--------|-------|
| **18 Portal Scraping** | ✅ Done | `lib/core/config/portals.dart`, `lib/core/services/news_scraper.dart` |
| **Riverpod State Mgmt** | ✅ Done | `lib/features/providers/news_providers.dart` |
| **Hive Offline Cache** | ✅ Done | `lib/core/services/cache_service.dart` |
| **Dark Mode** | ✅ Done | `lib/core/theme/app_theme.dart` |
| **Cross-Portal Search** | ✅ Done | `lib/features/search_screen.dart` |
| **Shared NewsListTile** | ✅ Done | `lib/core/widgets/news_list_tile.dart` |
| **Centralized Config** | ✅ Done | `lib/core/config/portals.dart`, `lib/core/config/constants.dart` |
| **61 Tests** | ✅ All pass | `test/` directory (7 test files) |
| **Portfolio README** | ✅ Done | `README.md`, `CHANGELOG.md` |

### Portal Breakdown (18 total)

**Bangla (14):**
Prothom Alo, Kaler Kantho, BanglaNews24, Ittefaq, TBS News, Jugantor, Samakal, Manabzamin, bdnews24, Jago News 24, Somoy News, Bangla Tribune, Dhaka Post, Daily Inqilab

**English (3):**
The Daily Star (Bangla section), Dhaka Tribune, New Age

**Finance (1):**
Bajus (Gold/Silver rates)

---

## 🔄 In Progress / Not Started

### High Priority (Do Next)
- [ ] **Bookmark Articles** — Save favorites to Hive
  - Add `isBookmarked` field to `NewsItem`
  - Create `BookmarkService` (Hive box: `bookmarks`)
  - Bookmark icon on `NewsListTile`
  - Bookmark screen in bottom nav or drawer
- [ ] **Infinite Scroll / Pagination**
  - Track `page` in `NewsState`
  - `fetchMore()` method on `NewsNotifier`
  - Paginated API calls or HTML page traversal
- [ ] **Portal-Specific Search**
  - Add search bar inside individual portal screens
  - Filter cached articles by keyword

### Medium Priority
- [ ] **Push Notifications** — `workmanager` + `flutter_local_notifications`
  - Periodic background scraping (every 30 min)
  - Notify on new articles matching keywords
- [ ] **Share as Image Card** — `screenshot` + `share_plus`
  - Render article as styled widget → PNG → share
- [ ] **CI/CD Pipeline** — GitHub Actions
  - `flutter analyze` + `flutter test` on every PR
  - Auto-build APK on `main` branch push
- [ ] **Error Monitoring** — Firebase Crashlytics or Sentry
  - Catch runtime errors in production
  - Track scraping failures per portal

### Low Priority (Nice to Have)
- [ ] **Web Platform** — `flutter build web`
  - Ensure responsive layout for desktop
- [ ] **Accessibility** — Screen reader, semantic labels, font scaling
- [ ] **Analytics** — Most-read articles, most-used portals
- [ ] **Rate Limiting** — Configurable cooldown per portal
- [ ] **Custom Themes** — Multiple color schemes (blue, green, purple)
- [ ] **Article Caching Preview** — Show cached article body offline

---

## 🏗️ Architecture Reference

```
lib/
├── main.dart                          # ProviderScope + Hive.init + MaterialApp
├── homepage.dart                      # Portal grid + category chips + search/theme buttons
│
├── core/
│   ├── config/
│   │   ├── constants.dart             # Timeouts, pagination, cache TTL, user-agent
│   │   └── portals.dart               # 18 PortalConfig entries + registry methods
│   │
│   ├── models/
│   │   └── news_item.dart             # Immutable article data + copyWith
│   │
│   ├── services/
│   │   ├── cache_service.dart          # Hive cache (30-min TTL)
│   │   └── news_scraper.dart          # 20+ parsing strategies, strategy routing
│   │
│   ├── theme/
│   │   └── app_theme.dart             # Light + dark Material 3 themes
│   │
│   ├── utils/
│   │   ├── app_http_client.dart       # HTTP client factory
│   │   ├── external_link_opener.dart  # URL normalization
│   │   └── text_utils.dart            # cleanText() + formatTimestamp()
│   │
│   └── widgets/
│       ├── news_list_tile.dart        # Unified news card + share
│       ├── shimmer_loader.dart        # Skeleton loading + UpdatedChip
│       ├── portal_app_bar.dart        # Gradient app bar
│       └── error_state_widget.dart    # Error UI with retry
│
└── features/
    ├── providers/
    │   └── news_providers.dart        # NewsNotifier, SearchNotifier, themeModeProvider
    │
    ├── pages/                         # 18 screen files
    │   ├── bajus_prices_screen.dart
    │   ├── prothomalo_news_screen.dart
    │   ├── kalerkontho_news_screen.dart
    │   ├── banglanews24_news_screen.dart
    │   ├── ittefaq_news_screen.dart
    │   ├── business_standard_news_screen.dart
    │   ├── daily_star_news_screen.dart
    │   ├── jugantor_news_screen.dart
    │   ├── samakal_news_screen.dart
    │   ├── manabzamin_news_screen.dart
    │   ├── bdnews24_news_screen.dart          # NEW
    │   ├── jagonews24_news_screen.dart        # NEW
    │   ├── somoynews_news_screen.dart         # NEW
    │   ├── banglatribune_news_screen.dart     # NEW
    │   ├── dhakapost_news_screen.dart         # NEW
    │   ├── dailyinqilab_news_screen.dart      # NEW
    │   ├── dhakatribune_news_screen.dart      # NEW
    │   └── newagebd_news_screen.dart          # NEW
    │
    └── search_screen.dart             # Cross-portal search UI
```

---

## 🔧 How to Continue

### Adding a New Portal
1. Add `PortalConfig` entry to `lib/core/config/portals.dart`
2. Add parsing method in `lib/core/services/news_scraper.dart` (follow `_parseBdnews24` pattern)
3. Add case to switch statement in `scrapePortal()` method
4. Create screen file in `lib/features/pages/` (follow `bdnews24_news_screen.dart` pattern)
5. Register in `_pageBuilders` map in `lib/homepage.dart`
6. Run `flutter analyze` + `flutter test`

### Running the Project
```bash
flutter pub get
flutter run
```

### Running Tests
```bash
flutter test
flutter test --coverage           # with coverage
flutter test test/models/         # specific directory
```

### Building for Release
```bash
flutter build apk --release
flutter build appbundle --release
```

---

## ⚠️ Known Issues / Technical Debt

1. **Scraping fragility** — All CSS selectors are hardcoded. If a site changes structure, that screen breaks silently. Consider adding a selector validation step or health check.
2. **No pagination** — Each portal fetches 30-40 articles max. Users can't load more.
3. **Search is sequential** — Search queries portals one-by-one. Could be parallelized for speed (but risks IP bans).
4. **Hive cache is global** — No per-user or per-session isolation. Fine for single-user app.
5. **Riverpod providers are basic** — `NewsNotifier` could be enhanced with `family` + `autoDispose` for better memory management.
6. **Test coverage gaps** — No tests for actual scraping logic (requires mocking HTTP responses).

---

## 📊 Key Metrics

| Metric | Value |
|--------|-------|
| **Total Dart files** | ~35 |
| **Test files** | 7 |
| **Tests passing** | 61/61 |
| **Analysis issues** | 0 errors, 0 warnings |
| **Dependencies** | 14 production + 5 dev |
| **Code duplication** | Minimal (shared widgets) |

---

*This document should be updated at the end of each development session.*
