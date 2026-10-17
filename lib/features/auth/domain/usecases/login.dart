import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Login {
  const Login(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call({
    required String username,
    required String password,
  }) {
    // Usernames never contain spaces, but keyboards like to add a trailing one.
    return _repository.login(username: username.trim(), password: password);
  }
}
