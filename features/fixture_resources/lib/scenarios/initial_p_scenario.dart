import 'dart:convert';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';
import 'package:http/http.dart' as http;

class InitialPScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnag_performance.setExtraConfig("instrumentAppStart", false);
    bugsnag_performance.setExtraConfig("instrumentNavigation", false);
    bugsnag_performance.setExtraConfig("probabilityRequestsPause", 1000);
    bugsnag_performance.setExtraConfig("probabilityValueExpireTime", 25000);
    bugsnag_performance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse(FixtureConfig.MAZE_HOST.toString() + '/traces'));
    setMaxBatchSize(1);
    doSimpleSpan('First');
  }

  void step2() {
    doSimpleSpan('Second');
  }

  @override
  void invokeMethod(String name) {
    switch (name) {
      case 'step2':
        step2();
        break;
      default:
        break;
    }
  }
}
