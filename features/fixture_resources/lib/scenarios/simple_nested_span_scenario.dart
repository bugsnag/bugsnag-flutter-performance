import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class SimpleNestedSpanScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(2);
    final span1 = bugsnag_performance.startSpan('span1');
    final span2 = bugsnag_performance.startSpan('span2');
    span2.end();
    span1.end();
  }
}
