import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remote,
    required this._local,
    required this._tokenStorage,
  });

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final TokenStorage _tokenStorage;

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
  }) async {
    final result = await guard<User>(() async {
      final response = await _remote.login(username, password);
      await _tokenStorage.save(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _local.saveUser(response.user);
      return response.user.toEntity();
    });

    // DummyJSON answers a wrong username or password with a 400.
    if (result case Err(failure: ServerFailure(statusCode: 400))) {
      return const Err(InvalidCredentialsFailure());
    }
    return result;
  }

  @override
  Future<User?> getSavedUser() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null) return null;
    return _local.getUser()?.toEntity();
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
    await _local.clear();
  }
}
