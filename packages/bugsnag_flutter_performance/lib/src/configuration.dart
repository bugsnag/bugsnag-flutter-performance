class BugsnagPerformanceConfiguration {
  BugsnagPerformanceConfiguration({this.apiKey, this.endpoint});
  String? apiKey;
  Uri? endpoint;
  int autoTriggerExportOnBatchSize = 100;
  int autoExportBatchAfterSeconds = 60;
  int probabilityRequestsPause = 30000;
  int probabilityValueExpireTime = 24 * 3600 * 1000;
  bool instrumentAppStart = true;
  bool instrumentNavigation = true;

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
      case 'instrumentAppStart':
        instrumentAppStart = value;
        break;
      case 'instrumentNavigation':
        instrumentNavigation = value;
        break;
        case 'autoExportBatchAfterSeconds':
        autoExportBatchAfterSeconds = value;
        break;
    }
  }
}
