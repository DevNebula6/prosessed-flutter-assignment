import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/app/app.dart';
import 'package:shopsphere/app/home_shell.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() async {
    repository = MockAuthRepository();
    when(() => repository.logout()).thenAnswer((_) async {});
    await registerFakeDependencies(auth: repository);
  });

  void stubLogin(String password, Result<User> result) {
    when(() => repository.login(username: 'emilys', password: password))
        .thenAnswer((_) async => result);
  }

  testWidgets('opens home directly when a session is stored', (tester) async {
    when(() => repository.getSavedUser()).thenAnswer((_) async => testUser);

    await tester.pumpWidget(const ShopSphereApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('validates, shows invalid credentials, then signs in', (
    tester,
  ) async {
    when(() => repository.getSavedUser()).thenAnswer((_) async => null);
    stubLogin('wrongpass', const Err(InvalidCredentialsFailure()));
    stubLogin('emilyspass', const Ok(testUser));

    await tester.pumpWidget(const ShopSphereApp());
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'emilys');
    await tester.enterText(fields.at(1), 'wrongpass');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid username or password.'), findsOneWidget);

    await tester.enterText(fields.at(1), 'emilyspass');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });
}
