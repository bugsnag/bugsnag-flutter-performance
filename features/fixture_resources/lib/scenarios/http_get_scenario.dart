import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart';
import '../main.dart';
import 'scenario.dart';

class HttpGetScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setBatchSize(1);
    BugSnagHttpClient()
        .withSubscriber(BugsnagPerformance.networkInstrumentation)
        .get(FixtureConfig.MAZE_HOST);
  }
}
