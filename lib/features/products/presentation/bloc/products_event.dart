part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

/// The first load, and the retry after it failed.
final class ProductsRequested extends ProductsEvent {
  const ProductsRequested();
}

final class ProductsRefreshed extends ProductsEvent {
  const ProductsRefreshed();
}

final class NextPageRequested extends ProductsEvent {
  const NextPageRequested();
}

final class SearchChanged extends ProductsEvent {
  const SearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class CategorySelected extends ProductsEvent {
  const CategorySelected(this.slug);

  /// Null shows every category.
  final String? slug;

  @override
  List<Object?> get props => [slug];
}

final class SortChanged extends ProductsEvent {
  const SortChanged(this.sort);

  final ProductSort sort;

  @override
  List<Object?> get props => [sort];
}
