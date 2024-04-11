import 'package:flutter/widgets.dart';

typedef WillShowNewRouteCallback = Function(
  Route<dynamic>? newRoute,
  Route<dynamic>? previousRoute,
  String? navigatorName,
);

class BugsnagPerformanceNavigatorObserverCallbacks {
  WillShowNewRouteCallback? _didPushNewRouteCallback;
  WillShowNewRouteCallback? _didReplaceRouteCallback;
  WillShowNewRouteCallback? _didRemoveRouteCallback;
  WillShowNewRouteCallback? _didPopRouteCallback;

  void didPushNewRoute({
    Route<dynamic>? newRoute,
    Route<dynamic>? previousRoute,
    String? navigatorName,
  }) {
    if (_didPushNewRouteCallback != null) {
      _didPushNewRouteCallback!(
        newRoute,
        previousRoute,
        navigatorName,
      );
    }
  }

  void didReplaceRoute({
    Route<dynamic>? newRoute,
    Route<dynamic>? previousRoute,
    String? navigatorName,
  }) {
    if (_didReplaceRouteCallback != null) {
      _didReplaceRouteCallback!(
        newRoute,
        previousRoute,
        navigatorName,
      );
    }
  }

  void didRemoveRoute({
    Route<dynamic>? newRoute,
    Route<dynamic>? previousRoute,
    String? navigatorName,
  }) {
    if (_didRemoveRouteCallback != null) {
      _didRemoveRouteCallback!(
        newRoute,
        previousRoute,
        navigatorName,
      );
    }
  }

  void didPopRoute({
    Route<dynamic>? newRoute,
    Route<dynamic>? previousRoute,
    String? navigatorName,
  }) {
    if (_didPopRouteCallback != null) {
      _didPopRouteCallback!(
        newRoute,
        previousRoute,
        navigatorName,
      );
    }
  }

  static setup({
    WillShowNewRouteCallback? didPushNewRouteCallback,
    WillShowNewRouteCallback? didReplaceRouteCallback,
    WillShowNewRouteCallback? didRemoveRouteCallback,
    WillShowNewRouteCallback? didPopRouteCallback,
  }) {
    if (didPushNewRouteCallback != null) {
      callbacks._didPushNewRouteCallback = didPushNewRouteCallback;
    }
    if (didReplaceRouteCallback != null) {
      callbacks._didReplaceRouteCallback = didReplaceRouteCallback;
    }
    if (didRemoveRouteCallback != null) {
      callbacks._didRemoveRouteCallback = didRemoveRouteCallback;
    }
    if (didPopRouteCallback != null) {
      callbacks._didPopRouteCallback = didPopRouteCallback;
    }
  }
}

final callbacks = BugsnagPerformanceNavigatorObserverCallbacks();
