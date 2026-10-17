import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static const _userKey = 'signed_in_user';

  UserModel? getUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveUser(UserModel user) {
    return _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clear() => _prefs.remove(_userKey);
}
