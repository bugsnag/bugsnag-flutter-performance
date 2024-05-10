import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';

import 'scenario.dart';

class AutoInstrumentViewLoadBasicDeferScenario extends Scenario {
  final _key =
      GlobalKey<_AutoInstrumentViewLoadBasicDeferScenarioScreenState>();

  @override
  Future<void> run() async {
    setInstrumentsViewLoad(true);
    await startBugsnag();
    setMaxBatchSize(1);
  }

  @override
  Widget? createWidget() {
    return MeasuredWidget(
      name: 'AutoInstrumentViewLoadBasicDeferScenarioWidget',
      builder: (_) => AutoInstrumentViewLoadBasicDeferScenarioScreen(
        key: _key,
        runCommandCallback: () => runCommandCallback!(),
      ),
    );
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

class AutoInstrumentViewLoadBasicDeferScenarioScreen extends StatefulWidget {
  const AutoInstrumentViewLoadBasicDeferScenarioScreen({
    super.key,
    required this.runCommandCallback,
  });
  final void Function() runCommandCallback;

  @override
  State<AutoInstrumentViewLoadBasicDeferScenarioScreen> createState() =>
      _AutoInstrumentViewLoadBasicDeferScenarioScreenState();
}

class _AutoInstrumentViewLoadBasicDeferScenarioScreenState
    extends State<AutoInstrumentViewLoadBasicDeferScenarioScreen> {
  var _stage = 1;

  @override
  Widget build(BuildContext context) {
    if (_stage < 2) {
      return GestureDetector(
        child: const BugsnagLoadingIndicator(child: Text('Loading...')),
        onTap: () => widget.runCommandCallback(),
      );
    }
    return const Text('AutoInstrumentViewLoadBasicDeferScenarioScreen');
  }

  void setStage(int stage) {
    setState(() {
      _stage = stage;
    });
  }
}
