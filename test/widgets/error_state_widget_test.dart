import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_scraping_with_flutter/core/widgets/error_state_widget.dart';

void main() {
  group('ErrorStateWidget', () {
    Widget _buildErrorState({VoidCallback? onRetry}) {
      return MaterialApp(
        home: Scaffold(
          body: ErrorStateWidget(
            onRetry: onRetry ?? () {},
          ),
        ),
      );
    }

    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(_buildErrorState());
      expect(find.text('Failed to load news'), findsOneWidget);
    });

    testWidgets('displays subtitle', (tester) async {
      await tester.pumpWidget(_buildErrorState());
      expect(
        find.text('Please check your connection and try again.'),
        findsOneWidget,
      );
    });

    testWidgets('displays Try Again button', (tester) async {
      await tester.pumpWidget(_buildErrorState());
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('displays wifi_off icon', (tester) async {
      await tester.pumpWidget(_buildErrorState());
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('triggers onRetry when Try Again is tapped', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(
              onRetry: () => retried = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });

    testWidgets('displays custom message when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(
              onRetry: () {},
              message: 'Custom error message',
            ),
          ),
        ),
      );
      expect(find.text('Custom error message'), findsOneWidget);
      expect(find.text('Failed to load news'), findsNothing);
    });
  });
}
