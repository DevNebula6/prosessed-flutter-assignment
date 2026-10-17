import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/core/storage/token_storage.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/data/models/login_response_model.dart';
import 'package:shopsphere/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';

import '../../../../helpers/fixture_reader.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late MockTokenStorage tokenStorage;
  late AuthRepositoryImpl repository;

  final response = LoginResponseModel.fromJson(
    fixture('login_response.json') as Map<String, dynamic>,
  );
  final user = response.user.toEntity();

  DioException dioError(DioExceptionType type, {int? statusCode}) {
    final options = RequestOptions(path: '/auth/login');
    return DioException(
      requestOptions: options,
      type: type,
      response: statusCode == null
          ? null
          : Response(requestOptions: options, statusCode: statusCode),
    );
  }

  setUpAll(() => registerFallbackValue(response.user));

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    tokenStorage = MockTokenStorage();
    repository = AuthRepositoryImpl(
      remote: remote,
      local: local,
      tokenStorage: tokenStorage,
    );

    when(
      () => tokenStorage.save(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    when(() => local.saveUser(any())).thenAnswer((_) async {});
  });

  group('login', () {
    test('returns the user and stores the session', () async {
      when(() => remote.login('emilys', 'emilyspass'))
          .thenAnswer((_) async => response);

      final result = await repository.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(result, Ok<User>(user));
      verify(
        () => tokenStorage.save(
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
        ),
      ).called(1);
      verify(() => local.saveUser(response.user)).called(1);
    });

    test('maps a 400 to InvalidCredentialsFailure', () async {
      when(() => remote.login(any(), any()))
          .thenThrow(dioError(DioExceptionType.badResponse, statusCode: 400));

      final result = await repository.login(
        username: 'emilys',
        password: 'wrong',
      );

      expect(result, const Err<User>(InvalidCredentialsFailure()));
      verifyNever(
        () => tokenStorage.save(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      );
    });

    test('returns NetworkFailure when there is no connection', () async {
      when(() => remote.login(any(), any()))
          .thenThrow(dioError(DioExceptionType.connectionError));

      final result = await repository.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(result, const Err<User>(NetworkFailure()));
    });

    test('returns ServerFailure when the server fails', () async {
      when(() => remote.login(any(), any()))
          .thenThrow(dioError(DioExceptionType.badResponse, statusCode: 500));

      final result = await repository.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(result, const Err<User>(ServerFailure(500)));
    });
  });

  group('getSavedUser', () {
    test('returns null when no token is stored', () async {
      when(() => tokenStorage.readAccessToken()).thenAnswer((_) async => null);

      expect(await repository.getSavedUser(), isNull);
      verifyNever(() => local.getUser());
    });

    test('returns the cached user when a token is stored', () async {
      when(() => tokenStorage.readAccessToken())
          .thenAnswer((_) async => 'test-access-token');
      when(() => local.getUser()).thenReturn(response.user);

      expect(await repository.getSavedUser(), user);
    });

    test('returns null when secure storage cannot be read', () async {
      when(() => tokenStorage.readAccessToken())
          .thenThrow(Exception('keystore reset'));

      expect(await repository.getSavedUser(), isNull);
    });
  });

  test('logout clears the tokens and the cached user', () async {
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
    when(() => local.clear()).thenAnswer((_) async {});

    await repository.logout();

    verify(() => tokenStorage.clear()).called(1);
    verify(() => local.clear()).called(1);
  });
}
