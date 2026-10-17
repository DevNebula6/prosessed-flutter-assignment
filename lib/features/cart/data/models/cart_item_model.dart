import '../../../products/data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel {
  const CartItemModel({required this.product, required this.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(
      product: ProductModel.fromEntity(item.product),
      quantity: item.quantity,
    );
  }

  final ProductModel product;
  final int quantity;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };

  CartItem toEntity() {
    return CartItem(product: product.toEntity(), quantity: quantity);
  }
}
