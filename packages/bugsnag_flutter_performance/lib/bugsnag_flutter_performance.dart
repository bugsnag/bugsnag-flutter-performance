library bugsnag_flutter_performance;

import 'dart:async';

import 'package:bugsnag_flutter_performance/src/bugsnag_network_request_info.dart';
import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:bugsnag_flutter_performance/src/span_attributes.dart';
import 'package:bugsnag_flutter_performance/src/span_context.dart';

import 'bugsnag_flutter_performance.dart';
export 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart'
    show bugsnag_performance;
export 'src/span.dart' show BugsnagPerformanceSpan;

class BugsnagPerformance {
  BugsnagPerformance._internal();

  static final BugsnagPerformanceClientImpl _client =
      BugsnagPerformanceClientImpl();

  Future<void> start({
    required String apiKey,
    Uri? endpoint,
    BugsnagNetworkRequestInfo? Function(BugsnagNetworkRequestInfo)?
        networkRequestCallback,
    String? releaseStage,
    List<String>? enabledReleaseStages,
    String? appVersion,
  }) {
    return _client.start(
      apiKey: apiKey,
      endpoint: endpoint,
      networkRequestCallback: networkRequestCallback,
      releaseStage: releaseStage,
      enabledReleaseStages: enabledReleaseStages,
      appVersion: appVersion,
    );
  }

  BugsnagPerformanceSpan startSpan(String name,
      {DateTime? startTime,
      BugsnagPerformanceSpanContext? parentContext,
      bool? makeCurrentContext = true,
      bool? isFirstClass = true}) {
    return _client.startSpan(
      name,
      startTime: startTime,
      parentContext: parentContext,
      makeCurrentContext: makeCurrentContext,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'custom',
        isFirstClass: isFirstClass,
      ),
    );
  }

  BugsnagPerformanceSpan startNetworkSpan(String url, String httpMethod) {
    return _client.startNetworkSpan(url, httpMethod.toUpperCase());
  }

  Future<void> measureRunApp(
    FutureOr<void> Function() runApp,
  ) async {
    await _client.measureRunApp(runApp);
  }

  // Intended for internal-use only
  void setExtraConfig(String key, dynamic value) {
    _client.setExtraConfig(key, value);
  }

  dynamic networkInstrumentation(dynamic data) {
    return _client.networkInstrumentation(data);
  }
}

// ignore: non_constant_identifier_names
final BugsnagPerformance bugsnag_performance = BugsnagPerformance._();
