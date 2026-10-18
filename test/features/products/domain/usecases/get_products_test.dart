import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/products/domain/entities/product_sort.dart';
import 'package:shopsphere/features/products/domain/entities/products_page.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  test('trims the search query and forwards the filters', () async {
    final repository = MockProductRepository();
    const page = ProductsPage(products: [], skip: 0, total: 0);
    when(
      () => repository.getProducts(
        query: any(named: 'query'),
        category: any(named: 'category'),
        sort: ProductSort.title,
        skip: any(named: 'skip'),
      ),
    ).thenAnswer((_) async => const Ok(page));

    final result = await GetProducts(repository)(
      query: '  phone ',
      category: 'smartphones',
      sort: ProductSort.title,
      skip: 20,
    );

    expect(result, const Ok(page));
    verify(
      () => repository.getProducts(
        query: 'phone',
        category: 'smartphones',
        sort: ProductSort.title,
        skip: 20,
      ),
    ).called(1);
  });
}
