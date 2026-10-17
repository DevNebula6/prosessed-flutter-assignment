import '../../../../core/error/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<Result<User>> login({
    required String username,
    required String password,
  });

  /// The user from the last login, or null when there is no stored session.
  Future<User?> getSavedUser();

  Future<void> logout();
}
