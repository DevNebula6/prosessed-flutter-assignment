import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/error_mapper.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';

void main() {
  final requestOptions = RequestOptions(path: '/products');

  DioException dioError(DioExceptionType type, {Object? error}) {
    return DioException(
      requestOptions: requestOptions,
      type: type,
      error: error,
    );
  }

  DioException badResponse(int statusCode) {
    return DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: requestOptions,
        statusCode: statusCode,
      ),
    );
  }

  group('mapError', () {
    test('maps timeouts to TimeoutFailure', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(mapError(dioError(type)), const TimeoutFailure());
      }
    });

    test('maps connection errors to NetworkFailure', () {
      expect(
        mapError(dioError(DioExceptionType.connectionError)),
        const NetworkFailure(),
      );
      expect(
        mapError(
          dioError(
            DioExceptionType.unknown,
            error: const SocketException('Connection reset'),
          ),
        ),
        const NetworkFailure(),
      );
    });

    test('maps 401 and 403 to UnauthorizedFailure', () {
      expect(mapError(badResponse(401)), const UnauthorizedFailure());
      expect(mapError(badResponse(403)), const UnauthorizedFailure());
    });

    test('maps 404 to NotFoundFailure', () {
      expect(mapError(badResponse(404)), const NotFoundFailure());
    });

    test('maps other error statuses to ServerFailure with the code', () {
      expect(mapError(badResponse(500)), const ServerFailure(500));
      expect(mapError(badResponse(400)), const ServerFailure(400));
    });

    test('maps malformed data to ParseFailure', () {
      expect(mapError(const FormatException()), const ParseFailure());
      expect(mapError(TypeError()), const ParseFailure());
    });

    test('maps anything else to UnknownFailure', () {
      expect(mapError(Exception('boom')), const UnknownFailure());
      expect(
        mapError(dioError(DioExceptionType.cancel)),
        const UnknownFailure(),
      );
    });
  });

  group('guard', () {
    test('returns Ok with the value when the action succeeds', () async {
      final result = await guard(() async => 42);

      expect(result, const Ok(42));
    });

    test(
      'returns Err with the mapped failure when the action throws',
      () async {
        final result = await guard<int>(() => throw badResponse(500));

        expect(result, const Err<int>(ServerFailure(500)));
      },
    );
  });
}
