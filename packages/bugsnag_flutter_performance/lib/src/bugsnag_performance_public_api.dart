import 'dart:async';

import '../bugsnag_flutter_performance.dart';
import 'client.dart';

class BugsnagPerformance {
  static final BugsnagPerformanceClientImpl _client =
      BugsnagPerformanceClientImpl();

  static Future<void> start({String? apiKey, Uri? endpoint}) async {
    return _client.start(apiKey: apiKey, endpoint: endpoint);
  }

  static BugsnagPerformanceSpan startSpan(String name) {
    return _client.startSpan(name);
  }

  static void runApp({
    FutureOr<void> Function()? runApp,
  }) {
    //TODO implement
    // _client.runApp(runApp: runApp);
  }

  static void setBatchSize(int batchSize) {
    _client.setBatchSize(batchSize);
  }
}
