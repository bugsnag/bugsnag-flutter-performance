import 'package:bugsnag_dio_client/bugsnag_dio_client.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import '../main.dart';
import 'scenario.dart';

class DIOPostScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setBatchSize(1);
    BugsnagDioClient()
        .withSubscriber(BugsnagPerformance.networkInstrumentation)
        .client
        .post(FixtureConfig.MAZE_HOST.toString(), data: {"key": "value"});
  }
}
