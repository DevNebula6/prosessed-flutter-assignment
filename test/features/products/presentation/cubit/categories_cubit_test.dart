import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/products/domain/entities/product_category.dart';
import 'package:shopsphere/features/products/domain/usecases/get_categories.dart';
import 'package:shopsphere/features/products/presentation/cubit/categories_cubit.dart';

class MockGetCategories extends Mock implements GetCategories {}

void main() {
  late MockGetCategories getCategories;

  const categories = [
    ProductCategory(slug: 'beauty', name: 'Beauty'),
    ProductCategory(slug: 'groceries', name: 'Groceries'),
  ];

  setUp(() => getCategories = MockGetCategories());

  blocTest<CategoriesCubit, CategoriesState>(
    'emits loading then the categories',
    setUp: () =>
        when(() => getCategories())
            .thenAnswer((_) async => const Ok(categories)),
    build: () => CategoriesCubit(getCategories),
    act: (cubit) => cubit.load(),
    expect: () => [
      const CategoriesLoading(),
      const CategoriesLoaded(categories),
    ],
  );

  blocTest<CategoriesCubit, CategoriesState>(
    'emits loading then an error when loading fails',
    setUp: () =>
        when(() => getCategories())
            .thenAnswer((_) async => const Err(NetworkFailure())),
    build: () => CategoriesCubit(getCategories),
    act: (cubit) => cubit.load(),
    expect: () => [const CategoriesLoading(), const CategoriesError()],
  );
}
