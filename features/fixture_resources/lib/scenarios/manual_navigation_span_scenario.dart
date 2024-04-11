import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

class ManualNavigationSpanScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(1);
    bugsnag_performance
        .startNavigationSpan(
          'navigationScenarioRoute',
          navigatorName: 'customNavigator',
          previousRoute: 'navigationScenarioPreviousRoute',
        )
        .end();
  }
}
