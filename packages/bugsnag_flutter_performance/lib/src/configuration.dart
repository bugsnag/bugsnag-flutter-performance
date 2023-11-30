class BugsnagPerformanceConfiguration {
  BugsnagPerformanceConfiguration({this.apiKey, this.endpoint});
  String? apiKey;
  Uri? endpoint;
  int autoTriggerExportOnBatchSize = 100;
  int probabilityRequestsPause = 30000;
  int probabilityValueExpireTime = 24 * 3600 * 1000;

  void applyExtraConfig(String key, dynamic value) {
    switch (key) {
      case 'autoTriggerExportOnBatchSize':
        autoTriggerExportOnBatchSize = value;
        break;
      case 'probabilityRequestsPause':
        probabilityRequestsPause = value;
        break;
      case 'probabilityValueExpireTime':
        probabilityValueExpireTime = value;
        break;
    }
  }
}
