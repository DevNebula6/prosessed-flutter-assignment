abstract final class Validators {
  static String? username(String? value) {
    final username = value?.trim() ?? '';
    if (username.isEmpty) return 'Enter your username';
    if (username.length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
