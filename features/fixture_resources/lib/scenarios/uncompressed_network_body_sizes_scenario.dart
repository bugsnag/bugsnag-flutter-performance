import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';

import 'scenario.dart';

class UncompressedNetworkBodySizesScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();

    // Ensure the batch is flushed immediately.
    setMaxBatchSize(1);

    // Use a custom span so we can deterministically set attributes.
    final span = bugsnag_performance.startSpan('UncompressedBodySizes');
    span.end(
      uncompressedRequestContentLength: 123,
      uncompressedResponseContentLength: 456,
    );
  }
}


