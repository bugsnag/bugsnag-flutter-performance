import 'scenario.dart';

class CustomReleaseStageScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(releaseStage: "CustomReleaseStageScenario");
    setMaxBatchSize(1);
    doSimpleSpan('CustomReleaseStageScenario');
  }
}
