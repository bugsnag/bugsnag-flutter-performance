import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class CorrelationSimpleScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
      shouldUseNotifier: true,
    );
    setMaxBatchSize(1);

    final span = bugsnag_performance.startSpan('Span 1');
    await bugsnag.notify(Exception('CorrelationSimpleScenario'), null);
    span.end();
  }
}
