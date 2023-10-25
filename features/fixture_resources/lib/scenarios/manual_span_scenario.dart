
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class ManualSpan extends Scenario {
  @override
  Future<void> run() async {
    log("running manual span scenario");
    const apiKey = '0123456789abcdef0123456789abcdef';
    BugsnagPerformanceClient client = BugsnagPerformanceClient();
    log("using MAZE_HOST: " + FixtureConfig.MAZE_HOST.toString());
    client.start(apiKey: apiKey, endpoint: Uri.parse("https://webhook.site/2c429399-3f1e-4c44-b4dd-59853fd1ff79"));
    client.setBatchSize(1);
    client.startSpan('Test').end();
  }
}
