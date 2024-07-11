// ignore_for_file: avoid_print
import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/widgets.dart';

import '../channels.dart';
import '../main.dart';

abstract class Scenario {
  String? extraConfig;
  BugsnagEndpointConfiguration? endpointConfiguration;
  void Function()? runCommandCallback;

  Future<void> clearPersistentData() async {
    print('[MazeRunner] Clearing Persistent Data...');
    await MazeRunnerChannels.clearPersistentData();
  }

  Widget? createWidget() => null;
  RouteSettings? routeSettings() => null;

  Future<void> run();

  void doSimpleSpan(String name) {
    bugsnag_performance.startSpan(name).end();
  }

  void setMaxBatchSize(int size) {
    bugsnag_performance.setExtraConfig("maxBatchSize", size);
  }

  void setMaxBatchAge(int milliseconds) {
    bugsnag_performance.setExtraConfig("maxBatchAge", milliseconds);
  }

  void setInstrumentsNavigation(bool value) {
    bugsnag_performance.setExtraConfig("instrumentNavigation", value);
  }

  void setInstrumentsViewLoad(bool value) {
    bugsnag_performance.setExtraConfig("instrumentViewLoad", value);
  }

  Future<void> startBugsnag({
    String? releaseStage,
    List<String>? enabledReleaseStages,
    List<RegExp>? tracePropagationUrls,
    String? appVersion,
    bool shouldUseNotifier = false,
  }) async {
    bugsnag_performance.setExtraConfig("instrumentAppStart", false);
    bugsnag_performance.setExtraConfig("probabilityValueExpireTime", 1000);
    await bugsnag_performance.start(
      apiKey: '12312312312312312312312312312312',
      endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'),
      releaseStage: releaseStage,
      enabledReleaseStages: enabledReleaseStages,
      tracePropagationUrls: tracePropagationUrls,
      appVersion: appVersion,
    );
    if (shouldUseNotifier && endpointConfiguration != null) {
      await bugsnag.start(
        apiKey: '12312312312312312312312312312312',
        endpoints: endpointConfiguration!,
      );
    }
  }

  void invokeMethod(String name) {}
}
