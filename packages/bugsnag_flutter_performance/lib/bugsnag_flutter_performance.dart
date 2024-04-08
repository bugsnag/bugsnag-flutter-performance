library bugsnag_flutter_performance;

import 'dart:async';

import 'package:bugsnag_flutter_performance/src/bugsnag_network_request_info.dart';
import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:bugsnag_flutter_performance/src/span_attributes.dart';

import 'bugsnag_flutter_performance.dart';
export 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart'
    show bugsnag_performance;
export 'package:bugsnag_flutter_performance/src/span_context.dart'
    show BugsnagPerformanceSpanContext;
export 'src/span.dart' show BugsnagPerformanceSpan;
export 'src/widgets/bugsnag_loading_indicator.dart'
    show BugsnagLoadingIndicator;
export 'src/widgets/bugsnag_navigation_container.dart'
    show BugsnagNavigationContainer;

class InvalidBugsnagApiKeyException implements Exception {
  String message;
  InvalidBugsnagApiKeyException(this.message);

  @override
  String toString() => "InvalidApiKeyException: $message";
}

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
    bool? instrumentAppStarts,
  }) {
    _validateApiKey(apiKey);
    return _client.start(
      apiKey: apiKey,
      endpoint: endpoint,
      networkRequestCallback: networkRequestCallback,
      releaseStage: releaseStage,
      enabledReleaseStages: enabledReleaseStages,
      appVersion: appVersion,
      instrumentAppStarts: instrumentAppStarts,
    );
  }

  void _validateApiKey(String apiKey) {
    final RegExp regExp = RegExp(r'^[0-9a-fA-F]{32}$');
    if (apiKey.isEmpty || !regExp.hasMatch(apiKey)) {
      throw InvalidBugsnagApiKeyException(
          "Invalid configuration. apiKey should be a 32-character hexademical string, got $apiKey");
    }
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

  BugsnagPerformanceSpanContext? getCurrentSpanContext() {
    return _client.getCurrentSpanContext();
  }
}

// ignore: non_constant_identifier_names
final BugsnagPerformance bugsnag_performance = BugsnagPerformance._internal();
