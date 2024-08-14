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
  BugsnagPerformanceSpan? navigationSpan;

  BugsnagPerformanceSpan? nearestNavigationSpan() {
    if (navigationSpan != null && navigationSpan!.isOpen()) {
      return navigationSpan;
    }
    return parent?.nearestNavigationSpan();
  }
}
