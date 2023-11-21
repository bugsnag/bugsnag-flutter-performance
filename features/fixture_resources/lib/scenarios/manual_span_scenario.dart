import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';
import 'scenario.dart';

class ManualSpanScenario extends Scenario {
  @override
  Future<void> run() async {
    BugsnagPerformance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'));
    BugsnagPerformance.setBatchSize(1);
    final span = BugsnagPerformance.startSpan('ManualSpanScenario');
    span.end();
  }
}
