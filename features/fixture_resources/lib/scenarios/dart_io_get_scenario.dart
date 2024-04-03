import 'dart:io';

import 'package:bugsnag_flutter_dart_io_http_client/bugsnag_flutter_dart_io_http_client.dart'
    as dartIo;
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import '../main.dart';
import 'scenario.dart';

class DartIoGetScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(1);
    dartIo.addSubscriber(bugsnag_performance.networkInstrumentation);
    final client = dartIo.HttpClient();
    HttpClientRequest request = await client.getUrl(FixtureConfig.MAZE_HOST);
    await request.close();
  }
}
