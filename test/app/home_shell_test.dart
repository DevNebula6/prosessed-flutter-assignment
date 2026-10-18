import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/app/home_shell.dart';

import '../helpers/test_app.dart';

void main() {
  setUp(registerFakeDependencies);

  testWidgets('the rail runs the full height, behind the system bars', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPadding);
    await pumpTestApp(tester, const HomeShell(), size: const Size(1280, 800));

    final rail = tester.getRect(find.byType(NavigationRail));
    expect(rail.top, 0);
    expect(rail.bottom, 800);
  });

  // Rotating across a breakpoint changes the layout around the tabs. The
  // shop should keep what the user was doing, not start over.
  for (final (name, portrait, landscape) in [
    ('phone', const Size(412, 915), const Size(915, 412)),
    ('tablet', const Size(800, 1280), const Size(1280, 800)),
  ]) {
    testWidgets('rotating a $name keeps the search', (tester) async {
      await pumpTestApp(tester, const HomeShell(), size: portrait);
      await tester.enterText(find.byType(TextField), 'phone');
      await tester.pump(const Duration(milliseconds: 500));

      tester.view.physicalSize = landscape;
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('phone'), findsOneWidget);
    });
  }
}
