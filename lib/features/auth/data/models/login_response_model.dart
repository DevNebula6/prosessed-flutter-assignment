import 'user_model.dart';

/// `POST /auth/login` returns the tokens and the user fields in one object.
class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json),
    );
  }

  final String accessToken;
  final String refreshToken;
  final UserModel user;
}
