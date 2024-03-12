import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart' as http;
import '../main.dart';
import 'scenario.dart';

class HttpCallbackCancelSpanScenario extends Scenario {
  @override
  Future<void> run() async {
    BugsnagPerformance.setExtraConfig("instrumentAppStart", false);
    await BugsnagPerformance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'),
        networkRequestCallback: (info) {
          return null;
        });
    setMaxBatchSize(1);
    http.addSubscriber(BugsnagPerformance.networkInstrumentation);
    http.BugSnagHttpClient().get(FixtureConfig.MAZE_HOST);
    await Future.delayed(const Duration(seconds: 10));
    BugsnagPerformance.startSpan('HttpCallbackCancelSpanScenario').end();
  }
}
