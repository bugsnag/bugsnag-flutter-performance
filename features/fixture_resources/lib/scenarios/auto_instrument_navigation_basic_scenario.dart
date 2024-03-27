import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class AutoInstrumentNavigationBasicScenario extends Scenario {
  @override
  Future<void> run() async {
    setInstrumentsNavigation(true);
    await startBugsnag();
    setMaxBatchSize(1);
  }

  @override
  Widget? createWidget() {
    return Text('AutoInstrumentNavigationBasicScenario');
  }

  @override
  RouteSettings? routeSettings() {
    return RouteSettings(name: 'basic_navigation_scenario');
  }
}
