import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/storage/theme_storage.dart';
import 'package:shopsphere/core/theme/theme_bloc.dart';

class MockThemeStorage extends Mock implements ThemeStorage {}

void main() {
  late MockThemeStorage storage;

  setUpAll(() => registerFallbackValue(ThemeMode.system));

  setUp(() {
    storage = MockThemeStorage();
    when(() => storage.read()).thenReturn(ThemeMode.system);
    when(() => storage.write(any())).thenAnswer((_) async {});
  });

  test('starts with the saved choice', () {
    when(() => storage.read()).thenReturn(ThemeMode.dark);

    expect(ThemeBloc(storage).state, ThemeMode.dark);
  });

  blocTest<ThemeBloc, ThemeMode>(
    'switches the theme and remembers it',
    build: () => ThemeBloc(storage),
    act: (bloc) => bloc.add(const ThemeModeChanged(ThemeMode.light)),
    expect: () => [ThemeMode.light],
    verify: (_) => verify(() => storage.write(ThemeMode.light)).called(1),
  );
}
