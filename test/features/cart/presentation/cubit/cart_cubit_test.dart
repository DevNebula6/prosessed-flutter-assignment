import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository repository;

  const apple = Product(
    id: 16,
    title: 'Apple',
    category: 'groceries',
    price: 1.99,
    discountPercentage: 12.62,
    rating: 4.19,
    stock: 8,
    thumbnail: 'thumbnail.webp',
  );

  setUpAll(() => registerFallbackValue(const Cart()));

  setUp(() {
    repository = MockCartRepository();
    when(() => repository.loadCart()).thenReturn(const Cart());
    when(() => repository.saveCart(any())).thenAnswer((_) async {});
  });

  test('starts with the saved cart', () {
    final saved = const Cart().add(apple, quantity: 2);
    when(() => repository.loadCart()).thenReturn(saved);

    expect(CartCubit(repository).state, saved);
  });

  blocTest<CartCubit, Cart>(
    'adding a product emits the new cart and saves it',
    build: () => CartCubit(repository),
    act: (cubit) => cubit.add(apple, quantity: 3),
    expect: () => [const Cart().add(apple, quantity: 3)],
    verify: (_) =>
        verify(() => repository.saveCart(const Cart().add(apple, quantity: 3)))
            .called(1),
  );

  blocTest<CartCubit, Cart>(
    'updates the quantity of a line',
    build: () => CartCubit(repository),
    seed: () => const Cart().add(apple),
    act: (cubit) => cubit.updateQuantity(apple.id, 4),
    expect: () => [const Cart().add(apple, quantity: 4)],
  );

  blocTest<CartCubit, Cart>(
    'removes a line',
    build: () => CartCubit(repository),
    seed: () => const Cart().add(apple),
    act: (cubit) => cubit.remove(apple.id),
    expect: () => [const Cart()],
  );

  blocTest<CartCubit, Cart>(
    'clear empties the cart and saves it',
    build: () => CartCubit(repository),
    seed: () => const Cart().add(apple, quantity: 2),
    act: (cubit) => cubit.clear(),
    expect: () => [const Cart()],
    verify: (_) => verify(() => repository.saveCart(const Cart())).called(1),
  );
}
