import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';

import 'scenario.dart';

class AutoInstrumentNavigationBasicDeferScenario extends Scenario {
  final _key =
      GlobalKey<_AutoInstrumentNavigationBasicDeferScenarioScreenState>();

  @override
  Future<void> run() async {
    setInstrumentsNavigation(true);
    await startBugsnag();
    setMaxBatchSize(1);
  }

  @override
  Widget? createWidget() {
    return AutoInstrumentNavigationBasicDeferScenarioScreen(
      key: _key,
      runCommandCallback: () => runCommandCallback!(),
    );
  }

  @override
  RouteSettings? routeSettings() {
    return const RouteSettings(name: 'basic_defer_navigation_scenario');
  }

  void step2() {
    _key.currentState!.setStage(2);
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

class AutoInstrumentNavigationBasicDeferScenarioScreen extends StatefulWidget {
  const AutoInstrumentNavigationBasicDeferScenarioScreen({
    super.key,
    required this.runCommandCallback,
  });
  final void Function() runCommandCallback;

  @override
  State<AutoInstrumentNavigationBasicDeferScenarioScreen> createState() =>
      _AutoInstrumentNavigationBasicDeferScenarioScreenState();
}

class _AutoInstrumentNavigationBasicDeferScenarioScreenState
    extends State<AutoInstrumentNavigationBasicDeferScenarioScreen> {
  var _stage = 1;

  @override
  Widget build(BuildContext context) {
    if (_stage < 2) {
      return GestureDetector(
        child: const BugsnagLoadingIndicator(child: Text('Loading...')),
        onTap: () => widget.runCommandCallback(),
      );
    }
    return const Text('AutoInstrumentNavigationBasicDeferScenarioScreen');
  }

  void setStage(int stage) {
    setState(() {
      _stage = stage;
    });
  }
}
