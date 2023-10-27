import 'dart:convert';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';
import 'package:http/http.dart' as http;

const apiKey = '0123456789abcdef0123456789abcdef';

class ManualSpanScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnagPerformance.start(
        apiKey: '0123456789abcdef0123456789abcdef',
        endpoint: Uri.parse(
            "https://webhook.site/9d5c4637-681b-426c-b52d-5440f83f6472"));
    bugsnagPerformance.setBatchSize(1);
    final span = bugsnagPerformance.startSpan('ManualSpanScenario');
    span.end();
  }
}
