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
  });

  AuthCubit buildCubit() {
    return AuthCubit(
      getSavedUser: getSavedUser,
      logout: logout,
      sessionExpired: const Stream.empty(),
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
    setUp: () => when(() => logout()).thenAnswer((_) async {}),
    build: buildCubit,
    seed: () => const Authenticated(user),
    act: (cubit) => cubit.logout(),
    expect: () => [const Unauthenticated()],
    verify: (_) => verify(() => logout()).called(1),
  );
}
