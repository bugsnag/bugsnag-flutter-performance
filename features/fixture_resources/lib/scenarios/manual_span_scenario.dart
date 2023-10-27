import 'dart:convert';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';
import 'package:http/http.dart' as http;

class ManualSpanScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnagPerformance.setBatchSize(1);
    final span = bugsnagPerformance.startSpan('ManualSpanScenario');
    span.end();
  }
}
