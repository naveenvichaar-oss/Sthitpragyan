import 'package:flutter/material.dart';

/// AppNavigator provides a unified, top-level navigator key for reactive
/// navigation and modal presentation from background services and intent receivers.
class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Convenience getter for current top-level context
  static BuildContext? get currentContext => navigatorKey.currentContext;
}
