import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';

import 'scenario.dart';

class ClearCustomAppStartNameScenario extends Scenario {
  @override
  Future<void> run() async {
    setMaxBatchSize(4);
    await startBugsnag();
    final control = bugsnag_performance.getSpanControl<AppStartSpanControl>();
    control?.setType('FirstOpen');
    control?.clearType();
    bugsnag_performance.measureRunApp(() async => const Duration(seconds: 1));
  }
}