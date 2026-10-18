import '../../../../core/error/result.dart';
import '../entities/product_category.dart';
import '../repositories/product_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final ProductRepository _repository;

  Future<Result<List<ProductCategory>>> call() => _repository.getCategories();
}
