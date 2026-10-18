import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/network/auth_interceptor.dart';
import 'package:shopsphere/core/network/session_events.dart';
import 'package:shopsphere/core/storage/token_storage.dart';

import '../../helpers/fake_http_adapter.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockTokenStorage tokens;
  late FakeHttpAdapter adapter;
  late Dio dio;
  late String? accessToken;
  late bool refreshTokenValid;
  late SessionEvents sessionEvents;

  ResponseBody respond(RequestOptions request) {
    switch (request.path) {
      case '/auth/refresh':
        return refreshTokenValid
            ? jsonResponse({
                'accessToken': 'new-access',
                'refreshToken': 'new-refresh',
              })
            : jsonResponse({
                'message': 'Invalid refresh token',
              }, statusCode: 403);
      case '/auth/me':
        return request.headers['Authorization'] == 'Bearer new-access'
            ? jsonResponse({'id': 1})
            : jsonResponse({
                'message': 'Invalid/Expired Token!',
              }, statusCode: 401);
      default:
        return jsonResponse({'ok': true});
    }
  }

  Iterable<RequestOptions> requestsTo(String path) {
    return adapter.requests.where((request) => request.path == path);
  }

  setUp(() {
    accessToken = 'old-access';
    refreshTokenValid = true;

    tokens = MockTokenStorage();
    when(() => tokens.readAccessToken()).thenAnswer((_) async => accessToken);
    when(() => tokens.readRefreshToken())
        .thenAnswer((_) async => 'old-refresh');
    when(
      () => tokens.save(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((invocation) async {
      accessToken = invocation.namedArguments[#accessToken] as String;
    });
    when(() => tokens.clear()).thenAnswer((_) async => accessToken = null);

    adapter = FakeHttpAdapter(respond);
    final options = BaseOptions(baseUrl: 'https://dummyjson.com');
    final plainClient = Dio(options)..httpClientAdapter = adapter;
    sessionEvents = SessionEvents();
    dio = Dio(options)
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          tokenStorage: tokens,
          plainClient: plainClient,
          sessionEvents: sessionEvents,
        ),
      );
  });

  test('adds the access token to requests', () async {
    await dio.get<void>('/products');

    expect(
      adapter.requests.single.headers['Authorization'],
      'Bearer old-access',
    );
  });

  test('leaves the token off the login request', () async {
    await dio.post<void>('/auth/login');

    expect(adapter.requests.single.headers, isNot(contains('Authorization')));
  });

  test('refreshes an expired token and retries the request', () async {
    final response = await dio.get<Map<String, dynamic>>('/auth/me');

    expect(response.data, {'id': 1});
    expect(requestsTo('/auth/refresh').single.data, {
      'refreshToken': 'old-refresh',
      'expiresInMins': 30,
    });
    verify(
      () => tokens.save(accessToken: 'new-access', refreshToken: 'new-refresh'),
    ).called(1);
  });

  test('refreshes only once for requests that fail together', () async {
    await Future.wait([dio.get<void>('/auth/me'), dio.get<void>('/auth/me')]);

    expect(requestsTo('/auth/refresh'), hasLength(1));
  });

  test('ends the session when the refresh token is rejected', () async {
    refreshTokenValid = false;
    final expired = expectLater(sessionEvents.expired, emits(null));

    await expectLater(
      dio.get<void>('/auth/me'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status code',
          401,
        ),
      ),
    );
    verify(() => tokens.clear()).called(1);
    await expired;
  });

  test('keeps the session when the refresh call cannot get through', () async {
    adapter = FakeHttpAdapter((request) {
      if (request.path == '/auth/refresh') {
        throw DioException.connectionError(
          requestOptions: request,
          reason: 'offline',
        );
      }
      return respond(request);
    });
    final options = BaseOptions(baseUrl: 'https://dummyjson.com');
    dio = Dio(options)
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          tokenStorage: tokens,
          plainClient: Dio(options)..httpClientAdapter = adapter,
          sessionEvents: sessionEvents,
        ),
      );

    // The caller should hear about the connection, not the expired token, or
    // the user is told their session ended while it didn't.
    await expectLater(
      dio.get<void>('/auth/me'),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.connectionError,
        ),
      ),
    );
    verifyNever(() => tokens.clear());
  });
}
