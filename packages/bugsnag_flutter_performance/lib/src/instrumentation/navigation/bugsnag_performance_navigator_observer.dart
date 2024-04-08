import 'package:flutter/widgets.dart';

import 'bugsnag_performance_navigator_observer_callbacks.dart';

class BugsnagPerformanceNavigatorObserver extends NavigatorObserver {
  final String? navigatorName;

  /// Create and configure a `BugsnagPerformanceNavigatorObserver` to listen for navigation
  /// events.
  ///
  /// Typically you will configure this in you `MaterialApp`, `CupertinoApp`
  /// or `Navigator`:
  /// ```dart
  /// return MaterialApp(
  ///   navigatorObservers: [BugsnagPerformanceNavigatorObserver()],
  ///   initialRoute: '/',
  ///   routes: {
  ///     '/': (context) => const AppHomeWidget(),
  /// ```
  BugsnagPerformanceNavigatorObserver({
    this.navigatorName,
  });

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    callbacks.didReplaceRoute(
      newRoute: newRoute,
      previousRoute: oldRoute,
      navigatorName: navigatorName,
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    callbacks.didRemoveRoute(
      newRoute: previousRoute,
      previousRoute: route,
      navigatorName: navigatorName,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    callbacks.didPopRoute(
      newRoute: previousRoute,
      previousRoute: route,
      navigatorName: navigatorName,
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    callbacks.didPushNewRoute(
      newRoute: route,
      previousRoute: previousRoute,
      navigatorName: navigatorName,
    );
  }
}
