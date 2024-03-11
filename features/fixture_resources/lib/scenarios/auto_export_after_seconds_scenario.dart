import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class AutoExportAfterSecondsScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchAge(5000);
    final span = BugsnagPerformance.startSpan('AutoExportAfterSecondsScenario');
    span.end();
  }
}
