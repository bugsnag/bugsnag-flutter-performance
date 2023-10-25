
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class ManualSpan extends Scenario {
  @override
  Future<void> run() async {
    const apiKey = '0123456789abcdef0123456789abcdef';
    BugsnagPerformanceClient client = BugsnagPerformanceClient();
    client.start(apiKey: apiKey, endpoint: FixtureConfig.MAZE_HOST);
    client.setBatchSize(1);
    client.startSpan('Test').end();
  }
}
