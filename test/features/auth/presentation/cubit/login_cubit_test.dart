import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/usecases/login.dart';
import 'package:shopsphere/features/auth/presentation/cubit/login_cubit.dart';

class MockLogin extends Mock implements Login {}

void main() {
  late MockLogin login;

  const user = User(
    id: 1,
    username: 'emilys',
    firstName: 'Emily',
    lastName: 'Johnson',
    email: 'emily.johnson@x.dummyjson.com',
    image: 'https://dummyjson.com/icon/emilys/128',
  );

  setUp(() => login = MockLogin());

  void stubLogin(Result<User> result) {
    when(
      () => login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => result);
  }

  blocTest<LoginCubit, LoginState>(
    'emits loading then success for valid credentials',
    setUp: () => stubLogin(const Ok(user)),
    build: () => LoginCubit(login),
    act: (cubit) => cubit.submit(username: 'emilys', password: 'emilyspass'),
    expect: () => [const LoginLoading(), const LoginSuccess(user)],
  );

  blocTest<LoginCubit, LoginState>(
    'emits loading then the failure message for invalid credentials',
    setUp: () => stubLogin(const Err(InvalidCredentialsFailure())),
    build: () => LoginCubit(login),
    act: (cubit) => cubit.submit(username: 'emilys', password: 'wrong'),
    expect: () => [
      const LoginLoading(),
      const LoginError('Invalid username or password.'),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'ignores a submit while a login is already running',
    build: () => LoginCubit(login),
    seed: () => const LoginLoading(),
    act: (cubit) => cubit.submit(username: 'emilys', password: 'emilyspass'),
    expect: () => <LoginState>[],
    verify: (_) => verifyNever(
      () => login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ),
  );
}
