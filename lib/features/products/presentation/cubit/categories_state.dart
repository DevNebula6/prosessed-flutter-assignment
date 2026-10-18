part of 'categories_cubit.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

final class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

final class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(this.categories);

  final List<ProductCategory> categories;

  @override
  List<Object?> get props => [categories];
}

final class CategoriesError extends CategoriesState {
  const CategoriesError();
}
