import 'scenario.dart';

class MaxBatchAgeScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchAge(5000);
    doSimpleSpan('MaxBatchAgeScenario');
  }
}
