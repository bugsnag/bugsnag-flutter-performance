import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class CustomAppVersionScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(appVersion: "999.888.777");
    setMaxBatchSize(1);
    doSimpleSpan('CustomAppVersionScenario');
  }
}
