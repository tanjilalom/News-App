# 📱 Flutter News-App — Project Overview

> **Name:** `web_scraping_with_flutter`  
> **Description:** A news web scraping app that fetches real-time Gold/Silver prices and news from multiple Bangladeshi news portals.  
> **Flutter SDK:** `>=3.5.0 <4.0.0`  
> **Version:** `1.0.0+1`

---

## 📦 Dependencies

| Category | Packages |
|----------|----------|
| **UI & Fonts** | `google_fonts`, `cupertino_icons` |
| **HTTP & Parsing** | `http`, `html` |
| **Utilities** | `intl`, `cached_network_image`, `url_launcher` |
| **Dev** | `flutter_test`, `flutter_lints` |

---

## 🏗️ Architecture

```
lib/
├── main.dart                    # App entry point
├── homepage.dart                # Main navigation screen
├── networks/
│   └── scraper_services.dart   # (Commented out) Shared scraper utilities
└── features/
    └── pages/
        ├── bajus_prices_screen.dart        # Gold/Silver rates from bajus.org
        ├── prothomalo_news_screen.dart     # প্রথম আলো news
        ├── kalerkontho_news_screen.dart    # কালের কণ্ঠ news (RSS)
        ├── banglanews24_news_screen.dart   # বাংলা নিউজ ২৪ (Latest + Popular tabs)
        ├── ittefaq_news_screen.dart        # ইত্তেফাক news
        └── business_standard_news_screen.dart  # TBS News Bangla
```

---

## 🎯 Features

### 1. Home Screen (`HomePage`)
- Lists 6 portal cards with icons and colors
- Fade navigation transitions to each screen

### 2. Bajus Gold & Silver Prices (`bajus_prices_screen.dart`)
- Scrapes `https://www.bajus.org/gold-price`
- Displays gold & silver rates in card format
- Custom HTTP client to bypass SSL validation
- Pull-to-refresh, error handling with retry

### 3. News Screens (5 Portals)

| Screen | Source | Method |
|--------|--------|--------|
| **Prothom Alo** | `prothomalo.com/collection/latest` | HTML Scraping |
| **Kaler Kontho** | `kalerkantho.com/rss.xml` | RSS Parsing |
| **BanglaNews24** | `banglanews24.com/` | HTML Scraping (Tabbed: Latest/Popular) |
| **Ittefaq** | `ittefaq.com.bd/latest-news` | HTML Scraping |
| **TBS News** | `tbsnews.net/bangla` | HTML Scraping (with images) |

---

## 🎨 UI Patterns

- **Consistent Design:** Gradient AppBars, rounded corners, card-based layouts
- **Google Fonts:** `Poppins`, `NotoSansBengali` for Bengali text
- **Error Handling:** Loading states, error UI with retry buttons, snackbars
- **Pull-to-Refresh:** All screens support `RefreshIndicator`
- **External Links:** News articles open in browser via `url_launcher`

---

## ⚠️ Notable Observations

1. **`scraper_services.dart`** is entirely commented out — appears to be legacy/unused code
2. **Inconsistent HTTP clients:** Some screens use standard `http.get()`, others use custom `IOClient` with SSL bypass
3. **Hardcoded URLs** in each screen — no centralized config
4. **No state management** (no Provider, Riverpod, Bloc, etc.) — all local `setState()`
5. **No tests** in the `test/` directory

---

## 🚀 Potential Improvements

- [ ] Centralize scraper service (uncomment & refactor `scraper_services.dart`)
- [ ] Add a centralized config file for URLs and selectors
- [ ] Introduce state management (Provider / Riverpod)
- [ ] Add unit & widget tests
- [ ] Implement offline caching for scraped content
- [ ] Add dark mode support
- [ ] Extract reusable widgets (NewsCard, ErrorWidget, LoadingWidget)
- [ ] Handle rate limiting / request throttling

---

*Generated on: April 11, 2026*
