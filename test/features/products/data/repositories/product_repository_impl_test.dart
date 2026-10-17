import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/models/product_category_model.dart';
import 'package:shopsphere/features/products/data/models/products_page_model.dart';
import 'package:shopsphere/features/products/data/repositories/product_repository_impl.dart';
import 'package:shopsphere/features/products/domain/entities/product_category.dart';
import 'package:shopsphere/features/products/domain/entities/product_sort.dart';
import 'package:shopsphere/features/products/domain/entities/products_page.dart';

import '../../../../helpers/fixture_reader.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

void main() {
  late MockProductRemoteDataSource remote;
  late ProductRepositoryImpl repository;

  final pageModel = ProductsPageModel.fromJson(
    fixture('products_page.json') as Map<String, dynamic>,
  );

  setUpAll(() => registerFallbackValue(ProductSort.relevance));

  setUp(() {
    remote = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(remote);
  });

  void stubGetProducts(Future<ProductsPageModel> Function() answer) {
    when(
      () => remote.getProducts(
        query: any(named: 'query'),
        category: any(named: 'category'),
        sort: any(named: 'sort'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => answer());
  }

  DioException dioError(DioExceptionType type, [int? statusCode]) {
    final options = RequestOptions(path: '/products');
    return DioException(
      requestOptions: options,
      type: type,
      response: statusCode == null
          ? null
          : Response(requestOptions: options, statusCode: statusCode),
    );
  }

  group('getProducts', () {
    test('returns the page and forwards the filters', () async {
      stubGetProducts(() async => pageModel);

      final result = await repository.getProducts(
        query: 'mascara',
        sort: ProductSort.rating,
        skip: 20,
      );

      expect(result, Ok<ProductsPage>(pageModel.toEntity()));
      verify(
        () => remote.getProducts(
          query: 'mascara',
          category: null,
          sort: ProductSort.rating,
          skip: 20,
          limit: 20,
        ),
      ).called(1);
    });

    test('returns ServerFailure when the server fails', () async {
      stubGetProducts(() => throw dioError(DioExceptionType.badResponse, 500));

      final result = await repository.getProducts();

      expect(result, const Err<ProductsPage>(ServerFailure(500)));
    });

    test('returns NetworkFailure when offline', () async {
      stubGetProducts(() => throw dioError(DioExceptionType.connectionError));

      final result = await repository.getProducts();

      expect(result, const Err<ProductsPage>(NetworkFailure()));
    });
  });

  group('getCategories', () {
    test('returns the categories', () async {
      when(() => remote.getCategories()).thenAnswer(
        (_) async => const [
          ProductCategoryModel(slug: 'beauty', name: 'Beauty'),
        ],
      );

      final result = await repository.getCategories();

      expect(
        result,
        const Ok<List<ProductCategory>>([
          ProductCategory(slug: 'beauty', name: 'Beauty'),
        ]),
      );
    });

    test('returns TimeoutFailure when the request times out', () async {
      when(() => remote.getCategories())
          .thenThrow(dioError(DioExceptionType.receiveTimeout));

      final result = await repository.getCategories();

      expect(result, const Err<List<ProductCategory>>(TimeoutFailure()));
    });
  });
}
