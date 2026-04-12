import 'package:flutter_test/flutter_test.dart';
import 'package:web_scraping_with_flutter/core/models/news_item.dart';

void main() {
  group('NewsItem', () {
    test('creates with required fields only', () {
      const item = NewsItem(title: 'Test Title', url: 'https://example.com');

      expect(item.title, 'Test Title');
      expect(item.url, 'https://example.com');
      expect(item.time, '');
      expect(item.category, '');
      expect(item.imageUrl, '');
      expect(item.isPopular, false);
      expect(item.description, '');
    });

    test('creates with all fields', () {
      const item = NewsItem(
        title: 'Breaking News',
        url: 'https://example.com/news/1',
        time: 'Apr 12, 2:30 PM',
        category: 'Politics',
        imageUrl: 'https://example.com/img.jpg',
        isPopular: true,
        description: 'A detailed description',
      );

      expect(item.title, 'Breaking News');
      expect(item.url, 'https://example.com/news/1');
      expect(item.time, 'Apr 12, 2:30 PM');
      expect(item.category, 'Politics');
      expect(item.imageUrl, 'https://example.com/img.jpg');
      expect(item.isPopular, true);
      expect(item.description, 'A detailed description');
    });

    group('copyWith', () {
      test('returns identical object when no args provided', () {
        const original = NewsItem(title: 'Title', url: 'https://example.com');
        final copy = original.copyWith();

        expect(copy.title, original.title);
        expect(copy.url, original.url);
        expect(copy.time, original.time);
        expect(copy.category, original.category);
        expect(copy.imageUrl, original.imageUrl);
        expect(copy.isPopular, original.isPopular);
        expect(copy.description, original.description);
      });

      test('updates specified fields', () {
        const original = NewsItem(title: 'Title', url: 'https://example.com');
        final copy = original.copyWith(
          title: 'Updated Title',
          isPopular: true,
          category: 'Sports',
        );

        expect(copy.title, 'Updated Title');
        expect(copy.url, original.url);
        expect(copy.isPopular, true);
        expect(copy.category, 'Sports');
        expect(copy.time, original.time);
      });

      test('can set isPopular to false', () {
        const original = NewsItem(
          title: 'Title',
          url: 'https://example.com',
          isPopular: true,
        );
        final copy = original.copyWith(isPopular: false);
        expect(copy.isPopular, false);
      });

      test('can set fields to empty strings', () {
        const original = NewsItem(
          title: 'Title',
          url: 'https://example.com',
          category: 'Politics',
        );
        final copy = original.copyWith(category: '');
        expect(copy.category, '');
      });
    });
  });
}
