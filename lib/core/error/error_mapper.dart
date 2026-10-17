import 'dart:io';

import 'package:dio/dio.dart';

import 'failures.dart';
import 'result.dart';

/// Runs [action] and turns anything it throws into an [Err] with a [Failure].
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } catch (error) {
    return Err(mapError(error));
  }
}

Failure mapError(Object error) {
  return switch (error) {
    DioException() => _mapDioException(error),
    // Thrown while reading a JSON body that doesn't match our models.
    FormatException() || TypeError() => const ParseFailure(),
    _ => const UnknownFailure(),
  };
}

Failure _mapDioException(DioException error) {
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const TimeoutFailure(),
    DioExceptionType.connectionError => const NetworkFailure(),
    // A connection dropped mid-response comes through as an unknown error.
    DioExceptionType.unknown when error.error is SocketException =>
      const NetworkFailure(),
    DioExceptionType.badResponse => _mapStatusCode(error.response?.statusCode),
    _ => const UnknownFailure(),
  };
}

Failure _mapStatusCode(int? statusCode) {
  return switch (statusCode) {
    401 || 403 => const UnauthorizedFailure(),
    404 => const NotFoundFailure(),
    _ => ServerFailure(statusCode),
  };
}
