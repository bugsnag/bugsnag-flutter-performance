import 'dart:async';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class NewZoneNewContextScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(4);
    final span1 = bugsnag_performance.startSpan('span1');

    runZoned(() {
      final span3 = bugsnag_performance.startSpan('span3');
      final span4 = bugsnag_performance.startSpan('span4');
      span4.end();
      span3.end();
    }, zoneValues: {});

    final span2 = bugsnag_performance.startSpan('span2');
    span2.end();
    span1.end();
  }
}
