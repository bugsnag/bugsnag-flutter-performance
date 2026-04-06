import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';

import 'scenario.dart';

/// Creates a span and sets the uncompressed request/response body size attributes.
///
/// This is used by MazeRunner feature tests to validate the
/// [BugsnagPerformanceSpanAttributes.uncompressedRequestContentLength] and
/// [BugsnagPerformanceSpanAttributes.uncompressedResponseContentLength] helpers.
class UncompressedNetworkBodySizesScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();

    // Ensure the batch is flushed immediately.
    setMaxBatchSize(1);

    // Use a custom span so we can deterministically set attributes.
    final span = bugsnag_performance.startSpan('UncompressedBodySizes');
    span.setAttribute('http.request.body.size', 123);
    span.setAttribute('http.response.body.size', 456);
    span.end();
  }
}


