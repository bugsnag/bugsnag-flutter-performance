import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_instrumentation_node.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_instrumentation_phase.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_state.dart';
import 'package:bugsnag_flutter_performance/src/span_attributes.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:bugsnag_flutter_performance/src/widgets/measured_screen/measured_screen_callbacks.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

abstract class NavigationInstrumentation {
  void setEnabled(bool enabled);
  void willShowRoute(
    Route<dynamic>? route,
    String? routeDescription,
  );
  void didStartBuildingScreen(ScreenInstrumentationState state);
  void didFinishBuildingScreen(ScreenInstrumentationState state);
  void didShowScreen(
    ScreenInstrumentationState state, {
    required bool isLoading,
  });
  void didFinishLoadingScreen(ScreenInstrumentationState state);
}

class NavigationInstrumentationImpl implements NavigationInstrumentation {
  final BugsnagPerformanceClient client;
  late final BugsnagClock clock;

  var _enabled = true;

  NavigationInstrumentationImpl({
    required this.client,
    required this.clock,
  }) {
    measuredScreenCallbacks.setup(
      didStartBuildingScreenCallback: didStartBuildingScreen,
      didFinishBuildingScreenCallback: didFinishBuildingScreen,
      didShowScreenCallback: didShowScreen,
      didFinishLoadingScreenCallback: didFinishLoadingScreen,
    );
  }

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  @override
  void willShowRoute(Route? route, String? routeDescription) {
    final startTime = clock.now();
    if (!_enabled || routeDescription == null || route == null) {
      return;
    }
    final node = route.navigator != null
        ? NavigationInstrumentationNode.of(route.navigator!.context)
        : appRootNavigationNode;
    node.routeLoadStartTime = startTime;
    node.currentlyLoadedRoute = route;
    node.isLoadingPhasedRoute = false;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (node.currentlyLoadedRoute == route &&
          !node.isLoadingPhasedRoute &&
          route.isCurrent) {
        final state = ScreenInstrumentationState(
          name: routeDescription,
          startTime: startTime,
        );
        _startNavigationSpan(state);
        if (node.isLoading()) {
          node.addDidFinishLoadingCallback(() {
            _endNavigationSpan(state);
          });
        } else {
          _endNavigationSpan(state);
        }
      }
      node.currentlyLoadedRoute = null;
      node.routeLoadStartTime = null;
      node.isLoadingPhasedRoute = false;
    });
  }

  @override
  void didStartBuildingScreen(ScreenInstrumentationState state) {
    _startNavigationSpan(state);
    _startNavigationPhaseSpan(
      state,
      phase: NavigationInstrumentationPhase.preBuild,
      startTime: state.startTime,
    );
    _endNavigationPhaseSpan(state,
        phase: NavigationInstrumentationPhase.preBuild);
    _startNavigationPhaseSpan(state,
        phase: NavigationInstrumentationPhase.build);
  }

  @override
  void didFinishBuildingScreen(ScreenInstrumentationState state) {
    _endNavigationPhaseSpan(state, phase: NavigationInstrumentationPhase.build);
    _startNavigationPhaseSpan(state,
        phase: NavigationInstrumentationPhase.appearing);
  }

  @override
  void didShowScreen(ScreenInstrumentationState state,
      {required bool isLoading}) {
    _endNavigationPhaseSpan(state,
        phase: NavigationInstrumentationPhase.appearing);
    if (isLoading) {
      _startNavigationPhaseSpan(state,
          phase: NavigationInstrumentationPhase.loading);
    } else {
      _endNavigationSpan(state);
    }
  }

  @override
  void didFinishLoadingScreen(ScreenInstrumentationState state) {
    _endNavigationPhaseSpan(state,
        phase: NavigationInstrumentationPhase.loading);
    _endNavigationSpan(state);
  }

  void _startNavigationSpan(ScreenInstrumentationState state) {
    if (!_enabled || state.viewLoadSpan != null) {
      return;
    }
    state.viewLoadSpan = client.startSpan(
      '[Navigation]/${state.name}',
      parentContext: state.nearestViewLoadSpan(),
      startTime: state.startTime,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'navigation',
      ),
    );
  }

  void _endNavigationSpan(ScreenInstrumentationState state) {
    if (!_enabled) {
      return;
    }
    final span = state.viewLoadSpan;
    if (span != null) {
      span.end();
    }
  }

  void _startNavigationPhaseSpan(
    ScreenInstrumentationState state, {
    required NavigationInstrumentationPhase phase,
    DateTime? startTime,
  }) {
    final parentSpan = state.viewLoadSpan;
    if (!_enabled || parentSpan == null || state.phaseSpans[phase] != null) {
      return;
    }
    state.phaseSpans[phase] =
        client.startSpan('[NavigationPhase/${phase.name()}]/${state.name}',
            parentContext: parentSpan,
            startTime: startTime,
            attributes: BugsnagPerformanceSpanAttributes(
              category: 'navigation_phase',
              phase: phase.name(),
            ));
  }

  void _endNavigationPhaseSpan(
    ScreenInstrumentationState state, {
    required NavigationInstrumentationPhase phase,
  }) {
    final span = state.phaseSpans[phase];
    if (!_enabled || span == null || !span.isOpen()) {
      return;
    }
    span.end();
  }
}
