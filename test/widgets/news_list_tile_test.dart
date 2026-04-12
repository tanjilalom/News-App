import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_scraping_with_flutter/core/models/news_item.dart';
import 'package:web_scraping_with_flutter/core/widgets/news_list_tile.dart';

void main() {
  group('NewsListTile', () {
    const _testItem = NewsItem(
      title: 'Test Article Title',
      url: 'https://example.com/article/1',
      time: 'Apr 12, 2:30 PM',
      category: 'Politics',
    );

    Widget _buildTile({VoidCallback? onTap}) {
      return MaterialApp(
        home: Scaffold(
          body: NewsListTile(
            item: _testItem,
            onTap: onTap ?? () {},
            accentColor: const Color(0xFF3366FF),
          ),
        ),
      );
    }

    testWidgets('displays the article title', (tester) async {
      await tester.pumpWidget(_buildTile());
      expect(find.text('Test Article Title'), findsOneWidget);
    });

    testWidgets('displays the category chip when category is set',
        (tester) async {
      await tester.pumpWidget(_buildTile());
      expect(find.text('Politics'), findsOneWidget);
    });

    testWidgets('displays the timestamp', (tester) async {
      await tester.pumpWidget(_buildTile());
      expect(find.text('Apr 12, 2:30 PM'), findsOneWidget);
    });

    testWidgets('displays Read button', (tester) async {
      await tester.pumpWidget(_buildTile());
      expect(find.text('Read'), findsOneWidget);
    });

    testWidgets('does not show category chip when category is empty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsListTile(
              item: const NewsItem(title: 'Title', url: 'https://example.com'),
              onTap: () {},
            ),
          ),
        ),
      );
      // "Politics" should not appear
      expect(find.text('Politics'), findsNothing);
    });

    testWidgets('does not show share button when onShare is null',
        (tester) async {
      await tester.pumpWidget(_buildTile());
      expect(find.byIcon(Icons.share_rounded), findsNothing);
    });

    testWidgets('shows share button when onShare is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsListTile(
              item: _testItem,
              onTap: () {},
              onShare: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
    });

    testWidgets('shows Popular badge when isPopular is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsListTile(
              item: const NewsItem(
                title: 'Title',
                url: 'https://example.com',
                isPopular: true,
              ),
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('Popular'), findsOneWidget);
    });

    testWidgets('triggers onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsListTile(
              item: _testItem,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Test Article Title'));
      expect(tapped, isTrue);
    });
  });
}
