import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/order.dart';
import 'package:shopsphere/features/cart/domain/usecases/place_order.dart';
import 'package:shopsphere/features/cart/presentation/cubit/checkout_cubit.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockPlaceOrder extends Mock implements PlaceOrder {}

void main() {
  late MockPlaceOrder placeOrder;

  final cart = const Cart().add(
    const Product(
      id: 144,
      title: 'Cricket Helmet',
      category: 'sports-accessories',
      price: 44.99,
      discountPercentage: 9.64,
      rating: 4.2,
      stock: 9,
      thumbnail: 'thumbnail.webp',
    ),
    quantity: 2,
  );
  const order = Order(id: 209, totalQuantity: 2);

  setUpAll(() => registerFallbackValue(const Cart()));

  setUp(() => placeOrder = MockPlaceOrder());

  void stubPlaceOrder(Result<Order> result) {
    when(
      () => placeOrder(
        userId: any(named: 'userId'),
        cart: any(named: 'cart'),
      ),
    ).thenAnswer((_) async => result);
  }

  blocTest<CheckoutCubit, CheckoutState>(
    'emits in progress then the placed order',
    setUp: () => stubPlaceOrder(const Ok(order)),
    build: () => CheckoutCubit(placeOrder),
    act: (cubit) => cubit.placeOrder(userId: 1, cart: cart),
    expect: () => [const CheckoutInProgress(), const CheckoutSuccess(order)],
    verify: (_) => verify(() => placeOrder(userId: 1, cart: cart)).called(1),
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'emits the failure message when the order fails',
    setUp: () => stubPlaceOrder(const Err(ServerFailure(500))),
    build: () => CheckoutCubit(placeOrder),
    act: (cubit) => cubit.placeOrder(userId: 1, cart: cart),
    expect: () => [
      const CheckoutInProgress(),
      const CheckoutError('Something went wrong. Please try again.'),
    ],
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'does nothing for an empty cart',
    build: () => CheckoutCubit(placeOrder),
    act: (cubit) => cubit.placeOrder(userId: 1, cart: const Cart()),
    expect: () => <CheckoutState>[],
  );

  test('ignores an order that completes after the cart closed', () async {
    final response = Completer<Result<Order>>();
    when(
      () => placeOrder(
        userId: any(named: 'userId'),
        cart: any(named: 'cart'),
      ),
    ).thenAnswer((_) => response.future);
    final cubit = CheckoutCubit(placeOrder);

    final placing = cubit.placeOrder(userId: 1, cart: cart);
    await cubit.close();
    response.complete(const Ok(order));

    await expectLater(placing, completes);
  });
}
