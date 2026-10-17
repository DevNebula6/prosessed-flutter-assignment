import 'package:equatable/equatable.dart';

/// A user-facing error returned by repositories instead of throwing.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure()
    : super('No internet connection. Check your network and try again.');
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure()
    : super('The server is taking too long to respond. Please try again.');
}

final class ServerFailure extends Failure {
  const ServerFailure([this.statusCode])
    : super('Something went wrong. Please try again.');

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure()
    : super("We couldn't find what you were looking for.");
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
    : super('Your session has expired. Please sign in again.');
}

final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('Invalid username or password.');
}

final class ParseFailure extends Failure {
  const ParseFailure()
    : super('We received an unexpected response. Please try again.');
}

final class UnknownFailure extends Failure {
  const UnknownFailure()
    : super('Something unexpected happened. Please try again.');
}
