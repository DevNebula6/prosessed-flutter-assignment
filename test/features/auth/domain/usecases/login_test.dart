import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/login.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const user = User(
    id: 1,
    username: 'emilys',
    firstName: 'Emily',
    lastName: 'Johnson',
    email: 'emily.johnson@x.dummyjson.com',
    image: 'https://dummyjson.com/icon/emilys/128',
  );

  test('trims the username but leaves the password untouched', () async {
    final repository = MockAuthRepository();
    when(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Ok(user));

    final result = await Login(repository)(
      username: '  emilys ',
      password: ' emilyspass ',
    );

    expect(result, const Ok(user));
    verify(() => repository.login(username: 'emilys', password: ' emilyspass '))
        .called(1);
  });
}
