import '../../../../core/error/result.dart';
import '../entities/cart.dart';
import '../entities/order.dart';
import '../repositories/cart_repository.dart';

class PlaceOrder {
  const PlaceOrder(this._repository);

  final CartRepository _repository;

  Future<Result<Order>> call({required int userId, required Cart cart}) {
    return _repository.placeOrder(userId: userId, cart: cart);
  }
}
