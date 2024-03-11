import 'dart:convert';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';
import 'package:http/http.dart' as http;

class ProbabilityExpiryScenario extends Scenario {
  @override
  Future<void> run() async {
    BugsnagPerformance.setExtraConfig("instrumentAppStart", false);
    BugsnagPerformance.setExtraConfig("probabilityRequestsPause", 100);
    BugsnagPerformance.setExtraConfig("probabilityValueExpireTime", 100);
    BugsnagPerformance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse(FixtureConfig.MAZE_HOST.toString() + '/traces'));
    setMaxBatchSize(1);
    await Future.delayed(Duration(milliseconds: 500));
    final span = BugsnagPerformance.startSpan('myspan');
    span.end();
  }
}
