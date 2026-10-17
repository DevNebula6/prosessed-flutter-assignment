import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  /// Before discount.
  double get subtotal => product.price * quantity;

  /// After discount.
  double get total => product.discountedPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  @override
  List<Object?> get props => [product, quantity];
}
