import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart';
import 'package:dio/io.dart';
import '../main.dart';
import 'scenario.dart';
import 'package:bugsnag_flutter_dart_io_http_client/bugsnag_flutter_dart_io_http_client.dart'
    as dart_io;
import 'package:dio/dio.dart';

class DIOCallbackCancelSpanScenario extends Scenario {
  @override
  Future<void> run() async {
    bugsnag_performance.setExtraConfig("instrumentAppStart", false);
    await bugsnag_performance.start(
        apiKey: '12312312312312312312312312312312',
        endpoint: Uri.parse('${FixtureConfig.MAZE_HOST}/traces'),
        networkRequestCallback: (info) {
          return null;
        });
    setMaxBatchSize(1);
    dart_io.addSubscriber(bugsnag_performance.networkInstrumentation);
    final dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return dart_io.BugsnagHttpClient();
      },
    );
    dio.get(FixtureConfig.MAZE_HOST.toString());
    await Future.delayed(const Duration(seconds: 10));
    doSimpleSpan('DIOCallbackCancelSpanScenario');
  }
}
