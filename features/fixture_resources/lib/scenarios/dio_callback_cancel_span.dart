import 'package:bugsnag_dio_client/bugsnag_dio_client.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart';
import '../main.dart';
import 'scenario.dart';

class DIOCallbackCancelSpanScenario extends Scenario {
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
    BugsnagDioClient()
        .withSubscriber(BugsnagPerformance.networkInstrumentation)
        .client
        .get(FixtureConfig.MAZE_HOST.toString());
    await Future.delayed(const Duration(seconds: 10));
    BugsnagPerformance.startSpan('DIOCallbackCancelSpanScenario').end();
  }
}
