import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product.dart';
import 'package:shopsphere/features/products/presentation/cubit/product_details_cubit.dart';

class MockGetProduct extends Mock implements GetProduct {}

void main() {
  late MockGetProduct getProduct;

  const product = Product(
    id: 1,
    title: 'Essence Mascara Lash Princess',
    category: 'beauty',
    price: 9.99,
    discountPercentage: 10.48,
    rating: 2.56,
    stock: 99,
    thumbnail: 'thumbnail.webp',
  );

  setUp(() => getProduct = MockGetProduct());

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'emits loading then the product',
    setUp: () =>
        when(() => getProduct(1)).thenAnswer((_) async => const Ok(product)),
    build: () => ProductDetailsCubit(getProduct),
    act: (cubit) => cubit.load(1),
    expect: () => [
      const ProductDetailsLoading(),
      const ProductDetailsLoaded(product),
    ],
  );

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'emits not found for a product that does not exist',
    setUp: () =>
        when(() => getProduct(9999))
            .thenAnswer((_) async => const Err(NotFoundFailure())),
    build: () => ProductDetailsCubit(getProduct),
    act: (cubit) => cubit.load(9999),
    expect: () => [
      const ProductDetailsLoading(),
      const ProductDetailsNotFound(),
    ],
  );

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'emits an error with the failure for anything else',
    setUp: () =>
        when(() => getProduct(1))
            .thenAnswer((_) async => const Err(ServerFailure(500))),
    build: () => ProductDetailsCubit(getProduct),
    act: (cubit) => cubit.load(1),
    expect: () => [
      const ProductDetailsLoading(),
      const ProductDetailsError(ServerFailure(500)),
    ],
  );

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'shows loading again when retrying after an error',
    setUp: () =>
        when(() => getProduct(1)).thenAnswer((_) async => const Ok(product)),
    build: () => ProductDetailsCubit(getProduct),
    seed: () => const ProductDetailsError(NetworkFailure()),
    act: (cubit) => cubit.load(1),
    expect: () => [
      const ProductDetailsLoading(),
      const ProductDetailsLoaded(product),
    ],
  );

  test('ignores a product that arrives after the page closed', () async {
    final response = Completer<Result<Product>>();
    when(() => getProduct(1)).thenAnswer((_) => response.future);
    final cubit = ProductDetailsCubit(getProduct);

    final loading = cubit.load(1);
    await cubit.close();
    response.complete(const Ok(product));

    await expectLater(loading, completes);
  });
}
