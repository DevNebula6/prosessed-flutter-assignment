import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
