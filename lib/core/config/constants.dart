/// App-wide constants.
class AppConstants {
  AppConstants._();

  // Timeouts
  static const httpTimeout = Duration(seconds: 20);
  static const refreshCooldown = Duration(seconds: 5);

  // Pagination
  static const defaultPageSize = 20;
  static const maxArticlesPerPortal = 40;

  // Cache
  static const cacheExpiry = Duration(minutes: 30);

  // User agent
  static const userAgent =
      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 '
      'Chrome/120 Mobile Safari/537.36';

  // App
  static const appName = 'BD News Hub';
  static const appVersion = '2.0.0';
}
