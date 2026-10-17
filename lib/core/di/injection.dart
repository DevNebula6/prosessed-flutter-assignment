import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../storage/token_storage.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt
    ..registerLazySingleton(() => TokenStorage(const FlutterSecureStorage()))
    ..registerLazySingleton<Dio>(createDio);
}
