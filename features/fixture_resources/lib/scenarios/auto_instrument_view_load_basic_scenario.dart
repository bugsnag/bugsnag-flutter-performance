import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'scenario.dart';

class AutoInstrumentViewLoadBasicScenario extends Scenario {
  @override
  Future<void> run() async {
    setInstrumentsViewLoad(true);
    await startBugsnag();
    setMaxBatchSize(3);
  }

  @override
  Widget? createWidget() {
    return MeasuredWidget(
      name: 'AutoInstrumentViewLoadBasicScenarioWidget',
      builder: (context) => const Text('AutoInstrumentViewLoadBasicScenario'),
    );
  }
}
