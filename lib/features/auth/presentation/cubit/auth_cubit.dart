import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_saved_user.dart';
import '../../domain/usecases/logout.dart';

part 'auth_state.dart';

/// App-wide session state. The root listener routes on its changes.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this._getSavedUser, required this._logout})
    : super(const AuthInitial());

  final GetSavedUser _getSavedUser;
  final Logout _logout;

  Future<void> checkSession() async {
    final user = await _getSavedUser();
    emit(user == null ? const Unauthenticated() : Authenticated(user));
  }

  void loggedIn(User user) => emit(Authenticated(user));

  Future<void> logout() async {
    await _logout();
    emit(const Unauthenticated());
  }
}
