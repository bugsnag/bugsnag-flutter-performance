import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart' as http;
import '../main.dart';
import 'scenario.dart';

class HttpCallbackEditScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnag_performance.setExtraConfig("instrumentAppStart", false);
    await bugsnag_performance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'),
        networkRequestCallback: (info) {
          info.url = "edited";
          return info;
        });
    setMaxBatchSize(1);
    http.addSubscriber(bugsnag_performance.networkInstrumentation);
    http.Client().get(FixtureConfig.MAZE_HOST);
  }
}
