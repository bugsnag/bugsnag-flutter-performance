import 'dart:convert';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';
import 'package:http/http.dart' as http;

class ManualSpanScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnagPerformance.start(apiKey: '12312312312312312312312312312312', endpoint: Uri.parse(FixtureConfig.MAZE_HOST.toString() + '/traces'));
    bugsnagPerformance.setBatchSize(1);
    final span = bugsnagPerformance.startSpan('ManualSpanScenario');
    span.end();
  }
}
