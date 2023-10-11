// ignore_for_file: avoid_print
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/widgets.dart';

import '../channels.dart';

abstract class Scenario {
  String? extraConfig;

  Future<void> clearPersistentData() async {
    print('[MazeRunner] Clearing Persistent Data...');
    await MazeRunnerChannels.clearPersistentData();
  }

  // Future<void> startBugsnag() => null;

  Widget? createWidget() => null;

  Future<void> run();
}

void expect(dynamic actual, dynamic expected) {
  if (actual != expected) {
    throw AssertionError('Expected \'$expected\' but got \'$actual\'');
  }
}
