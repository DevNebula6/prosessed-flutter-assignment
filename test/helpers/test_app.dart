import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/theme_bloc.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/get_saved_user.dart';
import 'package:shopsphere/features/auth/domain/usecases/login.dart';
import 'package:shopsphere/features/auth/domain/usecases/logout.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/cubit/login_cubit.dart';
import 'package:shopsphere/features/cart/domain/usecases/place_order.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/cubit/checkout_cubit.dart';
import 'package:shopsphere/features/products/domain/usecases/get_categories.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products.dart';
import 'package:shopsphere/features/products/presentation/bloc/products_bloc.dart';
import 'package:shopsphere/features/products/presentation/cubit/categories_cubit.dart';
import 'package:shopsphere/features/products/presentation/cubit/product_details_cubit.dart';
import 'package:shopsphere/features/profile/domain/usecases/get_profile.dart';
import 'package:shopsphere/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:shopsphere/features/wishlist/presentation/bloc/wishlist_bloc.dart';

import 'fakes.dart';

/// Registers every bloc the app asks [getIt] for, backed by in-memory
/// repositories. Pass [auth] to control sign-in from the test.
Future<void> registerFakeDependencies({AuthRepository? auth}) async {
  await getIt.reset();
  final authRepository = auth ?? FakeAuthRepository(savedUser: testUser);
  final products = FakeProductRepository();
  final cart = FakeCartRepository();

  getIt
    ..registerFactory(
      () => AuthCubit(
        getSavedUser: GetSavedUser(authRepository),
        logout: Logout(authRepository),
        sessionExpired: const Stream.empty(),
      ),
    )
    ..registerFactory(() => LoginCubit(Login(authRepository)))
    ..registerFactory(() => ProductsBloc(GetProducts(products)))
    ..registerFactory(() => CategoriesCubit(GetCategories(products)))
    ..registerFactory(() => ProductDetailsCubit(GetProduct(products)))
    ..registerFactory(() => CartCubit(cart))
    ..registerFactory(() => CheckoutCubit(PlaceOrder(cart)))
    ..registerFactory(() => ProfileCubit(GetProfile(FakeProfileRepository())))
    ..registerFactory(() => WishlistBloc(FakeWishlistRepository()))
    ..registerFactory(() => ThemeBloc(FakeThemeStorage()));

  // Network images go through a disk cache that asks the platform for a
  // folder; tests have no platform, so point it at the temp directory.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => Directory.systemTemp.path,
      );
}

/// Pumps [home] inside the same app-wide providers and theme the app uses,
/// on a screen of [size] with text scaled by [textScale].
Future<void> pumpTestApp(
  WidgetTester tester,
  Widget home, {
  Size size = const Size(412, 915),
  double textScale = 1,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkSession()),
        BlocProvider(create: (_) => getIt<CartCubit>()),
        BlocProvider(create: (_) => getIt<WishlistBloc>()),
        BlocProvider(create: (_) => getIt<ThemeBloc>()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: home,
      ),
    ),
  );
  // Long enough for the fake requests to land, without waiting for the
  // never-ending shimmer and spinner animations to settle.
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 500));
}
