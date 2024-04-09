import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class AutoInstrumentAppStartsScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnag_performance.setExtraConfig("instrumentAppStart", true);
    bugsnag_performance.setExtraConfig("probabilityValueExpireTime", 1000);
    bugsnag_performance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse(FixtureConfig.MAZE_HOST.toString() + '/traces'),
        instrumentAppStarts: true);
    bugsnag_performance.measureRunApp(() async => await Duration(seconds: 1));
    setMaxBatchSize(4);
  }
}
