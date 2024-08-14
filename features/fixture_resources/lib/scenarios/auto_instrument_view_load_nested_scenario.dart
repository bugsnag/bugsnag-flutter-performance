import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';

import 'scenario.dart';

class AutoInstrumentViewLoadNestedScenario extends Scenario {
  final _key = GlobalKey<_AutoInstrumentViewLoadNestedScenarioScreenState>();

  @override
  Future<void> run() async {
    setInstrumentsViewLoad(true);
    await startBugsnag();
    setMaxBatchSize(1);
  }

  @override
  Widget? createWidget() {
    return MeasuredWidget(
      name: 'AutoInstrumentViewLoadNestedScenarioWidget',
      builder: (_) => MeasuredWidget(
        name: 'AutoInstrumentViewLoadNestedScenarioChildWidget',
        builder: (_) => AutoInstrumentViewLoadNestedScenarioScreen(
          key: _key,
          runCommandCallback: () => runCommandCallback!(),
        ),
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

class AutoInstrumentViewLoadNestedScenarioScreen extends StatefulWidget {
  const AutoInstrumentViewLoadNestedScenarioScreen({
    super.key,
    required this.runCommandCallback,
  });
  final void Function() runCommandCallback;

  @override
  State<AutoInstrumentViewLoadNestedScenarioScreen> createState() =>
      _AutoInstrumentViewLoadNestedScenarioScreenState();
}

class _AutoInstrumentViewLoadNestedScenarioScreenState
    extends State<AutoInstrumentViewLoadNestedScenarioScreen> {
  var _stage = 1;

  @override
  Widget build(BuildContext context) {
    if (_stage < 2) {
      return GestureDetector(
        child: const BugsnagLoadingIndicator(child: Text('Loading...')),
        onTap: () => widget.runCommandCallback(),
      );
    }
    return const Text('AutoInstrumentViewLoadNestedScenarioScreen');
  }

  void setStage(int stage) {
    setState(() {
      _stage = stage;
    });
  }
}
