import '../../../products/domain/entities/product.dart';

abstract interface class WishlistRepository {
  /// Saved products, newest first. Empty when nothing usable was saved.
  List<Product> loadWishlist();

  Future<void> saveWishlist(List<Product> products);
}
