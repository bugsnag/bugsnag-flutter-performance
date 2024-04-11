import 'dart:async';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class MakeCurrentContextScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(3);
    final span1 = bugsnag_performance.startSpan('span1');
    final span2 =
        bugsnag_performance.startSpan('span2', makeCurrentContext: false);
    final span3 = bugsnag_performance.startSpan('span3');
    span3.end();
    span2.end();
    span1.end();
  }
}
