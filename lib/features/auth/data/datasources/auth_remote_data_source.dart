import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/login_response_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LoginResponseModel> login(String username, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
        'expiresInMins': ApiEndpoints.tokenLifetimeMinutes,
      },
    );
    return LoginResponseModel.fromJson(response.data!);
  }
}
