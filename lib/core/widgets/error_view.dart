import 'package:flutter/material.dart';

import '../error/failures.dart';
import 'empty_view.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (icon, title) = switch (failure) {
      NetworkFailure() => (Icons.wifi_off_rounded, "You're offline"),
      TimeoutFailure() => (Icons.hourglass_empty_rounded, 'Taking too long'),
      NotFoundFailure() => (Icons.search_off_rounded, 'Not found'),
      UnauthorizedFailure() => (Icons.lock_outline_rounded, 'Session expired'),
      _ => (Icons.cloud_off_rounded, 'Something went wrong'),
    };

    return EmptyView(
      icon: icon,
      title: title,
      message: failure.message,
      actionLabel: 'Try again',
      onAction: onRetry,
    );
  }
}
