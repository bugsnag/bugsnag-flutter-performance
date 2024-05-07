import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';

class ViewLoadInstrumentationState {
  ViewLoadInstrumentationState({
    required this.name,
    required this.startTime,
  });

  final String name;

  final DateTime startTime;
  BugsnagPerformanceSpan? viewLoadSpan;
  BugsnagPerformanceSpan? buildingSpan;
  BugsnagPerformanceSpan? appearingSpan;
  BugsnagPerformanceSpan? loadingSpan;
}
