import 'package:bugsnag_flutter_performance/src/span.dart';

class WidgetInstrumentationState {
  WidgetInstrumentationState({
    required this.name,
    required this.startTime,
    this.parent,
    this.navigatorName,
  });

  final String name;
  final WidgetInstrumentationState? parent;
  final String? navigatorName;

  final DateTime startTime;
  BugsnagPerformanceSpan? viewLoadSpan;

  BugsnagPerformanceSpan? nearestViewLoadSpan() {
    if (viewLoadSpan != null && viewLoadSpan!.isOpen()) {
      return viewLoadSpan;
    }
    return parent?.nearestViewLoadSpan();
  }
}
