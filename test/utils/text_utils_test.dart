import 'package:flutter_test/flutter_test.dart';
import 'package:web_scraping_with_flutter/core/utils/text_utils.dart';

void main() {
  group('TextUtils.cleanText', () {
    test('trims leading and trailing whitespace', () {
      expect(TextUtils.cleanText('  hello  '), 'hello');
    });

    test('collapses multiple spaces into one', () {
      expect(TextUtils.cleanText('hello    world'), 'hello world');
    });

    test('handles tabs and newlines', () {
      expect(TextUtils.cleanText('hello\n\t  world'), 'hello world');
    });

    test('returns empty string for whitespace-only input', () {
      expect(TextUtils.cleanText('   \n\t  '), '');
    });

    test('handles empty string', () {
      expect(TextUtils.cleanText(''), '');
    });

    test('preserves single spaces between words', () {
      expect(TextUtils.cleanText('The quick brown fox'), 'The quick brown fox');
    });
  });

  group('TextUtils.formatTimestamp', () {
    test('formats morning time correctly', () {
      final dt = DateTime(2026, 4, 12, 9, 30);
      final result = TextUtils.formatTimestamp(dt);
      expect(result, 'Apr 12, 9:30 AM');
    });

    test('formats afternoon time correctly', () {
      final dt = DateTime(2026, 4, 12, 14, 5);
      final result = TextUtils.formatTimestamp(dt);
      expect(result, 'Apr 12, 2:05 PM');
    });

    test('formats midnight as 12:00 AM', () {
      final dt = DateTime(2026, 1, 1, 0, 0);
      final result = TextUtils.formatTimestamp(dt);
      expect(result, 'Jan 1, 12:00 AM');
    });

    test('formats noon as 12:00 PM', () {
      final dt = DateTime(2026, 6, 15, 12, 0);
      final result = TextUtils.formatTimestamp(dt);
      expect(result, 'Jun 15, 12:00 PM');
    });

    test('pads minutes with leading zero', () {
      final dt = DateTime(2026, 3, 5, 18, 3);
      final result = TextUtils.formatTimestamp(dt);
      expect(result, 'Mar 5, 6:03 PM');
    });
  });
}
