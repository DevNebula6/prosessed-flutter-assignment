import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetSavedUser {
  const GetSavedUser(this._repository);

  final AuthRepository _repository;

  Future<User?> call() => _repository.getSavedUser();
}
