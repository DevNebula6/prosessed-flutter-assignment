import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/event_transformers.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_sort.dart';
import '../../domain/entities/products_page.dart';
import '../../domain/usecases/get_products.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc(this._getProducts) : super(const ProductsState()) {
    on<ProductsRequested>((event, emit) => _loadFirstPage(emit, state));
    on<ProductsRefreshed>(
      (event, emit) => _loadFirstPage(emit, state, keepProducts: true),
    );
    on<NextPageRequested>(_onNextPageRequested, transformer: droppable());
    on<SearchChanged>(
      _onSearchChanged,
      transformer: debounce(const Duration(milliseconds: 400)),
    );
    on<CategorySelected>(_onCategorySelected);
    on<SortChanged>(_onSortChanged);
  }

  final GetProducts _getProducts;

  // Bumped by every first-page load. A response that comes back for an older
  // load is dropped, so a slow request can't overwrite newer filters.
  var _latestRequest = 0;

  Future<void> _onSearchChanged(
    SearchChanged event,
    Emitter<ProductsState> emit,
  ) async {
    final query = event.query.trim();
    if (query == state.query) return;

    // The API can't search inside a category, so a search covers all of them.
    await _loadFirstPage(
      emit,
      state.copyWith(query: query, category: () => null),
    );
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<ProductsState> emit,
  ) async {
    if (event.slug == state.category && state.query.isEmpty) return;

    await _loadFirstPage(
      emit,
      state.copyWith(category: () => event.slug, query: ''),
    );
  }

  Future<void> _onSortChanged(
    SortChanged event,
    Emitter<ProductsState> emit,
  ) async {
    if (event.sort == state.sort) return;

    await _loadFirstPage(emit, state.copyWith(sort: event.sort));
  }

  Future<void> _onNextPageRequested(
    NextPageRequested event,
    Emitter<ProductsState> emit,
  ) async {
    if (state.status != ProductsStatus.success || state.hasReachedEnd) return;

    final request = _latestRequest;
    emit(state.copyWith(status: ProductsStatus.loadingMore));
    final result = await _fetch(skip: state.products.length);
    if (request != _latestRequest) return;

    switch (result) {
      case Ok(value: final page):
        emit(
          state.copyWith(
            status: ProductsStatus.success,
            products: [...state.products, ...page.products],
            hasReachedEnd: !page.hasMore,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(status: ProductsStatus.success, failure: failure));
    }
  }

  /// Loads the first page for the filters in [next]. A refresh keeps the
  /// current products on screen while it runs.
  Future<void> _loadFirstPage(
    Emitter<ProductsState> emit,
    ProductsState next, {
    bool keepProducts = false,
  }) async {
    final request = ++_latestRequest;
    emit(
      next.copyWith(
        status: ProductsStatus.loading,
        products: keepProducts ? null : const [],
        hasReachedEnd: false,
      ),
    );
    final result = await _fetch(skip: 0);
    if (request != _latestRequest) return;

    switch (result) {
      case Ok(value: final page):
        emit(
          state.copyWith(
            status: page.products.isEmpty
                ? ProductsStatus.empty
                : ProductsStatus.success,
            products: page.products,
            hasReachedEnd: !page.hasMore,
          ),
        );
      case Err(:final failure) when state.products.isEmpty:
        emit(state.copyWith(status: ProductsStatus.failure, failure: failure));
      case Err(:final failure):
        // A refresh failed with products on screen. Keep them, and set the
        // failure only for a moment so the page can show it in a snackbar;
        // left set, the list footer would offer to load the next page.
        emit(state.copyWith(status: ProductsStatus.success, failure: failure));
        emit(state.copyWith(status: ProductsStatus.success));
    }
  }

  Future<Result<ProductsPage>> _fetch({required int skip}) {
    return _getProducts(
      query: state.query,
      category: state.category,
      sort: state.sort,
      skip: skip,
    );
  }
}
