import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/app/home_shell.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/presentation/pages/cart_page.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  setUp(
    () => registerFakeDependencies(
      cart: const Cart().add(testProduct(1)).add(testProduct(2)),
    ),
  );

  testWidgets('the removed message on the cart tab stays clear of checkout', (
    tester,
  ) async {
    await pumpTestApp(tester, const HomeShell());
    await tester.tap(find.text('Cart').last);
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byTooltip('Remove').first);
    await tester.pump(const Duration(seconds: 1));

    // The visible card, not the SnackBar box, which also spans its margin.
    final snackBar = tester.getRect(
      find
          .descendant(
            of: find.byType(SnackBar),
            matching: find.byType(Material),
          )
          .first,
    );
    final button = tester.getRect(
      find.ancestor(
        of: find.text('Place order'),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
    expect(snackBar.bottom, lessThanOrEqualTo(button.top));
  });

  testWidgets('a single unit reads as one item', (tester) async {
    await registerFakeDependencies(cart: const Cart().add(testProduct(1)));
    await pumpTestApp(tester, const CartPage());

    expect(find.text('Subtotal (1 item)'), findsOneWidget);
  });
}
