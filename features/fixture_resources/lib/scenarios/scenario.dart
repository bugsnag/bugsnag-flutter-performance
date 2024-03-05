// ignore_for_file: avoid_print
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/widgets.dart';

import '../channels.dart';
import '../main.dart';

abstract class Scenario {
  String? extraConfig;

  Future<void> clearPersistentData() async {
    print('[MazeRunner] Clearing Persistent Data...');
    await MazeRunnerChannels.clearPersistentData();
  }

  Widget? createWidget() => null;
  RouteSettings? routeSettings() => null;

  Future<void> run();

  void setBatchSize(int size) {
    BugsnagPerformance.setExtraConfig("autoTriggerExportOnBatchSize", size);
  }

  Future<void> startBugsnag() async {
    BugsnagPerformance.setExtraConfig("instrumentAppStart", false);
    await BugsnagPerformance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'));
  }

  void invokeMethod(String name) {}
}
