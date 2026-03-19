import 'package:flutter_test/flutter_test.dart';
import 'package:web_scraping_with_flutter/main.dart';

void main() {
  testWidgets('renders the news portal home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('News Portals'), findsOneWidget);
    expect(find.text('Explore News Sources'), findsOneWidget);
    expect(find.text('Prothom Alo News'), findsOneWidget);
  });
}
