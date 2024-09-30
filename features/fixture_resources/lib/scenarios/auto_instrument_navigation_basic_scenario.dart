import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    return const Text('AutoInstrumentNavigationBasicScenario');
  }

  @override
  RouteSettings? routeSettings() {
    return const RouteSettings(name: 'basic_navigation_scenario');
  }
}
