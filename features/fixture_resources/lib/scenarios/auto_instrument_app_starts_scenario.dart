import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class AutoInstrumentAppStartsScenario extends Scenario {
  @override
  Future<void> run() async {
    BugsnagPerformance.setExtraConfig("instrumentAppStart", true);
    BugsnagPerformance.setExtraConfig("probabilityValueExpireTime", 1000);
    BugsnagPerformance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse(FixtureConfig.MAZE_HOST.toString() + '/traces'));
    BugsnagPerformance.measureRunApp(() async => await Duration(seconds: 1));
    setBatchSize(4);
  }
}
