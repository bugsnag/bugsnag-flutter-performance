import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class CorrelationNullScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
      shouldUseNotifier: true,
    );
    setMaxBatchSize(1);

    final span = bugsnag_performance.startSpan('Span 1');
    span.end();
    await bugsnag.notify(Exception('CorrelationNullScenario'), null);
  }
}
