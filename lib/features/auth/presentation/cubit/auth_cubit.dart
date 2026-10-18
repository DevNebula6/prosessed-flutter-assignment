import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_saved_user.dart';
import '../../domain/usecases/logout.dart';

part 'auth_state.dart';

/// App-wide session state. The root listener routes on its changes.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this._getSavedUser,
    required this._logout,
    required Stream<void> sessionExpired,
  }) : super(const AuthInitial()) {
    _sessionExpiredSubscription = sessionExpired.listen(
      (_) => _onSessionExpired(),
    );
  }

  final GetSavedUser _getSavedUser;
  final Logout _logout;
  late final StreamSubscription<void> _sessionExpiredSubscription;

  Future<void> checkSession() async {
    final user = await _getSavedUser();
    emit(user == null ? const Unauthenticated() : Authenticated(user));
  }

  void loggedIn(User user) => emit(Authenticated(user));

  Future<void> logout() async {
    await _logout();
    emit(const Unauthenticated());
  }

  Future<void> _onSessionExpired() async {
    // A late 401 after signing out has nothing left to end.
    if (state is! Authenticated) return;

    await _logout();
    emit(Unauthenticated(message: const UnauthorizedFailure().message));
  }

  @override
  Future<void> close() async {
    await _sessionExpiredSubscription.cancel();
    return super.close();
  }
}
