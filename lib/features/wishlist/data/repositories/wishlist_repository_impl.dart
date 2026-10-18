import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_local_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(this._local);

  final WishlistLocalDataSource _local;

  @override
  List<Product> loadWishlist() {
    try {
      return _local.getProducts().map((model) => model.toEntity()).toList();
    } catch (_) {
      // Same as the cart: an unreadable list just starts over empty.
      return const [];
    }
  }

  @override
  Future<void> saveWishlist(List<Product> products) {
    return _local.saveProducts(products.map(ProductModel.fromEntity).toList());
  }
}
