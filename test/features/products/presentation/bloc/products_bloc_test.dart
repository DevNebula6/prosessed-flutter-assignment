import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_sort.dart';
import 'package:shopsphere/features/products/domain/entities/products_page.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products.dart';
import 'package:shopsphere/features/products/presentation/bloc/products_bloc.dart';

class MockGetProducts extends Mock implements GetProducts {}

Product product(int id) {
  return Product(
    id: id,
    title: 'Product $id',
    category: 'beauty',
    price: 10,
    discountPercentage: 5,
    rating: 4,
    stock: 3,
    thumbnail: 'thumbnail-$id.webp',
  );
}

void main() {
  late MockGetProducts getProducts;

  final firstPage = [product(1), product(2)];

  setUpAll(() => registerFallbackValue(ProductSort.relevance));

  setUp(() => getProducts = MockGetProducts());

  When<Future<Result<ProductsPage>>> whenGetProducts({
    String? query,
    String? category,
    int? skip,
  }) {
    return when(
      () => getProducts(
        query: query ?? any(named: 'query'),
        category: category ?? any(named: 'category'),
        sort: any(named: 'sort'),
        skip: skip ?? any(named: 'skip'),
      ),
    );
  }

  void stubPage(List<Product> products, {int skip = 0, int total = 100}) {
    whenGetProducts().thenAnswer(
      (_) async =>
          Ok(ProductsPage(products: products, skip: skip, total: total)),
    );
  }

  ProductsBloc buildBloc() => ProductsBloc(getProducts);

  group('first load', () {
    blocTest<ProductsBloc, ProductsState>(
      'emits loading then the first page',
      setUp: () => stubPage(firstPage),
      build: buildBloc,
      act: (bloc) => bloc.add(const ProductsRequested()),
      expect: () => [
        const ProductsState(status: ProductsStatus.loading),
        ProductsState(status: ProductsStatus.success, products: firstPage),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'marks the end when the first page holds everything',
      setUp: () => stubPage(firstPage, total: 2),
      build: buildBloc,
      act: (bloc) => bloc.add(const ProductsRequested()),
      skip: 1,
      expect: () => [
        ProductsState(
          status: ProductsStatus.success,
          products: firstPage,
          hasReachedEnd: true,
        ),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits empty when nothing matches',
      setUp: () => stubPage(const [], total: 0),
      build: buildBloc,
      act: (bloc) => bloc.add(const ProductsRequested()),
      skip: 1,
      expect: () => [
        const ProductsState(status: ProductsStatus.empty, hasReachedEnd: true),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits failure with the reason when the request fails',
      setUp: () => whenGetProducts().thenAnswer(
        (_) async => const Err(ServerFailure(500)),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const ProductsRequested()),
      skip: 1,
      expect: () => [
        const ProductsState(
          status: ProductsStatus.failure,
          failure: ServerFailure(500),
        ),
      ],
    );
  });

  group('next page', () {
    blocTest<ProductsBloc, ProductsState>(
      'appends the next page and stops at the end',
      setUp: () => stubPage([product(3)], skip: 2, total: 3),
      build: buildBloc,
      seed: () =>
          ProductsState(status: ProductsStatus.success, products: firstPage),
      act: (bloc) => bloc.add(const NextPageRequested()),
      expect: () => [
        ProductsState(status: ProductsStatus.loadingMore, products: firstPage),
        ProductsState(
          status: ProductsStatus.success,
          products: [...firstPage, product(3)],
          hasReachedEnd: true,
        ),
      ],
      verify: (_) => verify(
        () => getProducts(
          query: '',
          category: null,
          sort: ProductSort.relevance,
          skip: 2,
        ),
      ).called(1),
    );

    blocTest<ProductsBloc, ProductsState>(
      'does nothing once the end is reached',
      build: buildBloc,
      seed: () => ProductsState(
        status: ProductsStatus.success,
        products: firstPage,
        hasReachedEnd: true,
      ),
      act: (bloc) => bloc.add(const NextPageRequested()),
      expect: () => <ProductsState>[],
      verify: (_) => verifyNever(
        () => getProducts(
          query: any(named: 'query'),
          category: any(named: 'category'),
          sort: any(named: 'sort'),
          skip: any(named: 'skip'),
        ),
      ),
    );

    blocTest<ProductsBloc, ProductsState>(
      'keeps the loaded products when the next page fails',
      setUp: () => whenGetProducts().thenAnswer(
        (_) async => const Err(NetworkFailure()),
      ),
      build: buildBloc,
      seed: () =>
          ProductsState(status: ProductsStatus.success, products: firstPage),
      act: (bloc) => bloc.add(const NextPageRequested()),
      skip: 1,
      expect: () => [
        ProductsState(
          status: ProductsStatus.success,
          products: firstPage,
          failure: const NetworkFailure(),
        ),
      ],
    );
  });

  group('filters', () {
    blocTest<ProductsBloc, ProductsState>(
      'debounces typing and searches only the latest query',
      setUp: () => stubPage(firstPage),
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const SearchChanged('ph'))
        ..add(const SearchChanged('pho'))
        ..add(const SearchChanged('phone ')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const ProductsState(status: ProductsStatus.loading, query: 'phone'),
        ProductsState(
          status: ProductsStatus.success,
          products: firstPage,
          query: 'phone',
        ),
      ],
      verify: (_) => verify(
        () => getProducts(
          query: 'phone',
          category: null,
          sort: ProductSort.relevance,
          skip: 0,
        ),
      ).called(1),
    );

    blocTest<ProductsBloc, ProductsState>(
      'searching clears the selected category',
      setUp: () => stubPage(firstPage),
      build: buildBloc,
      seed: () => const ProductsState(
        status: ProductsStatus.success,
        category: 'beauty',
      ),
      act: (bloc) => bloc.add(const SearchChanged('phone')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const ProductsState(status: ProductsStatus.loading, query: 'phone'),
        ProductsState(
          status: ProductsStatus.success,
          products: firstPage,
          query: 'phone',
        ),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'selecting a category clears the search and reloads',
      setUp: () => stubPage(firstPage),
      build: buildBloc,
      seed: () => ProductsState(
        status: ProductsStatus.success,
        products: firstPage,
        query: 'phone',
      ),
      act: (bloc) => bloc.add(const CategorySelected('smartphones')),
      expect: () => [
        const ProductsState(
          status: ProductsStatus.loading,
          category: 'smartphones',
        ),
        ProductsState(
          status: ProductsStatus.success,
          products: firstPage,
          category: 'smartphones',
        ),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'changing the sort reloads from the first page',
      setUp: () => stubPage(firstPage),
      build: buildBloc,
      act: (bloc) => bloc.add(const SortChanged(ProductSort.priceHighToLow)),
      expect: () => [
        const ProductsState(
          status: ProductsStatus.loading,
          sort: ProductSort.priceHighToLow,
        ),
        ProductsState(
          status: ProductsStatus.success,
          products: firstPage,
          sort: ProductSort.priceHighToLow,
        ),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'ignores a slower response for filters that were replaced',
      setUp: () {
        final slowBeauty = Completer<Result<ProductsPage>>();
        whenGetProducts(category: 'beauty')
            .thenAnswer((_) => slowBeauty.future);
        whenGetProducts(category: 'smartphones').thenAnswer((_) async {
          // The outdated request completes too; its result must be ignored.
          scheduleMicrotask(
            () => slowBeauty.complete(
              Ok(ProductsPage(products: [product(9)], skip: 0, total: 1)),
            ),
          );
          return Ok(ProductsPage(products: firstPage, skip: 0, total: 2));
        });
      },
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const CategorySelected('beauty'))
        ..add(const CategorySelected('smartphones')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const ProductsState(status: ProductsStatus.loading, category: 'beauty'),
        const ProductsState(
          status: ProductsStatus.loading,
          category: 'smartphones',
        ),
        ProductsState(
          status: ProductsStatus.success,
          products: firstPage,
          hasReachedEnd: true,
          category: 'smartphones',
        ),
      ],
    );
  });

  group('refresh', () {
    blocTest<ProductsBloc, ProductsState>(
      'keeps the products on screen while refreshing and replaces them after',
      setUp: () => stubPage([product(5)]),
      build: buildBloc,
      seed: () =>
          ProductsState(status: ProductsStatus.success, products: firstPage),
      act: (bloc) => bloc.add(const ProductsRefreshed()),
      expect: () => [
        ProductsState(status: ProductsStatus.loading, products: firstPage),
        ProductsState(status: ProductsStatus.success, products: [product(5)]),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'keeps the products and reports the failure once when refresh fails',
      setUp: () => whenGetProducts().thenAnswer(
        (_) async => const Err(NetworkFailure()),
      ),
      build: buildBloc,
      seed: () =>
          ProductsState(status: ProductsStatus.success, products: firstPage),
      act: (bloc) => bloc.add(const ProductsRefreshed()),
      skip: 1,
      // Reported for the snackbar, then cleared, so the list footer doesn't
      // offer to load more as if the next page had failed.
      expect: () => [
        ProductsState(
          status: ProductsStatus.success,
          products: firstPage,
          failure: const NetworkFailure(),
        ),
        ProductsState(status: ProductsStatus.success, products: firstPage),
      ],
    );
  });
}
