import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class CustomEnabledReleaseStageScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
        releaseStage: "CustomEnabledReleaseStageScenario",
        enabledReleaseStages: ["CustomEnabledReleaseStageScenario"]);
    setMaxBatchSize(1);
    final span =
        BugsnagPerformance.startSpan('CustomEnabledReleaseStageScenario');
    span.end();
  }
}
