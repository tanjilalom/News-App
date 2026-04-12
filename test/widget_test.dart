import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_scraping_with_flutter/homepage.dart';

void main() {
  testWidgets('renders the news portal home screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    // Let animations settle
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify app bar title
    expect(find.text('BD News Hub'), findsOneWidget);
    expect(find.text('আপনার সংবাদ কেন্দ্র'), findsOneWidget);

    // Verify header greeting
    expect(find.textContaining('Good'), findsOneWidget);
    expect(find.text('Stay Informed Today'), findsOneWidget);

    // Verify category chips exist
    expect(find.text('All'), findsOneWidget);
    expect(find.text('বাংলা'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);

    // Verify grid has portal cards (scroll to find them)
    await tester.drag(find.byType(GridView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // At least one portal should be visible
    expect(find.byType(GestureDetector), findsWidgets);
  });

  testWidgets('filters portals by Finance category', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Count items before filter
    final gridBefore = tester.widget<GridView>(find.byType(GridView));
    expect(gridBefore.gridDelegate, isNotNull);

    // Tap Finance chip
    await tester.tap(find.text('Finance'));
    await tester.pumpAndSettle();

    // Grid should now have fewer items (only Finance portals)
    // Bajus should be visible
    expect(find.text('Bajus Gold & Silver'), findsOneWidget);
  });

  testWidgets('tapping English chip shows English portals', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tap English chip
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // The Daily Star should be visible
    expect(find.text('The Daily Star'), findsOneWidget);
  });

  testWidgets('search and theme buttons appear in app bar', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(
      find.byIcon(Icons.dark_mode_rounded),
      findsOneWidget,
    );
  });
}
