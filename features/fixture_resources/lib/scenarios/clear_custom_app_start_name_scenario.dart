import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';

import '../main.dart';
import 'scenario.dart';

class ClearCustomAppStartNameScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnag_performance.setExtraConfig('instrumentAppStart', true);
    bugsnag_performance.setExtraConfig('probabilityValueExpireTime', 1000);
    bugsnag_performance.start(
      apiKey: '12312312312312312312312312312312',
      endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'),
    );
    final control = bugsnag_performance.getSpanControl<AppStartSpanControl>();
    control?.setType('FirstOpen');
    control?.clearType();
    bugsnag_performance.measureRunApp(() async => const Duration(seconds: 1));
    setMaxBatchSize(4);
  }
}
