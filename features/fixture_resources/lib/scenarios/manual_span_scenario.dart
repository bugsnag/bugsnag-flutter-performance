
import 'dart:convert';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:mazerunner/main.dart';

import 'scenario.dart';
import 'package:http/http.dart' as http;

class ManualSpan extends Scenario {
  @override
  Future<void> run() async {
    log("running manual span scenario");
    http.post(Uri.parse(FixtureConfig.MAZE_HOST.toString() + "/logs"), body: jsonEncode({
      "message": "manual span scenario"
    }));
  }
}

