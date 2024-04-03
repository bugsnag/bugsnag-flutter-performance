import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class SpanWithNoParentScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(2);

    final parent = bugsnag_performance.startSpan('parent');

    bugsnag_performance.startSpan(
      'no-parent',
      parentContext: BugsnagPerformanceSpanContext.invalid,
    ).end();

    parent.end();
  }
}
