import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart' as http;
import '../main.dart';
import 'scenario.dart';

class CheckNetworkCallbackTypeScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnag_performance.setExtraConfig("instrumentAppStart", false);
    String type = "not-set";
    await bugsnag_performance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'),
        networkRequestCallback: (info) {
          type = info.type!;
          return info;
        });
    setMaxBatchSize(2);
    http.addSubscriber(bugsnag_performance.networkInstrumentation);
    await http.Client().get(FixtureConfig.MAZE_HOST);
    doSimpleSpan(type);
  }
}
