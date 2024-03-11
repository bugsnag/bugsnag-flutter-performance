import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class AutoInstrumentNavigationBasicScenario extends Scenario {
  @override
  Future<void> run() async {
    BugsnagPerformance.setExtraConfig("instrumentAppStart", false);
    BugsnagPerformance.setExtraConfig("instrumentNavigation", true);
    BugsnagPerformance.setExtraConfig("probabilityValueExpireTime", 1000);
    BugsnagPerformance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse(FixtureConfig.MAZE_HOST.toString() + '/traces'));
    setMaxBatchSize(1);
  }

  @override
  Widget? createWidget() {
    return Text('AutoInstrumentNavigationBasicScenario');
  }

  @override
  RouteSettings? routeSettings() {
    return RouteSettings(name: 'AutoInstrumentNavigationBasicScenarioScreen');
  }
}
