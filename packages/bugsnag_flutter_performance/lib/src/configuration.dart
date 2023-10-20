class BugsnagPerformanceConfiguration {
  BugsnagPerformanceConfiguration({this.apiKey, this.endpoint});
  String? apiKey;
  Uri? endpoint;
  int autoTriggerExportOnBatchSize = 100;
}
