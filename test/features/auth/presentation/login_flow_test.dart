import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/app/app.dart';
import 'package:shopsphere/app/home_shell.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/get_saved_user.dart';
import 'package:shopsphere/features/auth/domain/usecases/login.dart';
import 'package:shopsphere/features/auth/domain/usecases/logout.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/cubit/login_cubit.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/cart/domain/usecases/place_order.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/cubit/checkout_cubit.dart';
import 'package:shopsphere/features/products/domain/entities/product_sort.dart';
import 'package:shopsphere/features/products/domain/entities/products_page.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/get_categories.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products.dart';
import 'package:shopsphere/features/products/presentation/bloc/products_bloc.dart';
import 'package:shopsphere/features/products/presentation/cubit/categories_cubit.dart';
import 'package:shopsphere/features/profile/domain/entities/user_profile.dart';
import 'package:shopsphere/features/profile/domain/repositories/profile_repository.dart';
import 'package:shopsphere/features/profile/domain/usecases/get_profile.dart';
import 'package:shopsphere/features/profile/presentation/cubit/profile_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class FakeCartRepository extends Fake implements CartRepository {
  @override
  Cart loadCart() => const Cart();

  @override
  Future<void> saveCart(Cart cart) async {}
}

void main() {
  late MockAuthRepository repository;

  const user = User(
    id: 1,
    username: 'emilys',
    firstName: 'Emily',
    lastName: 'Johnson',
    email: 'emily.johnson@x.dummyjson.com',
    image: 'https://dummyjson.com/icon/emilys/128',
  );

  setUpAll(() => registerFallbackValue(ProductSort.relevance));

  setUp(() async {
    await getIt.reset();
    repository = MockAuthRepository();

    // Home opens on the product list, which only needs to load something.
    final products = MockProductRepository();
    when(
      () => products.getProducts(
        query: any(named: 'query'),
        category: any(named: 'category'),
        sort: any(named: 'sort'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer(
      (_) async => const Ok(ProductsPage(products: [], skip: 0, total: 0)),
    );
    when(() => products.getCategories()).thenAnswer((_) async => const Ok([]));

    getIt
      ..registerFactory(
        () => AuthCubit(
          getSavedUser: GetSavedUser(repository),
          logout: Logout(repository),
        ),
      )
      ..registerFactory(() => LoginCubit(Login(repository)))
      ..registerFactory(() => ProductsBloc(GetProducts(products)))
      ..registerFactory(() => CategoriesCubit(GetCategories(products)))
      ..registerFactory(() => CartCubit(FakeCartRepository()))
      ..registerFactory(() => CheckoutCubit(PlaceOrder(FakeCartRepository())))
      ..registerFactory(
        () => ProfileCubit(GetProfile(FakeProfileRepository())),
      );
  });

  void stubLogin(String password, Result<User> result) {
    when(() => repository.login(username: 'emilys', password: password))
        .thenAnswer((_) async => result);
  }

  testWidgets('opens home directly when a session is stored', (tester) async {
    when(() => repository.getSavedUser()).thenAnswer((_) async => user);

    await tester.pumpWidget(const ShopSphereApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('validates, shows invalid credentials, then signs in', (
    tester,
  ) async {
    when(() => repository.getSavedUser()).thenAnswer((_) async => null);
    stubLogin('wrongpass', const Err(InvalidCredentialsFailure()));
    stubLogin('emilyspass', const Ok(user));

    await tester.pumpWidget(const ShopSphereApp());
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'emilys');
    await tester.enterText(fields.at(1), 'wrongpass');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid username or password.'), findsOneWidget);

    await tester.enterText(fields.at(1), 'emilyspass');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });
}

class FakeProfileRepository extends Fake implements ProfileRepository {
  @override
  Future<Result<UserProfile>> getProfile() async => const Err(NetworkFailure());
}
