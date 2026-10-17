import '../entities/cart.dart';

abstract interface class CartRepository {
  /// The saved cart, or an empty one when nothing usable was saved.
  Cart loadCart();

  Future<void> saveCart(Cart cart);
}
