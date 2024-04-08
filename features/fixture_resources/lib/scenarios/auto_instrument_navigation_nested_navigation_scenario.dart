import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';

import 'package:flutter/material.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class AutoInstrumentNavigationNestedNavigationScenario extends Scenario {
  final _key = GlobalKey<
      _AutoInstrumentNavigationNestedNavigationScenarioSubScreenState>();
  Route<dynamic>? routeToReplace;

  @override
  Future<void> run() async {
    setInstrumentsNavigation(true);
    await startBugsnag();
    setMaxBatchSize(1);
  }

  @override
  Widget? createWidget() {
    return BugsnagNavigationContainer(
      child: Navigator(
        observers: [
          BugsnagPerformanceNavigatorObserver(
              navigatorName: "nested_scenario_child_navigator")
        ],
        pages: [
          MaterialPage(
            child: AutoInstrumentNavigationNestedNavigationScenarioSubScreen(
                key: _key, runCommandCallback: () => runCommandCallback!()),
            name: 'nested_scenario_child_route_initial',
          )
        ],
      ),
    );
  }

  @override
  RouteSettings? routeSettings() {
    return const RouteSettings(
      name: 'nested_defer_navigation_scenario_parent',
    );
  }

  void step2() {
    _key.currentState!.finishLoading();
  }

  void step3() {
    routeToReplace = MaterialPageRoute(
      builder: (context) => GestureDetector(
        child: Container(
          color: Colors.white,
        ),
        onTap: () => runCommandCallback!(),
      ),
      settings: const RouteSettings(
        name: 'nested_scenario_child_route_2',
      ),
    );
    Navigator.of(_key.currentContext!).push(routeToReplace!);
  }

  void step4() {
    final route = MaterialPageRoute(
      builder: (context) => Container(),
      settings: const RouteSettings(
        name: 'nested_scenario_child_route_3',
      ),
    );
    Navigator.of(_key.currentContext!).replace(
      oldRoute: routeToReplace!,
      newRoute: route,
    );
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

class AutoInstrumentNavigationNestedNavigationScenarioSubScreen
    extends StatefulWidget {
  const AutoInstrumentNavigationNestedNavigationScenarioSubScreen({
    super.key,
    required this.runCommandCallback,
  });
  final void Function() runCommandCallback;

  @override
  State<AutoInstrumentNavigationNestedNavigationScenarioSubScreen>
      createState() =>
          _AutoInstrumentNavigationNestedNavigationScenarioSubScreenState();
}

class _AutoInstrumentNavigationNestedNavigationScenarioSubScreenState
    extends State<AutoInstrumentNavigationNestedNavigationScenarioSubScreen> {
  var isLoading = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        child: Row(
          children: [
            if (isLoading)
              const BugsnagLoadingIndicator(child: Text('Loading...')),
            const Text('Screen'),
          ],
        ),
      ),
      onTap: () => widget.runCommandCallback(),
    );
  }

  finishLoading() {
    setState(() {
      isLoading = false;
    });
  }
}
