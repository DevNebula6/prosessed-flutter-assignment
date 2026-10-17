import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required this._local});

  final CartLocalDataSource _local;

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
}
