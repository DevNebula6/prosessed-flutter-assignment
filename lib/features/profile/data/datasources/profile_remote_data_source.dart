import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/user_profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dio);

  final Dio _dio;

  /// Needs a valid access token, which the auth interceptor adds.
  Future<UserProfileModel> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
    return UserProfileModel.fromJson(response.data!);
  }
}
