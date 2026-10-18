import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorage {
  ThemeStorage(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static const _themeModeKey = 'theme_mode';

  /// Follows the system until the user picks something.
  ThemeMode read() {
    final name = _prefs.getString(_themeModeKey);
    return ThemeMode.values.asNameMap()[name] ?? ThemeMode.system;
  }

  Future<void> write(ThemeMode mode) {
    return _prefs.setString(_themeModeKey, mode.name);
  }
}
