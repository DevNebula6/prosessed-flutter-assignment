import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._login) : super(const LoginInitial());

  final Login _login;

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    if (state is LoginLoading) return;

    emit(const LoginLoading());
    final result = await _login(username: username, password: password);
    emit(switch (result) {
      Ok(:final value) => LoginSuccess(value),
      Err(:final failure) => LoginError(failure.message),
    });
  }
}
