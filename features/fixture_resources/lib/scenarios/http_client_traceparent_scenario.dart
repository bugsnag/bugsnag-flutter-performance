import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart' as http;
import '../main.dart';
import 'scenario.dart';

class HttpClientTraceparentScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(1);
    http.addSubscriber(bugsnag_performance.networkInstrumentation);
    http.get(Uri.parse('${FixtureConfig.MAZE_HOST.toString()}/reflect'));
  }
}
