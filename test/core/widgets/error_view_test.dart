import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/widgets/error_view.dart';

void main() {
  Future<void> pumpErrorView(
    WidgetTester tester,
    Failure failure, {
    VoidCallback? onRetry,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(failure: failure, onRetry: onRetry ?? () {}),
        ),
      ),
    );
  }

  testWidgets('explains an offline error and retries on tap', (tester) async {
    var retries = 0;
    await pumpErrorView(
      tester,
      const NetworkFailure(),
      onRetry: () => retries++,
    );

    expect(find.text("You're offline"), findsOneWidget);
    expect(find.text(const NetworkFailure().message), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('falls back to a general title for server errors', (
    tester,
  ) async {
    await pumpErrorView(tester, const ServerFailure(500));

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
  });
}
