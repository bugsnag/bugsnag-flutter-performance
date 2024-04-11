import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class CustomReleaseStageScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(releaseStage: "CustomReleaseStageScenario");
    setMaxBatchSize(1);
    doSimpleSpan('CustomReleaseStageScenario');
  }
}
