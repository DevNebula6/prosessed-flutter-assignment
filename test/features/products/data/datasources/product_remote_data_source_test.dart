import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/domain/entities/product_sort.dart';

import '../../../../helpers/fixture_reader.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late ProductRemoteDataSource dataSource;

  const fields =
      'title,price,discountPercentage,rating,stock,thumbnail,brand,category';

  setUp(() {
    dio = MockDio();
    dataSource = ProductRemoteDataSource(dio);
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        data: fixture('products_page.json') as Map<String, dynamic>,
      ),
    );
  });

  Future<List<dynamic>> fetchAndCapture({
    String query = '',
    String? category,
    ProductSort sort = ProductSort.relevance,
    int skip = 0,
  }) async {
    await dataSource.getProducts(
      query: query,
      category: category,
      sort: sort,
      skip: skip,
      limit: 20,
    );
    return verify(
      () => dio.get<Map<String, dynamic>>(
        captureAny(),
        queryParameters: captureAny(named: 'queryParameters'),
      ),
    ).captured;
  }

  test('requests the plain list with paging and the card fields', () async {
    final captured = await fetchAndCapture(skip: 40);

    expect(captured, [
      '/products',
      {'limit': 20, 'skip': 40, 'select': fields},
    ]);
  });

  test(
    'uses the search endpoint for a query and ignores the category',
    () async {
      final captured = await fetchAndCapture(
        query: 'phone',
        category: 'smartphones',
      );

      expect(captured, [
        '/products/search',
        {'q': 'phone', 'limit': 20, 'skip': 0, 'select': fields},
      ]);
    },
  );

  test('uses the category endpoint when a category is selected', () async {
    final captured = await fetchAndCapture(category: 'smartphones');

    expect(captured.first, '/products/category/smartphones');
  });

  test('maps each sort option to sortBy and order', () async {
    final expected = {
      ProductSort.priceLowToHigh: {'sortBy': 'price', 'order': 'asc'},
      ProductSort.priceHighToLow: {'sortBy': 'price', 'order': 'desc'},
      ProductSort.rating: {'sortBy': 'rating', 'order': 'desc'},
      ProductSort.title: {'sortBy': 'title', 'order': 'asc'},
    };

    for (final MapEntry(key: sort, value: params) in expected.entries) {
      final captured = await fetchAndCapture(sort: sort);
      final queryParameters = captured.last as Map<String, dynamic>;

      expect(queryParameters, containsPair('sortBy', params['sortBy']));
      expect(queryParameters, containsPair('order', params['order']));
    }
  });

  test('parses the response into a page model', () async {
    final page = await dataSource.getProducts(
      query: '',
      category: null,
      sort: ProductSort.relevance,
      skip: 0,
      limit: 20,
    );

    expect(page.total, 194);
    expect(page.products, hasLength(2));
  });
}
