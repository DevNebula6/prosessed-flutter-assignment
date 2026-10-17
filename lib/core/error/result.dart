import 'package:equatable/equatable.dart';

import 'failures.dart';

/// The outcome of an operation that can fail: either [Ok] or [Err].
sealed class Result<T> extends Equatable {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
