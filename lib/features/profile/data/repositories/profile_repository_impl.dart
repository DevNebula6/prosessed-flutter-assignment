import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Result<UserProfile>> getProfile() {
    return guard(() async {
      final profile = await _remote.getProfile();
      return profile.toEntity();
    });
  }
}
