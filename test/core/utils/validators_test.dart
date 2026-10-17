import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/utils/validators.dart';

void main() {
  group('username', () {
    test('is required', () {
      for (final value in [null, '', '   ']) {
        expect(Validators.username(value), 'Enter your username');
      }
    });

    test('needs at least 3 characters', () {
      expect(
        Validators.username('ab'),
        'Username must be at least 3 characters',
      );
    });

    test('accepts a valid username, ignoring surrounding spaces', () {
      expect(Validators.username('emilys'), isNull);
      expect(Validators.username(' emilys '), isNull);
    });
  });

  group('password', () {
    test('is required', () {
      expect(Validators.password(null), 'Enter your password');
      expect(Validators.password(''), 'Enter your password');
    });

    test('needs at least 6 characters', () {
      expect(
        Validators.password('12345'),
        'Password must be at least 6 characters',
      );
    });

    test('accepts a valid password', () {
      expect(Validators.password('emilyspass'), isNull);
    });
  });
}
