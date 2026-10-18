part of 'checkout_cubit.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

final class CheckoutIdle extends CheckoutState {
  const CheckoutIdle();
}

final class CheckoutInProgress extends CheckoutState {
  const CheckoutInProgress();
}

final class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess(this.order);

  final Order order;

  @override
  List<Object?> get props => [order];
}

final class CheckoutError extends CheckoutState {
  const CheckoutError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
