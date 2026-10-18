import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/theme_storage.dart';

part 'theme_event.dart';

/// The light / dark / system choice, remembered between launches.
class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc(this._storage) : super(_storage.read()) {
    on<ThemeModeChanged>(_onModeChanged);
  }

  final ThemeStorage _storage;

  Future<void> _onModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeMode> emit,
  ) async {
    emit(event.mode);
    await _storage.write(event.mode);
  }
}
