import 'dart:async';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class NewZoneNewContextScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setBatchSize(4);
    final span1 = BugsnagPerformance.startSpan('span1');

    runZoned(() {
      final span3 = BugsnagPerformance.startSpan('span3');
      final span4 = BugsnagPerformance.startSpan('span4');
      span4.end();
      span3.end();
    }, zoneValues: {});

    final span2 = BugsnagPerformance.startSpan('span2');
    span2.end();
    span1.end();
  }
}
