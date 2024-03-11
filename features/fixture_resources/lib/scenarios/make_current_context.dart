import 'dart:async';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class MakeCurrentContextScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(3);
    final span1 = BugsnagPerformance.startSpan('span1');
    final span2 =
        BugsnagPerformance.startSpan('span2', makeCurrentContext: false);
    final span3 = BugsnagPerformance.startSpan('span3');
    span3.end();
    span2.end();
    span1.end();
  }
}
