import 'package:bugsnag_dio_client/bugsnag_dio_client.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import '../main.dart';
import 'scenario.dart';

class DIOGetScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setBatchSize(1);
    BugsnagDioClient()
        .withSubscriber(BugsnagPerformance.networkInstrumentation)
        .client
        .get(FixtureConfig.MAZE_HOST.toString());
  }
}
