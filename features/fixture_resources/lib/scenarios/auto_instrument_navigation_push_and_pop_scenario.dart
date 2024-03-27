import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class AutoInstrumentNavigationPushAndPopScenario extends Scenario {
  final _key =
      GlobalKey<AutoInstrumentNavigationPushAndPopScenarioScreenState>();

  @override
  Future<void> run() async {
    setInstrumentsNavigation(true);
    await startBugsnag();
    setMaxBatchSize(1);
  }

  @override
  Widget? createWidget() {
    return AutoInstrumentNavigationPushAndPopScenarioScreen(
      key: _key,
      runCommandCallback: () => runCommandCallback!(),
    );
  }

  @override
  RouteSettings? routeSettings() {
    return const RouteSettings(name: 'push_and_pop_scenario');
  }

  void step2() {
    Navigator.of(_key.currentContext!).pop();
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

class AutoInstrumentNavigationPushAndPopScenarioScreen extends StatefulWidget {
  const AutoInstrumentNavigationPushAndPopScenarioScreen({
    super.key,
    required this.runCommandCallback,
  });
  final void Function() runCommandCallback;

  @override
  State<AutoInstrumentNavigationPushAndPopScenarioScreen> createState() =>
      AutoInstrumentNavigationPushAndPopScenarioScreenState();
}

class AutoInstrumentNavigationPushAndPopScenarioScreenState
    extends State<AutoInstrumentNavigationPushAndPopScenarioScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: Text('AutoInstrumentNavigationPushAndPopScenarioScreen'),
        color: Colors.white,
      ),
      onTap: () => widget.runCommandCallback(),
    );
  }
}
