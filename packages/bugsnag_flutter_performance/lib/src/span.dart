abstract class BugsnagPerformanceSpan {
  void end();
}

class BugsnagPerformanceSpanImpl implements BugsnagPerformanceSpan {

  BugsnagPerformanceSpanImpl({required this.name, required this.startTime});
  final DateTime startTime;
  final String name;
  DateTime? endTime;

  @override
  void end() {
    endTime = DateTime.now();
  }
}