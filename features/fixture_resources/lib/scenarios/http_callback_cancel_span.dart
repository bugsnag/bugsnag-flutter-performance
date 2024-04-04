import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart' as http;
import '../main.dart';
import 'scenario.dart';

class HttpCallbackCancelSpanScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnag_performance.setExtraConfig("instrumentAppStart", false);
    await bugsnag_performance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'),
        networkRequestCallback: (info) {
          return null;
        });
    setMaxBatchSize(1);
    http.addSubscriber(bugsnag_performance.networkInstrumentation);
    http.Client().get(FixtureConfig.MAZE_HOST);
    await Future.delayed(const Duration(seconds: 10));
    bugsnag_performance.startSpan('HttpCallbackCancelSpanScenario').end();
  }
}
