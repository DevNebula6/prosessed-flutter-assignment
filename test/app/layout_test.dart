import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/app/home_shell.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/order.dart';
import 'package:shopsphere/features/cart/presentation/pages/order_success_page.dart';
import 'package:shopsphere/features/products/presentation/pages/product_details_page.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

// Every main screen, on the screen sizes the app supports and with the
// system font scaled up to 1.3x. A layout overflow fails the test, and so do
// small or unlabelled tap targets and text without enough contrast.

const _setups = [
  (name: 'small phone', size: Size(360, 740), theme: ThemeMode.light),
  (
    name: 'small phone in dark mode',
    size: Size(360, 740),
    theme: ThemeMode.dark,
  ),
  (name: 'phone in landscape', size: Size(740, 360), theme: ThemeMode.light),
  (name: 'tablet', size: Size(800, 1280), theme: ThemeMode.light),
  (name: 'tablet in landscape', size: Size(1280, 800), theme: ThemeMode.light),
];

Future<void> _expectAccessible(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  // Something in the cart and wishlist, so those tabs show their full layout.
  setUp(
    () => registerFakeDependencies(
      cart: const Cart().add(testProduct(1), quantity: 2).add(testProduct(2)),
      wishlist: [testProduct(3), testProduct(4)],
    ),
  );

  for (final setup in _setups) {
    Future<void> pump(WidgetTester tester, Widget home) {
      return pumpTestApp(
        tester,
        home,
        size: setup.size,
        textScale: 1.3,
        themeMode: setup.theme,
      );
    }

    group('${setup.name} at 1.3x text:', () {
      testWidgets('login', (tester) async {
        await pump(tester, const LoginPage());
        await _expectAccessible(tester);
      });

      for (final tab in ['Shop', 'Wishlist', 'Cart', 'Profile']) {
        testWidgets('$tab tab', (tester) async {
          await pump(tester, const HomeShell());
          await tester.tap(find.text(tab).last);
          await tester.pump(const Duration(milliseconds: 500));
          await _expectAccessible(tester);
        });
      }

      testWidgets('product details', (tester) async {
        await pump(
          tester,
          ProductDetailsPage(productId: 1, preview: testProduct(1)),
        );
        await _expectAccessible(tester);
      });

      testWidgets('order confirmation', (tester) async {
        await pump(
          tester,
          const OrderSuccessPage(
            order: Order(id: 209, totalQuantity: 3),
            total: 58.54,
          ),
        );
        await _expectAccessible(tester);
      });
    });
  }
}
