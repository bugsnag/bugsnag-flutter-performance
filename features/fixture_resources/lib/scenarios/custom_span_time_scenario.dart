import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class CustomSpanTimeScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(1);
    bugsnag_performance
        .startSpan(
      'custom-time',
      startTime: DateTime(1985, 1, 1, 0, 0, 0, 0, 0),
    )
    .end(endTime: DateTime(1986, 1, 1, 0, 0, 0, 0, 0));
  }
}
