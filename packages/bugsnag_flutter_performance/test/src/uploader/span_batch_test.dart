import 'package:bugsnag_flutter_performance/src/configuration.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';
import 'package:bugsnag_flutter_performance/src/uploader/span_batch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpanBatch', () {
    late SpanBatch batch;

    setUp(() {
      batch = SpanBatchImpl();
    });

    test('should trigger batch full every time if not configured', () {
      int batchFullTriggeredCount = 0;
      batch.onBatchFull = (_) => batchFullTriggeredCount++;

      final span1 =
          BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
      final span2 =
          BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
      batch.add(span1);
      expect(batchFullTriggeredCount, equals(1));
      batch.add(span2);
      expect(batchFullTriggeredCount, equals(2));

      expect(batch.drain(), equals([span1, span2]));
    });

    group('when configured', () {
      const batchSize = 4;

      setUp(() {
        batch.configure(
          BugsnagPerformanceConfiguration()
            ..autoTriggerExportOnBatchSize = batchSize,
        );
      });

      group('add', () {
        test(
            'should trigger batch full after it reaches export on batch size value',
            () {
          int batchFullTriggeredCount = 0;
          batch.onBatchFull = (_) => batchFullTriggeredCount++;

          batch.add(
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now()));
          expect(batchFullTriggeredCount, equals(0));
          batch.add(
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now()));
          expect(batchFullTriggeredCount, equals(0));
          batch.add(
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now()));
          expect(batchFullTriggeredCount, equals(0));
          batch.add(
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now()));
          expect(batchFullTriggeredCount, equals(1));
        });
      });

      group('remove', () {
        test('should remove the span from the batch', () {
          final unrelatedSpan1 =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          final spanToRemove =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          final unrelatedSpan2 = BugsnagPerformanceSpanImpl(
            name: '',
            startTime: DateTime.now(),
            parentSpanId: unrelatedSpan1.spanId,
          );
          final unrelatedSpan3 = BugsnagPerformanceSpanImpl(
            name: '',
            startTime: DateTime.now(),
            parentSpanId: unrelatedSpan2.spanId,
          );
          batch.add(unrelatedSpan1);
          batch.add(spanToRemove);
          batch.add(unrelatedSpan2);
          batch.add(unrelatedSpan3);

          batch.remove(spanToRemove.traceId, spanToRemove.spanId);
          batch.allowDrain();
          expect(
            batch.drain(),
            equals([unrelatedSpan1, unrelatedSpan2, unrelatedSpan3]),
          );
        });

        test('should change parentId of child spans', () {
          final unrelatedSpan1 =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          final spanToRemove =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          final childSpan1 = BugsnagPerformanceSpanImpl(
            name: '',
            startTime: DateTime.now(),
            traceId: spanToRemove.traceId,
            parentSpanId: spanToRemove.spanId,
          );
          final spanFromAnotherTrace = BugsnagPerformanceSpanImpl(
            name: '',
            startTime: DateTime.now(),
            parentSpanId: spanToRemove.spanId,
          );
          final childSpan2 = BugsnagPerformanceSpanImpl(
            name: '',
            startTime: DateTime.now(),
            traceId: spanToRemove.traceId,
            parentSpanId: spanToRemove.spanId,
          );
          batch.add(unrelatedSpan1);
          batch.add(spanToRemove);
          batch.add(childSpan1);
          batch.add(spanFromAnotherTrace);
          batch.add(childSpan2);

          batch.remove(spanToRemove.traceId, spanToRemove.spanId);
          batch.allowDrain();
          final spans = batch.drain();
          expect(spans.length, equals(4));
          expect(spans[0].spanId, equals(unrelatedSpan1.spanId));
          expect(spans[0].parentSpanId, isNull);
          expect(spans[1].spanId, equals(childSpan1.spanId));
          expect(spans[1].parentSpanId, isNull);
          expect(spans[2].spanId, equals(spanFromAnotherTrace.spanId));
          expect(spans[2].parentSpanId, equals(spanToRemove.spanId));
          expect(spans[3].spanId, equals(childSpan2.spanId));
          expect(spans[3].parentSpanId, isNull);
        });
      });

      group('drain', () {
        test(
            'should return empty list if the batch is not full and it is not forced',
            () {
          batch.add(
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now()));
          expect(batch.drain().length, equals(0));
        });

        test('should return all spans if the batch is full', () {
          final span1 =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          final span2 =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          final span3 =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          final span4 =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          batch.add(span1);
          batch.add(span2);
          batch.add(span3);
          batch.add(span4);
          expect(
            batch.drain(),
            equals([span1, span2, span3, span4]),
          );
        });

        test('should clear the spans list', () {
          final span1 =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          final span2 =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          final span3 =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          final span4 =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          batch.add(span1);
          batch.add(span2);
          batch.add(span3);
          batch.add(span4);
          batch.drain();
          expect(
            batch.drain(),
            equals([]),
          );
        });

        test(
            'should return the spans if the batch is not full and it is forced',
            () {
          final span =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          batch.add(span);
          expect(
            batch.drain(force: true),
            equals([span]),
          );
        });

        test(
            'should return the spans if the batch is not full and allowDrain was called',
            () {
          final span =
              BugsnagPerformanceSpanImpl(name: '', startTime: DateTime.now());
          batch.add(span);
          batch.allowDrain();
          expect(
            batch.drain(),
            equals([span]),
          );
        });
      });
    });
  });
}
