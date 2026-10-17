import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/auth/data/models/login_response_model.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';

import '../../../../helpers/fixture_reader.dart';

void main() {
  final json = fixture('login_response.json') as Map<String, dynamic>;

  test('parses the tokens and the user from a login response', () {
    final model = LoginResponseModel.fromJson(json);

    expect(model.accessToken, 'test-access-token');
    expect(model.refreshToken, 'test-refresh-token');
    expect(
      model.user.toEntity(),
      const User(
        id: 1,
        username: 'emilys',
        firstName: 'Emily',
        lastName: 'Johnson',
        email: 'emily.johnson@x.dummyjson.com',
        image: 'https://dummyjson.com/icon/emilys/128',
      ),
    );
  });

  test('user survives a toJson/fromJson round trip', () {
    final user = UserModel.fromJson(json);

    expect(UserModel.fromJson(user.toJson()).toEntity(), user.toEntity());
  });

  test('throws when a required field is missing', () {
    final incomplete = Map<String, dynamic>.of(json)..remove('username');

    expect(() => UserModel.fromJson(incomplete), throwsA(isA<TypeError>()));
  });
}
