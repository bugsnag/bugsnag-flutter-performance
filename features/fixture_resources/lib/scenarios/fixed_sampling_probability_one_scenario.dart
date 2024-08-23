import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class FixedSamplingProbabilityOneScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
      samplingProbability: 1.0,
    );
    setMaxBatchSize(1);
    bugsnag_performance.startSpan('FixedSamplingProbabilitySpan1').end();
  }

  void step2() {
    bugsnag_performance.startSpan('FixedSamplingProbabilitySpan2').end();
  }

  @override
  void invokeMethod(String name) {
    switch (name) {
      case 'step2':
        step2();
        break;
      default:
        break;
    }
  }
}
