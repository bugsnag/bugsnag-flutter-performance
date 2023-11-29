import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class ManualSpanScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setBatchSize(1);
    final span = BugsnagPerformance.startSpan('ManualSpanScenario');
    span.end();
  }
}
