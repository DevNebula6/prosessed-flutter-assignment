import 'package:flutter/material.dart';

/// Lets the root auth listener navigate from above the [Navigator].
final navigatorKey = GlobalKey<NavigatorState>();

/// Lets the root auth listener show a message on whichever page is open.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
