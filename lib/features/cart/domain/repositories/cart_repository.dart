import '../../../../core/error/result.dart';
import '../entities/cart.dart';
import '../entities/order.dart';

abstract interface class CartRepository {
  /// The saved cart, or an empty one when nothing usable was saved.
  Cart loadCart();

  Future<void> saveCart(Cart cart);

  Future<Result<Order>> placeOrder({required int userId, required Cart cart});
}
