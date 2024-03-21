import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class DisableCustomReleaseStageScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
        releaseStage: "custom", enabledReleaseStages: ["release"]);
    setMaxBatchSize(1);
    final span =
        BugsnagPerformance.startSpan('DisableCustomReleaseStageScenario');
    span.end();
  }
}
