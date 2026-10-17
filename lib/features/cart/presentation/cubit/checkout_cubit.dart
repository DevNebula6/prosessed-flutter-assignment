import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/place_order.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._placeOrder) : super(const CheckoutIdle());

  final PlaceOrder _placeOrder;

  Future<void> placeOrder({required int userId, required Cart cart}) async {
    if (state is CheckoutInProgress || cart.isEmpty) return;

    emit(const CheckoutInProgress());
    final result = await _placeOrder(userId: userId, cart: cart);
    emit(switch (result) {
      Ok(:final value) => CheckoutSuccess(value),
      Err(:final failure) => CheckoutError(failure.message),
    });
  }
}
