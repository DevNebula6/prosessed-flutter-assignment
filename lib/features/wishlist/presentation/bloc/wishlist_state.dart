part of 'wishlist_bloc.dart';

final class WishlistState extends Equatable {
  const WishlistState([this.products = const []]);

  /// Newest first.
  final List<Product> products;

  bool contains(int productId) {
    return products.any((product) => product.id == productId);
  }

  @override
  List<Object?> get props => [products];
}
