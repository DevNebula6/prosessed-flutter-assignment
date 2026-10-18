import '../../../../core/error/result.dart';
import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  /// The signed-in user, fresh from the server.
  Future<Result<UserProfile>> getProfile();
}
