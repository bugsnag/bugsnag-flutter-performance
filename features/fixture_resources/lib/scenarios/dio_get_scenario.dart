import 'package:bugsnag_flutter_dart_io_http_client/bugsnag_flutter_dart_io_http_client.dart' as dart_io;
import 'package:dio/dio.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:dio/io.dart';
import '../main.dart';
import 'scenario.dart';

class DIOGetScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    setMaxBatchSize(1);

    dart_io.addSubscriber(BugsnagPerformance.networkInstrumentation);
    final dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return dart_io.BugsnagHttpClient();
      },
    );

    dio.get(FixtureConfig.MAZE_HOST.toString());

  }
}
