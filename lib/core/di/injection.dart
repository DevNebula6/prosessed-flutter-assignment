import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_saved_user.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/cart/data/datasources/cart_local_data_source.dart';
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/place_order.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/cubit/checkout_cubit.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_categories.dart';
import '../../features/products/domain/usecases/get_product.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/presentation/bloc/products_bloc.dart';
import '../../features/products/presentation/cubit/categories_cubit.dart';
import '../../features/products/presentation/cubit/product_details_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../network/session_events.dart';
import '../storage/token_storage.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  getIt
    ..registerSingleton(prefs)
    ..registerLazySingleton(() => TokenStorage(const FlutterSecureStorage()))
    ..registerLazySingleton(SessionEvents.new)
    ..registerLazySingleton<Dio>(
      // Inserted first so the debug log shows the Authorization header.
      () => createDio()
        ..interceptors.insert(
          0,
          AuthInterceptor(
            tokenStorage: getIt(),
            plainClient: createDio(),
            sessionEvents: getIt(),
          ),
        ),
    );

  _registerAuth();
  _registerProducts();
  _registerCart();
  _registerProfile();
}

void _registerAuth() {
  getIt
    ..registerLazySingleton(() => AuthRemoteDataSource(getIt()))
    ..registerLazySingleton(() => AuthLocalDataSource(getIt()))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: getIt(),
        local: getIt(),
        tokenStorage: getIt(),
      ),
    )
    ..registerLazySingleton(() => Login(getIt()))
    ..registerLazySingleton(() => Logout(getIt()))
    ..registerLazySingleton(() => GetSavedUser(getIt()))
    ..registerFactory(
      () => AuthCubit(
        getSavedUser: getIt(),
        logout: getIt(),
        sessionExpired: getIt<SessionEvents>().expired,
      ),
    )
    ..registerFactory(() => LoginCubit(getIt()));
}

void _registerProducts() {
  getIt
    ..registerLazySingleton(() => ProductRemoteDataSource(getIt()))
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetProducts(getIt()))
    ..registerLazySingleton(() => GetProduct(getIt()))
    ..registerLazySingleton(() => GetCategories(getIt()))
    ..registerFactory(() => ProductsBloc(getIt()))
    ..registerFactory(() => CategoriesCubit(getIt()))
    ..registerFactory(() => ProductDetailsCubit(getIt()));
}

void _registerCart() {
  getIt
    ..registerLazySingleton(() => CartLocalDataSource(getIt()))
    ..registerLazySingleton(() => CartRemoteDataSource(getIt()))
    ..registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(local: getIt(), remote: getIt()),
    )
    ..registerLazySingleton(() => PlaceOrder(getIt()))
    ..registerFactory(() => CartCubit(getIt()))
    ..registerFactory(() => CheckoutCubit(getIt()));
}

void _registerProfile() {
  getIt
    ..registerLazySingleton(() => ProfileRemoteDataSource(getIt()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetProfile(getIt()))
    ..registerFactory(() => ProfileCubit(getIt()));
}
