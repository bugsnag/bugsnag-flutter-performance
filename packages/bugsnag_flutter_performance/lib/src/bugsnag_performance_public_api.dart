import 'dart:async';

import 'package:bugsnag_flutter_performance/src/span_context.dart';

import '../bugsnag_flutter_performance.dart';
import 'client.dart';

class BugsnagPerformance {
  static final BugsnagPerformanceClientImpl _client =
      BugsnagPerformanceClientImpl();

  static Future<void> start({String? apiKey, Uri? endpoint}) async {
    return _client.start(apiKey: apiKey, endpoint: endpoint);
  }

  static BugsnagPerformanceSpan startSpan(String name,
      {DateTime? startTime,
      BugsnagPerformanceSpanContext? parentContext,
      bool? makeCurrentContext = true}) {
    return _client.startSpan(
      name,
      startTime: startTime,
      parentContext: parentContext,
      makeCurrentContext: makeCurrentContext,
    );
  }

  static void runApp({
    FutureOr<void> Function()? runApp,
  }) {
    //TODO implement this during auto instrumentation
    // _client.runApp(runApp: runApp);
  }

  static void setExtraConfig(String key, dynamic value) {
    _client.setExtraConfig(key, value);
  }

  static dynamic networkInstrumentation(dynamic data){
    return _client.networkInstrumentation(data);
  }
}
