import 'scenario.dart';

class DisableCustomReleaseStageScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
      releaseStage: "custom",
      enabledReleaseStages: ["release"],
    );
    setMaxBatchSize(1);
    doSimpleSpan('DisableCustomReleaseStageScenario');
  }
}
