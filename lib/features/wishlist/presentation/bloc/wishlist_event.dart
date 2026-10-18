part of 'wishlist_bloc.dart';

sealed class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

/// Saves the product, or removes it if it's already saved.
final class WishlistToggled extends WishlistEvent {
  const WishlistToggled(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class WishlistCleared extends WishlistEvent {
  const WishlistCleared();
}
