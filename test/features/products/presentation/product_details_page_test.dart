import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/presentation/widgets/add_to_cart_bar.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_icon.dart';
import 'package:shopsphere/features/products/presentation/pages/product_details_page.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  setUp(registerFakeDependencies);

  testWidgets('a missing product shows a not found state with a way back', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ProductDetailsPage(productId: 9999),
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Product not found'), findsOneWidget);

    await tester.tap(find.text('Back to shop'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailsPage), findsNothing);
  });

  testWidgets('adding to the cart updates the cart badge', (tester) async {
    await pumpTestApp(
      tester,
      ProductDetailsPage(productId: 1, preview: testProduct(1)),
    );

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    await tester.tap(find.text('Add to cart'));
    await tester.pump();

    expect(find.text('Added 2 to your cart'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(CartIcon), matching: find.text('2')),
      findsOneWidget,
    );
  });

  testWidgets('the added-to-cart message stays clear of the button', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      ProductDetailsPage(productId: 1, preview: testProduct(1)),
    );

    await tester.tap(find.text('Add to cart'));
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
    final bar = tester.getRect(find.byType(AddToCartBar));
    expect(snackBar.bottom, lessThanOrEqualTo(bar.top));
  });

  testWidgets('an out of stock product cannot be added', (tester) async {
    await pumpTestApp(
      tester,
      ProductDetailsPage(productId: 7, preview: testProduct(7, stock: 0)),
    );

    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Out of stock'),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
    expect(button.onPressed, isNull);
  });
}
