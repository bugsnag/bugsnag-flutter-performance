import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class ManualSpanIsFirstClassFalseScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(1);
    bugsnag_performance
        .startSpan(
          'ManualSpanIsFirstClassFalseScenario',
          isFirstClass: false,
        )
        .end();
  }
}
