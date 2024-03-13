import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_instrumentation_phase.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';

class ScreenInstrumentationState {
  ScreenInstrumentationState({
    required this.name,
    required this.startTime,
    this.parent,
  });

  final String name;
  final ScreenInstrumentationState? parent;

  final DateTime startTime;
  final Map<NavigationInstrumentationPhase, BugsnagPerformanceSpan> phaseSpans =
      {};
  BugsnagPerformanceSpan? viewLoadSpan;

  BugsnagPerformanceSpan? nearestViewLoadSpan() {
    if (viewLoadSpan != null && viewLoadSpan!.isOpen()) {
      return viewLoadSpan;
    }
    if (parent == null) {
      return null;
    }
    return parent!.nearestViewLoadSpan();
  }
}
