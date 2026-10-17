import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

Product product(
  int id, {
  double price = 100,
  double discount = 0,
  int stock = 10,
}) {
  return Product(
    id: id,
    title: 'Product $id',
    category: 'beauty',
    price: price,
    discountPercentage: discount,
    rating: 4,
    stock: stock,
    thumbnail: 'thumbnail.webp',
  );
}

void main() {
  group('add', () {
    test('adds a new line', () {
      final cart = const Cart().add(product(1), quantity: 2);

      expect(cart.items, hasLength(1));
      expect(cart.quantityOf(1), 2);
    });

    test('merges into an existing line', () {
      final cart = const Cart().add(product(1)).add(product(1), quantity: 3);

      expect(cart.items, hasLength(1));
      expect(cart.quantityOf(1), 4);
    });

    test('never goes above the stock', () {
      final cart = const Cart()
          .add(product(1, stock: 3), quantity: 2)
          .add(product(1, stock: 3), quantity: 2);

      expect(cart.quantityOf(1), 3);
    });

    test('ignores products that are out of stock', () {
      final cart = const Cart().add(product(1, stock: 0));

      expect(cart.isEmpty, isTrue);
    });
  });

  group('updateQuantity', () {
    test('changes the quantity of a line', () {
      final cart = const Cart().add(product(1)).updateQuantity(1, 5);

      expect(cart.quantityOf(1), 5);
    });

    test('removes the line when set to zero', () {
      final cart = const Cart().add(product(1)).updateQuantity(1, 0);

      expect(cart.isEmpty, isTrue);
    });
  });

  test('remove drops only the matching line', () {
    final cart = const Cart().add(product(1)).add(product(2)).remove(1);

    expect(cart.items.single.product.id, 2);
  });

  test('works out the item count, subtotal, discount and total', () {
    final cart = const Cart()
        .add(product(1, price: 100, discount: 10), quantity: 2)
        .add(product(2, price: 50), quantity: 1);

    expect(cart.itemCount, 3);
    expect(cart.subtotal, 250);
    expect(cart.discount, closeTo(20, 0.001));
    expect(cart.total, closeTo(230, 0.001));
  });

  test('an empty cart adds up to zero', () {
    const cart = Cart();

    expect(cart.itemCount, 0);
    expect(cart.total, 0);
    expect(cart.discount, 0);
  });
}
