part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

final class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.mode);

  final ThemeMode mode;

  @override
  List<Object?> get props => [mode];
}
