import 'dart:async';

import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'client_test.dart';

void main() {
  group('BugsnagPerformanceClientImpl Span Context', () {
    late BugsnagPerformanceClientImpl client;
    final lifecycleListener = MockLifecycleListener();
    setUp(() {
      client =
          BugsnagPerformanceClientImpl(lifecycleListener: lifecycleListener);
      client.retryQueueBuilder = MockRetryQueueBuilder();
    });

    test('simple span context parentage', () {
      final span1 = client.startSpan('span1');
      final span2 = client.startSpan('span2');
      span1.end();
      span2.end();

      expect(span1.parentSpanId, isNull, reason: 'span1 should have no parent');
      expect(span2.parentSpanId, equals(span1.spanId),
          reason: 'span1 is parent of span2');
      expect(span1.traceId, equals(span2.traceId),
          reason: 'trace ids should match');
    });

    test('span context in nested zone', () {
      final outside = client.startSpan('outside span');

      final [nestedOpen, nestedClosed] = Zone.current.fork().run(() {
        final span2 = client.startSpan('inside span');
        final span3 = client.startSpan('very nested span');
        span3.end();

        return [span2, span3];
      });

      final outsideNested = client.startSpan('outside but nested');
      outsideNested.end();
      nestedOpen.end();
      outside.end();

      expect(outside.parentSpanId, isNull,
          reason: 'root span should have no parent');
      expect(nestedOpen.parentSpanId, isNull,
          reason: 'zoned root should have no parent');
      expect(nestedClosed.parentSpanId, nestedOpen.spanId,
          reason: 'zoned child should have zoned root as parent');
      expect(outsideNested.parentSpanId, outside.spanId,
          reason: 'outside child should have outside root as parent');
      expect(outside.traceId, outsideNested.traceId,
          reason: 'outside spans should share traceId');
      expect(nestedOpen.traceId, nestedClosed.traceId,
          reason: 'zoned spans should share traceId');
    });
  });
}
