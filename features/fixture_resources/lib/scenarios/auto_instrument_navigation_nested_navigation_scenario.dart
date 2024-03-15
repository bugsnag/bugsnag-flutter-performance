import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_navigator_observer/bugsnag_flutter_navigator_observer.dart';
import 'package:flutter/material.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class AutoInstrumentNavigationNestedNavigationPhasedScenario extends Scenario {
  final _key = GlobalKey<State<StatefulWidget>>();
  final _subScreenKey = GlobalKey<
      _AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreenState>();

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
    return BugsnagNavigationContainer(
      child: Navigator(
        observers: [BugsnagNavigatorObserver()],
        pages: [
          MaterialPage(
            child: GestureDetector(
              key: _key,
              child: Container(color: Colors.white),
              onTap: () => runCommandCallback!(),
            ),
          )
        ],
      ),
    );
  }

  @override
  RouteSettings? routeSettings() {
    return const RouteSettings(
      name:
          'AutoInstrumentNavigationNestedNavigationPhasedScenarioNestedNavigatorScreen',
    );
  }

  void step2() {
    final route = MaterialPageRoute(
      builder: (context) =>
          AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen(
              key: _subScreenKey,
              runCommandCallback: () => runCommandCallback!()),
    );
    Navigator.of(_key.currentContext!).push(route);
  }

  void step3() {
    _subScreenKey.currentState!.finishLoading();
  }

  void step4() {
    final route = MaterialPageRoute(
      builder: (context) => Container(),
      settings: const RouteSettings(
        name:
            'AutoInstrumentNavigationNestedNavigationPhasedScenarioPushedScreen',
      ),
    );
    Navigator.of(_subScreenKey.currentContext!).push(route);
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

class AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen
    extends StatefulWidget {
  const AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen({
    super.key,
    required this.runCommandCallback,
  });
  final void Function() runCommandCallback;

  @override
  State<AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen>
      createState() =>
          _AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreenState();
}

class _AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreenState
    extends State<
        AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen> {
  var isLoading = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MeasuredScreen(
        key: const Key(
            'AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen'),
        name: 'AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen',
        builder: (context) => Container(
          color: Colors.white,
          child: Row(
            children: [
              if (isLoading)
                const BugsnagLoadingIndicator(child: Text('Loading...')),
              const Text('Screen'),
            ],
          ),
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
