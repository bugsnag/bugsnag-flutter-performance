import '../bugsnag_flutter_performance.dart';

class BugsnagPerformance
{

  static final BugsnagPerformanceClient _client = BugsnagPerformanceClient();

  static Future<void> start({String? apiKey, Uri? endpoint}) async {
    return _client.start(apiKey: apiKey, endpoint: endpoint);
  }

  static BugsnagPerformanceSpan startSpan(String name) {
    return _client.startSpan(name);
  }

  static void runApp(Widget app)
  {
    _client.runApp(app);
  }

}