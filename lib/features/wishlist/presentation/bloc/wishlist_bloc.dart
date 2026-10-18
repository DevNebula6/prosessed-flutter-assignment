import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/domain/entities/product.dart';
import '../../domain/repositories/wishlist_repository.dart';

part 'wishlist_event.dart';
part 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc(this._repository)
    : super(WishlistState(_repository.loadWishlist())) {
    // One change at a time, so the saves land in the order they were made.
    on<WishlistEvent>(_onChanged, transformer: sequential());
  }

  final WishlistRepository _repository;

  Future<void> _onChanged(
    WishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    final products = switch (event) {
      WishlistToggled(:final product) when state.contains(product.id) =>
        state.products.where((saved) => saved.id != product.id).toList(),
      WishlistToggled(:final product) => [product, ...state.products],
      WishlistCleared() => const <Product>[],
    };

    emit(WishlistState(products));
    await _repository.saveWishlist(products);
  }
}
