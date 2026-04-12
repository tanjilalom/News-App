import 'package:flutter_test/flutter_test.dart';
import 'package:web_scraping_with_flutter/core/config/portals.dart';

void main() {
  group('PortalConfig', () {
    test('all portals have non-empty IDs', () {
      for (final portal in PortalRegistry.all) {
        expect(portal.id, isNotEmpty, reason: 'Portal ID should not be empty');
      }
    });

    test('all portal IDs are unique', () {
      final ids = PortalRegistry.all.map((p) => p.id).toList();
      expect(ids.length, ids.toSet().length,
          reason: 'All portal IDs must be unique');
    });

    test('all portals have non-empty titles', () {
      for (final portal in PortalRegistry.all) {
        expect(portal.title, isNotEmpty,
            reason: '${portal.id} title should not be empty');
      }
    });

    test('all portals have non-empty base URLs', () {
      for (final portal in PortalRegistry.all) {
        expect(portal.baseUrl, isNotEmpty,
            reason: '${portal.id} baseUrl should not be empty');
      }
    });

    test('all portals have non-empty scrape URLs', () {
      for (final portal in PortalRegistry.all) {
        expect(portal.scrapeUrl, isNotEmpty,
            reason: '${portal.id} scrapeUrl should not be empty');
      }
    });

    test('all portal base URLs start with https://', () {
      for (final portal in PortalRegistry.all) {
        expect(portal.baseUrl.startsWith('https://'), isTrue,
            reason: '${portal.id} baseUrl should use HTTPS');
      }
    });

    test('bajus portal has SSL bypass enabled', () {
      final bajus = PortalRegistry.byId('bajus');
      expect(bajus, isNotNull);
      expect(bajus!.allowBadCertificates, isTrue);
    });

    test('ittefaq portal has SSL bypass enabled', () {
      final ittefaq = PortalRegistry.byId('ittefaq');
      expect(ittefaq, isNotNull);
      expect(ittefaq!.allowBadCertificates, isTrue);
    });
  });

  group('PortalRegistry', () {
    test('returns all portals for "all" category', () {
      final result = PortalRegistry.byCategory(PortalCategory.all);
      expect(result.length, PortalRegistry.all.length);
    });

    test('filters Bangla portals correctly', () {
      final result = PortalRegistry.byCategory(PortalCategory.bangla);
      expect(result.isNotEmpty, isTrue);
      for (final portal in result) {
        expect(portal.category, PortalCategory.bangla);
      }
    });

    test('filters English portals correctly', () {
      final result = PortalRegistry.byCategory(PortalCategory.english);
      expect(result.isNotEmpty, isTrue);
      for (final portal in result) {
        expect(portal.category, PortalCategory.english);
      }
    });

    test('filters Finance portals correctly', () {
      final result = PortalRegistry.byCategory(PortalCategory.finance);
      expect(result.isNotEmpty, isTrue);
      for (final portal in result) {
        expect(portal.category, PortalCategory.finance);
      }
    });

    test('byId returns null for unknown ID', () {
      expect(PortalRegistry.byId('nonexistent'), isNull);
    });

    test('byId finds existing portal', () {
      final portal = PortalRegistry.byId('prothomalo');
      expect(portal, isNotNull);
      expect(portal!.title, contains('Prothom Alo'));
    });
  });

  group('PortalCategory', () {
    test('has exactly 4 values', () {
      expect(PortalCategory.values.length, 4);
    });

    test('all categories have non-empty labels', () {
      for (final cat in PortalCategory.values) {
        expect(cat.label, isNotEmpty);
      }
    });

    test('all categories have icons', () {
      for (final cat in PortalCategory.values) {
        expect(cat.icon, isNotNull);
      }
    });
  });
}
