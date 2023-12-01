import 'package:bugsnag_flutter_performance/src/span.dart';

abstract class BugsnagPerformanceSpanContextStack {
  BugsnagPerformanceSpanContext? getCurrentContext();
  void pushContext(BugsnagPerformanceSpanContext context);
}

class BugsnagPerformanceSpanContextStackImpl
    implements BugsnagPerformanceSpanContextStack {
  final List<BugsnagPerformanceSpanContext> _stack = [];

  @override
  BugsnagPerformanceSpanContext? getCurrentContext() {
    _clearClosedSpans();
    if (_stack.isEmpty) {
      return null;
    }
    return _stack.last;
  }

  @override
  void pushContext(BugsnagPerformanceSpanContext context) {
    _stack.add(context);
  }

  void _clearClosedSpans() {
    _stack.removeWhere((span) => !span.isOpen());
  }
}

abstract class BugsnagPerformanceSpanContext {
  TraceId get traceId;
  SpanId get spanId;
  bool isOpen();
}
