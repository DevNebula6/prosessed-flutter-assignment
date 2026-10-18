import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_endpoints.dart';

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      // Request headers carry the access token and bodies the password, so
      // log only what was called and how it went.
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        logPrint: (line) => debugPrint(line.toString()),
      ),
    );
  }
  return dio;
}
