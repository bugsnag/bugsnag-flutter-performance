import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart';
import '../main.dart';
import 'scenario.dart';

class HttpCallbackEditScenario extends Scenario {
  @override
  Future<void> run() async {
    BugsnagPerformance.setExtraConfig("instrumentAppStart", false);
    await BugsnagPerformance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'),
        networkRequestCallback: (info) {
          info.url = "edited";
          return info;
        });
    setBatchSize(1);
    BugSnagHttpClient()
        .withSubscriber(BugsnagPerformance.networkInstrumentation)
        .get(FixtureConfig.MAZE_HOST);
  }
}
