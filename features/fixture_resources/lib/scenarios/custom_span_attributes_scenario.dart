import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';

import 'scenario.dart';

class CustomSpanAttributesScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(onSpanEndCallbacks: [
      _setAttributesAndThrow,
      _discardUnwantedSpan,
      _setAttributes,
    ]);
    setMaxBatchSize(1);
    doSimpleSpan('CustomSpanAttributesScenarioDiscaredSpan');
    final span =
        bugsnag_performance.startSpan('CustomSpanAttributesScenarioSpan');
    span.setAttribute('customAttribute1', 42);
    span.setAttribute('customAttribute2', 'Test');
    span.setAttribute('customAttribute3', 1);
    span.end();
    span.setAttribute('customAttribute5', 'T');
  }

  Future<bool> _setAttributesAndThrow(BugsnagPerformanceSpan span) async {
    span.setAttribute('customAttribute1', 'C');
    throw Exception('');
  }

  Future<bool> _discardUnwantedSpan(BugsnagPerformanceSpan span) async {
    if (span.name == 'CustomSpanAttributesScenarioDiscaredSpan') {
      return false;
    }
    return true;
  }

  Future<bool> _setAttributes(BugsnagPerformanceSpan span) async {
    span.setAttribute('customAttribute3', 2);
    span.setAttribute('customAttribute3', 3);
    span.setAttribute('customAttribute2', null);
    span.setAttribute('customAttribute4', 42.0);
    return true;
  }
}
