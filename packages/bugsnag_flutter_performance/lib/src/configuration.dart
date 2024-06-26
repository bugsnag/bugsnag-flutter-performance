class BugsnagPerformanceConfiguration {
  BugsnagPerformanceConfiguration(
      {this.apiKey,
      this.endpoint,
      this.releaseStage,
      this.enabledReleaseStages,
      this.tracePropagationUrls,
      this.appVersion});
  String? apiKey;
  Uri? endpoint;
  int maxBatchSize = 100;
  int maxBatchAge = 60 * 1000; // milliseconds
  int probabilityRequestsPause = 30000;
  int probabilityValueExpireTime = 24 * 3600 * 1000;
  bool instrumentAppStart = true;
  bool instrumentNavigation = true;
  bool instrumentViewLoad = true;
  List<RegExp>? tracePropagationUrls;
  String? releaseStage;
  List<String>? enabledReleaseStages;
  String? appVersion;

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
