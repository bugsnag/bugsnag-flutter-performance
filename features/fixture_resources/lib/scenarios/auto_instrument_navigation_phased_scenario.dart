import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class AutoInstrumentNavigationPhasedScenario extends Scenario {
  final _key = GlobalKey<_AutoInstrumentNavigationPhasedScenarioScreenState>();

  @override
  Future<void> run() async {
    BugsnagPerformance.setExtraConfig("instrumentAppStart", false);
    BugsnagPerformance.setExtraConfig("instrumentNavigation", true);
    BugsnagPerformance.setExtraConfig("probabilityValueExpireTime", 1000);
    BugsnagPerformance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse(FixtureConfig.MAZE_HOST.toString() + '/traces'));
    setMaxBatchSize(5);
  }

  @override
  Widget? createWidget() {
    return AutoInstrumentNavigationPhasedScenarioScreen(
      key: _key,
      runCommandCallback: () => runCommandCallback!(),
    );
  }

  @override
  RouteSettings? routeSettings() {
    return const RouteSettings(name: 'Test');
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

class AutoInstrumentNavigationPhasedScenarioScreen extends StatefulWidget {
  const AutoInstrumentNavigationPhasedScenarioScreen({
    super.key,
    required this.runCommandCallback,
  });
  final void Function() runCommandCallback;

  @override
  State<AutoInstrumentNavigationPhasedScenarioScreen> createState() =>
      _AutoInstrumentNavigationPhasedScenarioScreenState();
}

class _AutoInstrumentNavigationPhasedScenarioScreenState
    extends State<AutoInstrumentNavigationPhasedScenarioScreen> {
  var _stage = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MeasuredScreen(
        key: const Key('AutoInstrumentNavigationPhasedScenarioScreen'),
        name: 'AutoInstrumentNavigationPhasedScenarioScreen',
        builder: (context) => Container(
          color: Colors.white,
          child: Row(
            children: [
              if (_stage < 2)
                const BugsnagLoadingIndicator(child: Text('Loading...')),
              const Text('Screen'),
            ],
          ),
        ),
      ),
      onTap: () => widget.runCommandCallback(),
    );
  }

  void setStage(int stage) {
    setState(() {
      _stage = stage;
    });
  }
}
