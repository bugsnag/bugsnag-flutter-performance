import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/services.dart';

class MazeRunnerChannels {
  static const platform = MethodChannel('com.bugsnag.mazeRunner/platform');

  static Future<String> getCommand(String commandUrl) async {
    return await platform.invokeMethod("getCommand", {
      "commandUrl": commandUrl,
    }).then((value) => value ?? "");
  }

  static Future<void> clearPersistentData() {
    return platform.invokeMethod('clearPersistentData');
  }

  static Future<void> runScenario(String scenarioName,
          {Map<String, dynamic>? arguments}) async =>
      platform.invokeMethod('runScenario', {
        'scenarioName': scenarioName,
        ...?arguments,
      });
}
