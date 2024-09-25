import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';

import 'scenario.dart';

class AutoInstrumentNavigationWithViewLoadScenario extends Scenario {
  final _key =
      GlobalKey<_AutoInstrumentNavigationWithViewLoadScenarioScreenState>();

  @override
  Future<void> run() async {
    setInstrumentsNavigation(true);
    setInstrumentsViewLoad(true);
    await startBugsnag();
    setMaxBatchSize(1);
  }

  @override
  Widget? createWidget() {
    return AutoInstrumentNavigationWithViewLoadScenarioScreen(
      key: _key,
      runCommandCallback: () => runCommandCallback!(),
    );
  }

  @override
  RouteSettings? routeSettings() {
    return const RouteSettings(name: 'navigation_view_load_scenario');
  }

  void step2() {
    _key.currentState!.setStage(2);
  }

  void step3() {
    _key.currentState!.setStage(3);
  }

  void step4() {
    _key.currentState!.setStage(4);
  }

  @override
  void invokeMethod(String name) {
    switch (name) {
      case 'step2':
        step2();
        break;
      case 'step3':
        step3();
        break;
      case 'step4':
        step4();
        break;
      default:
        break;
    }
  }
}

class AutoInstrumentNavigationWithViewLoadScenarioScreen
    extends StatefulWidget {
  const AutoInstrumentNavigationWithViewLoadScenarioScreen({
    super.key,
    required this.runCommandCallback,
  });
  final void Function() runCommandCallback;

  @override
  State<AutoInstrumentNavigationWithViewLoadScenarioScreen> createState() =>
      _AutoInstrumentNavigationWithViewLoadScenarioScreenState();
}

class _AutoInstrumentNavigationWithViewLoadScenarioScreenState
    extends State<AutoInstrumentNavigationWithViewLoadScenarioScreen> {
  var _stage = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            color: Colors.white,
            child: MeasuredWidget(
              name: 'AutoInstrumentNavigationWithViewLoadWidget',
              builder: (context) => Row(
                children: [
                  if (_stage < 4)
                    BugsnagLoadingIndicator(
                      child: Column(children: [
                        if (_stage < 3)
                          const BugsnagLoadingIndicator(
                            child: Text('Still loading...'),
                          ),
                        if (_stage < 2)
                          const BugsnagLoadingIndicator(
                            child: CircularProgressIndicator(),
                          )
                      ]),
                    ),
                  const Text(
                      'AutoInstrumentNavigationWithViewLoadScenarioScreen')
                ],
              ),
            )),
        onTap: () => widget.runCommandCallback());
  }

  void setStage(int stage) {
    setState(() {
      _stage = stage;
    });
  }
}
