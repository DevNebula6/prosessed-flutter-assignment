import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/usecases/get_saved_user.dart';
import 'package:shopsphere/features/auth/domain/usecases/logout.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';

class MockGetSavedUser extends Mock implements GetSavedUser {}

class MockLogout extends Mock implements Logout {}

void main() {
  late MockGetSavedUser getSavedUser;
  late MockLogout logout;
  late StreamController<void> sessionExpired;

  const user = User(
    id: 1,
    username: 'emilys',
    firstName: 'Emily',
    lastName: 'Johnson',
    email: 'emily.johnson@x.dummyjson.com',
    image: 'https://dummyjson.com/icon/emilys/128',
  );

  setUp(() {
    getSavedUser = MockGetSavedUser();
    logout = MockLogout();
    sessionExpired = StreamController<void>();
    when(() => logout()).thenAnswer((_) async {});
  });

  tearDown(() => sessionExpired.close());

  AuthCubit buildCubit() {
    return AuthCubit(
      getSavedUser: getSavedUser,
      logout: logout,
      sessionExpired: sessionExpired.stream,
    );
  }

  test('starts in AuthInitial', () {
    expect(buildCubit().state, const AuthInitial());
  });

  blocTest<AuthCubit, AuthState>(
    'checkSession emits Authenticated when a session is stored',
    setUp: () => when(() => getSavedUser()).thenAnswer((_) async => user),
    build: buildCubit,
    act: (cubit) => cubit.checkSession(),
    expect: () => [const Authenticated(user)],
  );

  blocTest<AuthCubit, AuthState>(
    'checkSession emits Unauthenticated when there is no session',
    setUp: () => when(() => getSavedUser()).thenAnswer((_) async => null),
    build: buildCubit,
    act: (cubit) => cubit.checkSession(),
    expect: () => [const Unauthenticated()],
  );

  blocTest<AuthCubit, AuthState>(
    'loggedIn emits Authenticated',
    build: buildCubit,
    act: (cubit) => cubit.loggedIn(user),
    expect: () => [const Authenticated(user)],
  );

  blocTest<AuthCubit, AuthState>(
    'logout clears the session and emits Unauthenticated',
    build: buildCubit,
    seed: () => const Authenticated(user),
    act: (cubit) => cubit.logout(),
    expect: () => [const Unauthenticated()],
    verify: (_) => verify(() => logout()).called(1),
  );

  blocTest<AuthCubit, AuthState>(
    'signs out with a message when the session expires',
    build: buildCubit,
    seed: () => const Authenticated(user),
    act: (_) => sessionExpired.add(null),
    expect: () => [
      const Unauthenticated(
        message: 'Your session has expired. Please sign in again.',
      ),
    ],
    verify: (_) => verify(() => logout()).called(1),
  );

  blocTest<AuthCubit, AuthState>(
    'ignores an expired session once already signed out',
    build: buildCubit,
    seed: () => const Unauthenticated(),
    act: (_) => sessionExpired.add(null),
    expect: () => <AuthState>[],
    verify: (_) => verifyNever(() => logout()),
  );
}
