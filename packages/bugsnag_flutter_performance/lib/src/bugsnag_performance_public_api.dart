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

  static Future<void> measureRunApp(
    FutureOr<void> Function() runApp,
  ) async {
    await _client.measureRunApp(runApp);
  }

  static void setExtraConfig(String key, dynamic value) {
    _client.setExtraConfig(key, value);
  }
}
