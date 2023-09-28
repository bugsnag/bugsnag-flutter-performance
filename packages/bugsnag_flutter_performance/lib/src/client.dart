import 'configuration.dart';
import 'span.dart';

abstract class BugsnagPerformance {
  Future<void> start({BugsnagPerformanceConfiguration? configuration});
  BugsnagPerformanceSpan startSpan(String name, {DateTime? startTime});
}

class BugsnagPerformanceClient implements BugsnagPerformance {

  BugsnagPerformanceConfiguration? _configuration;
  @override
  Future<void> start({BugsnagPerformanceConfiguration? configuration}) async {
    _configuration = configuration;
  }

  @override
  BugsnagPerformanceSpan startSpan(String name, {DateTime? startTime}) {
    return BugsnagPerformanceSpanImpl(name: name, startTime: startTime ?? DateTime.now());
  }

}