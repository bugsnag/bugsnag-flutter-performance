import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';

import 'scenario.dart';

class CustomSpanAttributesWithLimitsScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
        attributeCountLimit: 8,
        attributeStringValueLimit: 20,
        attributeArrayLengthLimit: 6,
        onSpanEndCallbacks: [
          _setAttributes,
        ]);
    setMaxBatchSize(1);
    final span = bugsnag_performance
        .startSpan('CustomSpanAttributesWithLimitsScenarioSpan');
    const tooLongKey =
        'trberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwc';
    span.setAttribute('customAttribute1', 42);
    span.setAttribute(tooLongKey, 'Test');
    span.setAttribute('customAttribute2', 1);
    span.setAttribute('customAttribute3', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    span.setAttribute(
        'customAttribute4', 'VeryLongStringAttributeValueThatExceedsTheLimit');
    span.setAttribute('customAttribute5', 42.0);
    span.setAttribute('customAttribute6', 'Dropped');
    span.end();
  }

  Future<bool> _setAttributes(BugsnagPerformanceSpan span) async {
    span.setAttribute('customAttribute7', 'Droppedtoo');
    span.setAttribute('customAttribute2', 'NotDropped');
    return true;
  }
}
