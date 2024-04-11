import 'dart:async';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class PassContextToNewZoneScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(3);
    final span1 = bugsnag_performance.startSpan('span1');
    runZoned(() {
      final span2 =
          bugsnag_performance.startSpan('span2', parentContext: span1);
      final span3 = bugsnag_performance.startSpan('span3');
      span2.end();
      span3.end();
    }, zoneValues: {});
    await Future.delayed(const Duration(milliseconds: 1000));
    span1.end();
  }
}
