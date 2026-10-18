import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';

/// App-wide cart. Every change is saved right away.
class CartCubit extends Cubit<Cart> {
  CartCubit(this._repository) : super(_repository.loadCart());

  final CartRepository _repository;

  Future<void> add(Product product, {int quantity = 1}) {
    return _update(state.add(product, quantity: quantity));
  }

  Future<void> updateQuantity(int productId, int quantity) {
    return _update(state.updateQuantity(productId, quantity));
  }

  Future<void> remove(int productId) => _update(state.remove(productId));

  Future<void> clear() => _update(const Cart());

  Future<void> _update(Cart cart) async {
    emit(cart);
    await _repository.saveCart(cart);
  }
}
