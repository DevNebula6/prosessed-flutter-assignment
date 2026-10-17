part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// The stored session hasn't been checked yet.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated({this.message});

  /// Why the user was signed out, when it wasn't their own choice.
  final String? message;

  @override
  List<Object?> get props => [message];
}
