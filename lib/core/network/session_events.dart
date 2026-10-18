import 'dart:async';

/// Lets the network layer tell the app that the session is over and can't be
/// refreshed, without it knowing anything about the UI.
class SessionEvents {
  final _expired = StreamController<void>.broadcast();

  Stream<void> get expired => _expired.stream;

  void notifyExpired() => _expired.add(null);
}
