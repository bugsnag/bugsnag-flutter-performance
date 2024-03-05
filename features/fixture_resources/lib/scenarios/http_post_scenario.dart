import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart' as http;
import '../main.dart';
import 'scenario.dart';

class HttpPostScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setBatchSize(1);
    http.addSubscriber(BugsnagPerformance.networkInstrumentation);
    http.BugSnagHttpClient()
        .post(FixtureConfig.MAZE_HOST, body: {"key": "value"});
  }
}
