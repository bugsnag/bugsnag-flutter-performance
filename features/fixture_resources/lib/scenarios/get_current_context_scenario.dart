

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class GetCurrentContextScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(3);
    if(bugsnag_performance.getCurrentSpanContext() == null) {
      doSimpleSpan('part 1: null');
    }

    final span1 = bugsnag_performance.startSpan('context');
    if(bugsnag_performance.getCurrentSpanContext() == null) {
      doSimpleSpan('part 2: not null');
    }
  }
}
