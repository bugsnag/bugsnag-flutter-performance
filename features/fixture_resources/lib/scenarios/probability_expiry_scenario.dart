import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';

class ProbabilityExpiryScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnag_performance.setExtraConfig("instrumentAppStart", false);
    bugsnag_performance.setExtraConfig("probabilityRequestsPause", 100);
    bugsnag_performance.setExtraConfig("probabilityValueExpireTime", 100);
    bugsnag_performance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'));
    setMaxBatchSize(1);
    await Future.delayed(const Duration(milliseconds: 500));
    doSimpleSpan('myspan');
  }
}
