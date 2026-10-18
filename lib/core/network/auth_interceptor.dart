import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'session_events.dart';

/// Adds the access token to requests. When the server says it has expired
/// (401), gets a new one with the refresh token and retries the request once.
///
/// As a [QueuedInterceptor] it handles one error at a time, so requests that
/// fail together lead to a single refresh. If the refresh token is rejected
/// too, the session is cleared and [SessionEvents] is told.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this._tokenStorage,
    required this._plainClient,
    required this._sessionEvents,
  });

  final TokenStorage _tokenStorage;
  final SessionEvents _sessionEvents;

  /// A client without this interceptor, for the refresh call and the retry.
  /// Retrying through the intercepted client could deadlock the error queue.
  final Dio _plainClient;

  static const _publicPaths = {ApiEndpoints.login, ApiEndpoints.refresh};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_publicPaths.contains(options.path)) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        _publicPaths.contains(request.path)) {
      handler.next(err);
      return;
    }

    final String? token;
    try {
      token = await _freshAccessToken(request);
    } on DioException catch (refreshError) {
      // The refresh call itself didn't get through, e.g. no connection. Keep
      // the session and pass that on rather than the 401, so the user sees
      // why instead of being told their session expired.
      handler.next(refreshError);
      return;
    }

    if (token == null) {
      await _tokenStorage.clear();
      _sessionEvents.notifyExpired();
      handler.next(err);
      return;
    }

    try {
      request.headers['Authorization'] = 'Bearer $token';
      handler.resolve(await _plainClient.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// A token newer than the one [request] was sent with, refreshing it if no
  /// other request has already. Null when the refresh token is rejected.
  Future<String?> _freshAccessToken(RequestOptions request) async {
    final current = await _tokenStorage.readAccessToken();
    if (current != null &&
        request.headers['Authorization'] != 'Bearer $current') {
      return current;
    }

    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _plainClient.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {
          'refreshToken': refreshToken,
          'expiresInMins': ApiEndpoints.tokenLifetimeMinutes,
        },
      );
      final data = response.data!;
      final accessToken = data['accessToken'] as String;
      await _tokenStorage.save(
        accessToken: accessToken,
        refreshToken: data['refreshToken'] as String,
      );
      return accessToken;
    } on DioException catch (error) {
      if (error.response?.statusCode case 401 || 403) return null;
      rethrow;
    }
  }
}
