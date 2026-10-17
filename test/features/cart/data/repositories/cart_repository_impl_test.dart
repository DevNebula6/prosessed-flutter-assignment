import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:shopsphere/features/cart/data/models/cart_item_model.dart';
import 'package:shopsphere/features/cart/data/models/order_model.dart';
import 'package:shopsphere/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/order.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockCartLocalDataSource extends Mock implements CartLocalDataSource {}

class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

void main() {
  late MockCartLocalDataSource local;
  late MockCartRemoteDataSource remote;
  late CartRepositoryImpl repository;

  const helmet = Product(
    id: 144,
    title: 'Cricket Helmet',
    category: 'sports-accessories',
    price: 44.99,
    discountPercentage: 9.64,
    rating: 4.2,
    stock: 9,
    thumbnail: 'thumbnail.webp',
  );
  final cart = const Cart().add(helmet, quantity: 2);

  setUpAll(() => registerFallbackValue(<CartItemModel>[]));

  setUp(() {
    local = MockCartLocalDataSource();
    remote = MockCartRemoteDataSource();
    repository = CartRepositoryImpl(local: local, remote: remote);
  });

  group('loadCart', () {
    test('returns the saved items', () {
      when(() => local.getItems()).thenReturn([
        CartItemModel(product: ProductModel.fromEntity(helmet), quantity: 2),
      ]);

      expect(repository.loadCart(), cart);
    });

    test('falls back to an empty cart when the saved one is unreadable', () {
      when(() => local.getItems()).thenThrow(const FormatException());

      expect(repository.loadCart(), const Cart());
    });
  });

  test('saveCart stores every line with its quantity', () async {
    when(() => local.saveItems(any())).thenAnswer((_) async {});

    await repository.saveCart(cart);

    final saved =
        verify(() => local.saveItems(captureAny())).captured.single
            as List<CartItemModel>;
    expect(saved.single.product.id, 144);
    expect(saved.single.quantity, 2);
  });

  group('placeOrder', () {
    test('returns the order the API created', () async {
      when(() => remote.placeOrder(userId: 1, items: any(named: 'items')))
          .thenAnswer((_) async => const OrderModel(id: 209, totalQuantity: 2));

      final result = await repository.placeOrder(userId: 1, cart: cart);

      expect(result, const Ok<Order>(Order(id: 209, totalQuantity: 2)));
    });

    test('returns NetworkFailure when offline', () async {
      when(
        () => remote.placeOrder(
          userId: any(named: 'userId'),
          items: any(named: 'items'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/carts/add'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.placeOrder(userId: 1, cart: cart);

      expect(result, const Err<Order>(NetworkFailure()));
    });
  });
}
