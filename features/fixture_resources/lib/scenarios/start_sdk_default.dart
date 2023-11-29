import 'scenario.dart';

class StartSdkDefault extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
  }
}
