import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_sort.dart';
import '../../domain/entities/products_page.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<Result<ProductsPage>> getProducts({
    String query = '',
    String? category,
    ProductSort sort = ProductSort.relevance,
    int skip = 0,
    int limit = 20,
  }) {
    return guard(() async {
      final page = await _remote.getProducts(
        query: query,
        category: category,
        sort: sort,
        skip: skip,
        limit: limit,
      );
      return page.toEntity();
    });
  }

  @override
  Future<Result<Product>> getProduct(int id) {
    return guard(() async {
      final product = await _remote.getProduct(id);
      return product.toEntity();
    });
  }

  @override
  Future<Result<List<ProductCategory>>> getCategories() {
    return guard(() async {
      final categories = await _remote.getCategories();
      return categories.map((category) => category.toEntity()).toList();
    });
  }
}
