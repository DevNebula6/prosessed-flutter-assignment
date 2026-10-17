import '../../../../core/error/result.dart';
import '../entities/product_sort.dart';
import '../entities/products_page.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  Future<Result<ProductsPage>> call({
    String query = '',
    String? category,
    ProductSort sort = ProductSort.relevance,
    int skip = 0,
  }) {
    return _repository.getProducts(
      query: query.trim(),
      category: category,
      sort: sort,
      skip: skip,
    );
  }
}
