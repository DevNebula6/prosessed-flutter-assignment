import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/data/models/cart_item_model.dart';
import 'package:shopsphere/features/cart/data/models/order_model.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/entities/order.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

import '../../../../helpers/fixture_reader.dart';

void main() {
  test('parses the order from a carts/add response', () {
    final json = fixture('cart_add_response.json') as Map<String, dynamic>;

    expect(
      OrderModel.fromJson(json).toEntity(),
      const Order(id: 209, totalQuantity: 2),
    );
  });

  test('a cart item survives a save and load round trip', () {
    const item = CartItem(
      product: Product(
        id: 16,
        title: 'Apple',
        category: 'groceries',
        price: 1.99,
        discountPercentage: 12.62,
        rating: 4.19,
        stock: 8,
        thumbnail: 'thumbnail.webp',
      ),
      quantity: 3,
    );

    final json = CartItemModel.fromEntity(item).toJson();
    final restored = CartItemModel.fromJson(json).toEntity();

    expect(restored, item);
    expect(json['product'], isNot(contains('brand')));
  });
}
