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
      startTime: DateTime.fromMicrosecondsSinceEpoch(473385600000000, isUtc: true)
    )
    .end(endTime: DateTime.fromMicrosecondsSinceEpoch(504921600000000, isUtc: true));
  }
}
