import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class FixedSamplingProbabilityZeroScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
      samplingProbability: 0.0,
    );
    setMaxBatchSize(1);
    bugsnag_performance.startSpan('FixedSamplingProbabilitySpan1').end();
  }
}
