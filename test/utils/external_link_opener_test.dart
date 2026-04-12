import 'package:flutter_test/flutter_test.dart';
import 'package:web_scraping_with_flutter/core/utils/external_link_opener.dart';

void main() {
  group('normalizeExternalUrl', () {
    test('returns null for empty string', () {
      expect(normalizeExternalUrl(''), isNull);
    });

    test('returns null for whitespace-only string', () {
      expect(normalizeExternalUrl('   '), isNull);
    });

    test('preserves absolute URLs with scheme', () {
      expect(
        normalizeExternalUrl('https://example.com/article/123'),
        'https://example.com/article/123',
      );
    });

    test('resolves relative URLs against base URL', () {
      expect(
        normalizeExternalUrl('/article/123', baseUrl: 'https://example.com'),
        'https://example.com/article/123',
      );
    });

    test('resolves relative URLs with query params', () {
      expect(
        normalizeExternalUrl('/news?id=42', baseUrl: 'https://example.com'),
        'https://example.com/news?id=42',
      );
    });

    test('returns null for relative URL without base URL', () {
      expect(normalizeExternalUrl('/article/123'), isNull);
    });

    test('handles http scheme', () {
      expect(
        normalizeExternalUrl('http://example.com'),
        'http://example.com',
      );
    });

    test('trims whitespace from URL', () {
      expect(
        normalizeExternalUrl('  https://example.com  '),
        'https://example.com',
      );
    });
  });
}
