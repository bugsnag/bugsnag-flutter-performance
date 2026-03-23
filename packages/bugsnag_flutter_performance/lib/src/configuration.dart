import 'package:flutter/foundation.dart';
import 'package:bugsnag_flutter_performance/src/metrics/enabled_metrics.dart';

class BugsnagPerformanceConfiguration {
  BugsnagPerformanceConfiguration({
    this.apiKey,
    this.endpoint,
    this.releaseStage,
    this.enabledReleaseStages,
    this.tracePropagationUrls,
    this.serviceName,
    this.appVersion,
    this.samplingProbability,
    required this.attributeCountLimit,
    required this.attributeStringValueLimit,
    required this.attributeArrayLengthLimit,
    EnabledMetrics? enabledMetrics,
  }) : enabledMetrics = enabledMetrics ?? const EnabledMetrics();

  String? apiKey;
  Uri? endpoint;
  EnabledMetrics enabledMetrics;
  int maxBatchSize = 100;
  int maxBatchAge = kDebugMode
      ? 5 * 1000
      : 60 * 1000; // 5 seconds for debug, 60 seconds for release
  int probabilityRequestsPause = 30000;
  int probabilityValueExpireTime = 24 * 3600 * 1000;
  bool instrumentAppStart = true;
  bool instrumentNavigation = true;
  bool instrumentViewLoad = true;
  List<RegExp>? tracePropagationUrls;
  String? releaseStage;
  List<String>? enabledReleaseStages;
  String? serviceName;
  String? appVersion;
  double? samplingProbability;
  int attributeCountLimit;
  int attributeStringValueLimit;
  int attributeArrayLengthLimit;

  bool releaseStageEnabled() {
    return releaseStage == null ||
        enabledReleaseStages == null ||
        enabledReleaseStages!.contains(releaseStage);
  }

  void applyExtraConfig(String key, dynamic value) {
    switch (key) {
      case 'maxBatchSize':
        maxBatchSize = value;
        break;
      case 'probabilityRequestsPause':
        probabilityRequestsPause = value;
        break;
      case 'probabilityValueExpireTime':
        probabilityValueExpireTime = value;
        break;
      case 'instrumentAppStart':
        instrumentAppStart = value;
        break;
      case 'instrumentNavigation':
        instrumentNavigation = value;
        break;
      case 'instrumentViewLoad':
        instrumentViewLoad = value;
        break;
      case 'tracePropagationUrls':
        tracePropagationUrls = value;
      case 'maxBatchAge':
        maxBatchAge = value;
        break;
    }
  }
}
