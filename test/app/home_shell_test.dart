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
}
