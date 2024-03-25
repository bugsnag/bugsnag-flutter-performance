import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_instrumentation_node.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/widget_instrumentation_state.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';
import 'package:bugsnag_flutter_performance/src/span_attributes.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

abstract class NavigationInstrumentation {
  void setEnabled(bool enabled);
  void didPushNewRoute(
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
    String? navigatorName,
  );
  void didReplaceRoute(
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
    String? navigatorName,
  );
  void didRemoveRoute(
    Route<dynamic>? shownRoute,
    Route<dynamic>? removedRoute,
    String? navigatorName,
  );
  void didPopRoute(
    Route<dynamic>? shownRoute,
    Route<dynamic>? poppedRoute,
    String? navigatorName,
  );
}

class NavigationInstrumentationImpl implements NavigationInstrumentation {
  final BugsnagPerformanceClient client;
  late final BugsnagClock clock;

  var _enabled = true;

  NavigationInstrumentationImpl({
    required this.client,
    required this.clock,
  });

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  @override
  void didPushNewRoute(
    Route? route,
    Route? previousRoute,
    String? navigatorName,
  ) {
    _willShowRoute(
      route,
      previousRoute,
      navigatorName,
      'push',
    );
  }

  @override
  void didReplaceRoute(
    Route? route,
    Route? previousRoute,
    String? navigatorName,
  ) {
    _willShowRoute(
      route,
      previousRoute,
      navigatorName,
      'replace',
    );
  }

  @override
  void didRemoveRoute(
    Route? shownRoute,
    Route? removedRoute,
    String? navigatorName,
  ) {
    _willShowRoute(
      shownRoute,
      removedRoute,
      navigatorName,
      'remove',
    );
  }

  @override
  void didPopRoute(
    Route? shownRoute,
    Route? poppedRoute,
    String? navigatorName,
  ) {
    _willShowRoute(
      shownRoute,
      poppedRoute,
      navigatorName,
      'pop',
    );
  }

  void _willShowRoute(
    Route? route,
    Route? previousRoute,
    String? navigatorName,
    String triggeredBy,
  ) {
    final startTime = clock.now();
    final name = route?.settings.name;
    if (!_enabled || route == null || name == null) {
      return;
    }
    final node = route.navigator != null
        ? WidgetInstrumentationNode.of(route.navigator!.context)
        : appRootInstrumentationNode;
    final state = WidgetInstrumentationState(
      name: name,
      startTime: startTime,
      navigatorName: navigatorName,
    );
    node.state = state;
    _startNavigationSpan(
      state,
      triggeredBy: triggeredBy,
      previousRoute: previousRoute?.settings.name,
    );

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (!route.isCurrent) {
        return;
      }
      if (node.isLoading()) {
        node.addDidFinishLoadingCallback(() {
          if (!route.isCurrent) {
            return;
          }
          _endNavigationSpan(state, didFinishLoading: true);
        });
      } else {
        _endNavigationSpan(state, didFinishLoading: false);
      }
    });
  }

  void _startNavigationSpan(
    WidgetInstrumentationState state, {
    required String triggeredBy,
    String? previousRoute,
  }) {
    if (!_enabled || state.viewLoadSpan != null) {
      return;
    }
    final name = state.navigatorName != null
        ? '[Navigation]/${state.navigatorName}/${state.name}'
        : '[Navigation]/${state.name}';
    state.viewLoadSpan = client.startSpan(
      name,
      parentContext: state.nearestViewLoadSpan(),
      startTime: state.startTime,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'navigation',
        additionalAttributes: {
          'bugsnag.navigation.route': state.name,
          'bugsnag.navigation.navigator': state.navigatorName,
          'bugsnag.navigation.triggered_by': triggeredBy,
          'bugsnag.navigation.previous_route': previousRoute,
        },
      ),
    );
  }

  void _endNavigationSpan(
    WidgetInstrumentationState state, {
    bool didFinishLoading = false,
  }) {
    if (!_enabled) {
      return;
    }
    final span = state.viewLoadSpan;
    if (span is BugsnagPerformanceSpanImpl) {
      span.attributes.setAttribute(
        'bugsnag.navigation.ended_by',
        didFinishLoading ? 'loading_indicator' : 'frame_render',
      );
    }
    if (span != null) {
      span.end();
    }
  }
}
