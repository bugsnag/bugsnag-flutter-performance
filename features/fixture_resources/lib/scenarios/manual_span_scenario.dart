import 'scenario.dart';

class ManualSpanScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(1);
    doSimpleSpan('ManualSpanScenario');
  }
}
