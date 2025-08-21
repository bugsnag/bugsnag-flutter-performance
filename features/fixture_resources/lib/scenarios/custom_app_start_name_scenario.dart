import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class CustomAppStartNameScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnag_performance.setExtraConfig("instrumentAppStart", true);
    bugsnag_performance.setExtraConfig("probabilityValueExpireTime", 1000);
    await bugsnag_performance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'));

    // Get the AppStart span control and set a custom name
    final control = bugsnag_performance.getSpanControl(appStart);
    control?.setType('FirstOpen');

    bugsnag_performance.measureRunApp(() async => const Duration(seconds: 1));
    setMaxBatchSize(4);
  }
}