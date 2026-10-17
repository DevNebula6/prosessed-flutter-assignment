import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  getIt
    ..registerSingleton(prefs)
    ..registerLazySingleton(() => TokenStorage(const FlutterSecureStorage()))
    ..registerLazySingleton<Dio>(
      () => createDio(interceptors: [AuthInterceptor(getIt())]),
    );

  _registerAuth();
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
    );
}
