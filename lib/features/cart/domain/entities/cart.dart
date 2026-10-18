import 'dart:math';

import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product.dart';
import 'cart_item.dart';

/// An immutable cart. Every change returns a new [Cart].
class Cart extends Equatable {
  const Cart([this.items = const []]);

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  /// Total number of units, which is what the badge shows.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  double get total => items.fold(0, (sum, item) => sum + item.total);

  double get discount => subtotal - total;

  int quantityOf(int productId) {
    for (final item in items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  /// Adds [quantity] of [product], merging with an existing line. A line
  /// never goes above the product's stock.
  Cart add(Product product, {int quantity = 1}) {
    if (!product.inStock || quantity <= 0) return this;

    final current = quantityOf(product.id);
    if (current > 0) return updateQuantity(product.id, current + quantity);

    return Cart([
      ...items,
      CartItem(product: product, quantity: min(quantity, product.stock)),
    ]);
  }

  /// Sets the quantity of a line, capped at the stock. Zero removes it.
  Cart updateQuantity(int productId, int quantity) {
    if (quantity <= 0) return remove(productId);

    return Cart([
      for (final item in items)
        if (item.product.id == productId)
          item.copyWith(quantity: min(quantity, item.product.stock))
        else
          item,
    ]);
  }

  Cart remove(int productId) {
    return Cart(items.where((item) => item.product.id != productId).toList());
  }

  @override
  List<Object?> get props => [items];
}
