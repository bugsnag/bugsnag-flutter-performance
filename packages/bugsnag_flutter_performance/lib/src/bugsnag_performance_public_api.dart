import 'dart:async';

import 'package:bugsnag_flutter_performance/src/span_attributes.dart';
import 'package:bugsnag_flutter_performance/src/span_context.dart';

import '../bugsnag_flutter_performance.dart';
import 'bugsnag_network_request_info.dart';
import 'client.dart';

class BugsnagPerformance {
  static final BugsnagPerformanceClientImpl _client =
      BugsnagPerformanceClientImpl();

  static Future<void> start(
      {String? apiKey,
      Uri? endpoint,
      BugsnagNetworkRequestInfo? Function(BugsnagNetworkRequestInfo)?
          networkRequestCallback}) async {
    return _client.start(
        apiKey: apiKey,
        endpoint: endpoint,
        networkRequestCallback: networkRequestCallback);
  }

  static BugsnagPerformanceSpan startSpan(String name,
      {DateTime? startTime,
      BugsnagPerformanceSpanContext? parentContext,
      bool? makeCurrentContext = true}) {
    return _client.startSpan(name,
        startTime: startTime,
        parentContext: parentContext,
        makeCurrentContext: makeCurrentContext,
        attributes: BugsnagPerformanceSpanAttributes(isFirstClass: true));
  }

  static BugsnagPerformanceSpan startNetworkSpan(
      String url, String httpMethod) {
    return _client.startNetworkSpan(url, httpMethod.toUpperCase());
  }

  static Future<void> measureRunApp(
    FutureOr<void> Function() runApp,
  ) async {
    await _client.measureRunApp(runApp);
  }

  static void setExtraConfig(String key, dynamic value) {
    _client.setExtraConfig(key, value);
  }

  static dynamic networkInstrumentation(dynamic data) {
    return _client.networkInstrumentation(data);
  }
}
