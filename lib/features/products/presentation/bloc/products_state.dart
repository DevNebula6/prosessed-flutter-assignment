part of 'products_bloc.dart';

enum ProductsStatus { initial, loading, success, empty, failure, loadingMore }

final class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.hasReachedEnd = false,
    this.query = '',
    this.category,
    this.sort = ProductSort.relevance,
    this.failure,
  });

  final ProductsStatus status;
  final List<Product> products;
  final bool hasReachedEnd;
  final String query;
  final String? category;
  final ProductSort sort;

  /// Why the latest request failed. When the next page fails, this is set
  /// next to the products already on screen; a failed refresh sets it only
  /// for one state, to show a snackbar.
  final Failure? failure;

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    bool? hasReachedEnd,
    String? query,
    String? Function()? category,
    ProductSort? sort,
    Failure? failure,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      query: query ?? this.query,
      category: category != null ? category() : this.category,
      sort: sort ?? this.sort,
      // A failure only describes the request that just finished.
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    hasReachedEnd,
    query,
    category,
    sort,
    failure,
  ];
}
