import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class AutoInstrumentNavigationEmbededPhasedScenario extends Scenario {
  final _key =
      GlobalKey<_AutoInstrumentNavigationEmbededPhasedScenarioScreenState>();
  final _firstSubScreenKey =
      GlobalKey<_AutoInstrumentNavigationEmbededPhasedScenarioScreenState>();
  final _lastSubScreenKey =
      GlobalKey<_AutoInstrumentNavigationEmbededPhasedScenarioScreenState>();

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
    return AutoInstrumentNavigationEmbededPhasedScenarioScreen(
        key: _key,
        name: 'AutoInstrumentNavigationEmbededPhasedScenarioScreen',
        runCommandCallback: () => runCommandCallback!(),
        child: Row(
          children: [
            AutoInstrumentNavigationEmbededPhasedScenarioScreen(
                key: _firstSubScreenKey,
                name:
                    'AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen',
                runCommandCallback: () => runCommandCallback!()),
            AutoInstrumentNavigationEmbededPhasedScenarioScreen(
                key: _lastSubScreenKey,
                name:
                    'AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen',
                runCommandCallback: () => runCommandCallback!()),
          ],
        ));
  }

  @override
  RouteSettings? routeSettings() {
    return const RouteSettings(name: 'Test');
  }

  void step2() {
    _firstSubScreenKey.currentState!.finishLoading();
  }

  void step3() {
    _key.currentState!.finishLoading();
  }

  void step4() {
    _lastSubScreenKey.currentState!.finishLoading();
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

class AutoInstrumentNavigationEmbededPhasedScenarioScreen
    extends StatefulWidget {
  const AutoInstrumentNavigationEmbededPhasedScenarioScreen({
    super.key,
    required this.name,
    required this.runCommandCallback,
    this.child,
  });
  final void Function() runCommandCallback;
  final String name;
  final Widget? child;

  @override
  State<AutoInstrumentNavigationEmbededPhasedScenarioScreen> createState() =>
      _AutoInstrumentNavigationEmbededPhasedScenarioScreenState();
}

class _AutoInstrumentNavigationEmbededPhasedScenarioScreenState
    extends State<AutoInstrumentNavigationEmbededPhasedScenarioScreen> {
  var isLoading = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MeasuredScreen(
        key: Key(widget.name),
        name: widget.name,
        builder: (context) => Container(
          color: Colors.white,
          child: Row(
            children: [
              if (isLoading)
                const BugsnagLoadingIndicator(child: Text('Loading...')),
              const Text('Screen'),
              if (widget.child != null) widget.child!,
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
