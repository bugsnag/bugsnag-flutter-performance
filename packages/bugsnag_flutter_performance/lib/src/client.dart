import 'configuration.dart';
import 'span.dart';

abstract class BugsnagPerformance {
  Future<void> start({String? apiKey, Uri? endpoint});
  BugsnagPerformanceSpan startSpan(String name, {DateTime? startTime});
}

class BugsnagPerformanceClient implements BugsnagPerformance {
  BugsnagPerformanceConfiguration? configuration;
  @override
  Future<void> start({String? apiKey, Uri? endpoint}) async {
    configuration = BugsnagPerformanceConfiguration(
      apiKey: apiKey,
      endpoint: endpoint,
    );
  }

  @override
  BugsnagPerformanceSpan startSpan(String name, {DateTime? startTime}) {
    return BugsnagPerformanceSpanImpl(
        name: name, startTime: startTime ?? DateTime.now());
  }
}
