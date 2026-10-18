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
      LogInterceptor(
        requestBody: true,
        logPrint: (line) => debugPrint(line.toString()),
      ),
    );
  }
  return dio;
}
