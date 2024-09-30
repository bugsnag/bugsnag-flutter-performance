import 'scenario.dart';

class CustomEnabledReleaseStageScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
      releaseStage: "CustomEnabledReleaseStageScenario",
      enabledReleaseStages: ["CustomEnabledReleaseStageScenario"],
    );
    setMaxBatchSize(1);
    doSimpleSpan('CustomEnabledReleaseStageScenario');
  }
}
