import '../../../../core/error/result.dart';
import '../entities/product.dart';
import '../entities/product_category.dart';
import '../entities/product_sort.dart';
import '../entities/products_page.dart';

abstract interface class ProductRepository {
  /// A search [query] takes priority over [category]; the API can't combine
  /// the two.
  Future<Result<ProductsPage>> getProducts({
    String query = '',
    String? category,
    ProductSort sort = ProductSort.relevance,
    int skip = 0,
    int limit = 20,
  });

  /// The full product, with images and reviews. Fails with
  /// `NotFoundFailure` when no product has this [id].
  Future<Result<Product>> getProduct(int id);

  Future<Result<List<ProductCategory>>> getCategories();
}
