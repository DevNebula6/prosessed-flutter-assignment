import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required this._local, required this._remote});

  final CartLocalDataSource _local;
  final CartRemoteDataSource _remote;

  @override
  Cart loadCart() {
    try {
      return Cart(_local.getItems().map((item) => item.toEntity()).toList());
    } catch (_) {
      // A saved cart that no longer parses isn't worth failing the app over.
      return const Cart();
    }
  }

  @override
  Future<void> saveCart(Cart cart) {
    return _local.saveItems(cart.items.map(CartItemModel.fromEntity).toList());
  }

  @override
  Future<Result<Order>> placeOrder({required int userId, required Cart cart}) {
    return guard(() async {
      final order = await _remote.placeOrder(
        userId: userId,
        items: cart.items.map(CartItemModel.fromEntity).toList(),
      );
      return order.toEntity();
    });
  }
}
