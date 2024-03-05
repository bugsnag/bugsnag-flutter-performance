import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart' as http;
import '../main.dart';
import 'scenario.dart';

class HttpGetMultipleSubscribersScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setBatchSize(1);
    http.addSubscriber(BugsnagPerformance.networkInstrumentation);
    http.addSubscriber(BugsnagPerformance.networkInstrumentation);
    http.get(FixtureConfig.MAZE_HOST);
  }
}
