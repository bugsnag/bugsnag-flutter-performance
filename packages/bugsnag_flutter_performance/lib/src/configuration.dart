class BugsnagPerformanceConfiguration {
  BugsnagPerformanceConfiguration({this.apiKey, this.endpoint});
  String? apiKey;
  Uri? endpoint;
  int autoTriggerExportOnBatchSize = 100;

  void applyExtraConfig(String key, dynamic value) {
    switch (key) {
      case 'autoTriggerExportOnBatchSize':
        autoTriggerExportOnBatchSize = value;
        break;
    }
  }
}
