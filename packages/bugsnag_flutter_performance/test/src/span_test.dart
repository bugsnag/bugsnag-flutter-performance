import 'package:bugsnag_flutter_performance/src/extensions/date_time.dart';
import 'package:bugsnag_flutter_performance/src/extensions/int.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:bugsnag_flutter_performance/src/util/random.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const millisecondsSinceEpoch = 1640979000000;
  BugsnagClockImpl.ensureInitialized();

  group('BugsnagPerformanceSpanImpl', () {
    test('should have the provided name, start time, traceId and spanId', () {
      final traceId = randomTraceId();
      final spanId = randomSpanId();
      final span = BugsnagPerformanceSpanImpl(
        name: 'Test name',
        startTime: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
            isUtc: true),
        traceId: traceId,
        spanId: spanId,
      );
      expect(
        span.name,
        equals('Test name'),
      );
      expect(
        span.startTime,
        equals(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
            isUtc: true)),
      );
      expect(span.traceId, equals(traceId));
      expect(span.spanId, equals(spanId));
      expect(span.parentSpanId, isNull);
      expect(span.endTime, isNull);
    });

    test('should have random traceId and spanId if it is not provided', () {
      final span1 = BugsnagPerformanceSpanImpl(
        name: 'Test name',
        startTime: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
            isUtc: true),
      );
      final span2 = BugsnagPerformanceSpanImpl(
        name: 'Test name',
        startTime: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
            isUtc: true),
      );
      expect(span1.spanId != span2.spanId, isTrue);
      expect(span1.traceId != span2.traceId, isTrue);
    });

    test('should have the provided parentId', () {
      final parentSpanId = randomSpanId();
      final traceId = randomTraceId();
      final span = BugsnagPerformanceSpanImpl(
        name: 'Test name',
        startTime: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
            isUtc: true),
        traceId: traceId,
        parentSpanId: parentSpanId,
      );
      expect(span.traceId, equals(traceId));
      expect(span.parentSpanId, equals(parentSpanId));
    });

    group('end', () {
      test('should set the current time as end time if the span has not ended',
          () {
        final span = BugsnagPerformanceSpanImpl(
            name: 'Test name',
            startTime: DateTime.fromMillisecondsSinceEpoch(
                millisecondsSinceEpoch,
                isUtc: true));
        span.clock = BugsnagClockImpl.instance;
        final timeBeforeEnd = BugsnagClockImpl.instance.now();
        span.end();
        final timeAfterEnd = BugsnagClockImpl.instance.now();
        expect(
            span.endTime!.nanosecondsSinceEpoch >=
                timeBeforeEnd.nanosecondsSinceEpoch,
            isTrue);
        expect(
            span.endTime!.nanosecondsSinceEpoch <=
                timeAfterEnd.nanosecondsSinceEpoch,
            isTrue);
      });

      test('should not override the end time if the span has ended', () async {
        final span = BugsnagPerformanceSpanImpl(
            name: 'Test name',
            startTime: DateTime.fromMillisecondsSinceEpoch(
                millisecondsSinceEpoch,
                isUtc: true));
        span.clock = BugsnagClockImpl.instance;
        span.end();
        final firstEndTime = span.endTime;
        await Future.delayed(const Duration(milliseconds: 10));
        span.end();
        expect(span.endTime!.nanosecondsSinceEpoch,
            equals(firstEndTime!.nanosecondsSinceEpoch));
      });
    });

    group('fromJson', () {
      test('should decode an ended span', () {
        const endTime = millisecondsSinceEpoch + 100;
        const name = 'Test name';
        final json = {
          'name': name,
          'startTimeUnixNano': DateTime.fromMillisecondsSinceEpoch(
                  millisecondsSinceEpoch,
                  isUtc: true)
              .nanosecondsSinceEpoch
              .toString(),
          'endTimeUnixNano':
              DateTime.fromMillisecondsSinceEpoch(endTime, isUtc: true)
                  .nanosecondsSinceEpoch
                  .toString(),
          'traceId': 'ffa74cc50baa432515e9b28fc4abf2cb',
          'spanId': 'fa0e2d25f149f215',
          'parentSpanId': '6293f00f47da54de',
        };
        final span = BugsnagPerformanceSpanImpl.fromJson(json);
        expect(span.name, equals(name));
        expect(
            span.startTime,
            equals((int.parse(json['startTimeUnixNano'] as String))
                .timeFromNanos));
        expect(
            span.endTime,
            equals(
                (int.parse(json['endTimeUnixNano'] as String)).timeFromNanos));
        expect(span.traceId,
            equals(BigInt.tryParse(json['traceId'] as String, radix: 16)!));
        expect(span.spanId,
            equals(BigInt.tryParse(json['spanId'] as String, radix: 16)!));
        expect(
            span.parentSpanId,
            equals(
                BigInt.tryParse(json['parentSpanId'] as String, radix: 16)!));
      });

      test('should decode a running span', () {
        const name = 'Test name';
        final json = {
          'name': name,
          'startTimeUnixNano': DateTime.fromMillisecondsSinceEpoch(
                  millisecondsSinceEpoch,
                  isUtc: true)
              .nanosecondsSinceEpoch
              .toString(),
        };
        final span = BugsnagPerformanceSpanImpl.fromJson(json);
        expect(span.name, equals(name));
        expect(
            span.startTime,
            equals(
                int.parse(json['startTimeUnixNano'] as String).timeFromNanos));
        expect(span.endTime, isNull);
      });
    });

    group('toJson', () {
      test('should encode an ended span', () {
        final span = BugsnagPerformanceSpanImpl(
          name: 'Test name',
          startTime: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
              isUtc: true),
          traceId: randomTraceId(),
          parentSpanId: randomSpanId(),
        );
        span.clock = BugsnagClockImpl.instance;
        span.end();
        final json = span.toJson();
        expect(json['name'], equals(span.name));
        expect(int.parse(json['startTimeUnixNano']),
            equals(span.startTime.nanosecondsSinceEpoch));
        expect(int.parse(json['endTimeUnixNano']),
            equals(span.endTime!.nanosecondsSinceEpoch));
        expect(json['traceId'], equals(span.traceId.toRadixString(16)));
        expect(json['spanId'], equals(span.spanId.toRadixString(16)));
        expect(
            json['parentSpanId'], equals(span.parentSpanId!.toRadixString(16)));
      });

      test('should encode a running span', () {
        final span = BugsnagPerformanceSpanImpl(
            name: 'Test name',
            startTime: DateTime.fromMillisecondsSinceEpoch(
                millisecondsSinceEpoch,
                isUtc: true));
        final json = span.toJson();
        expect(json['name'], equals(span.name));
        expect(int.parse(json['startTimeUnixNano']),
            equals(span.startTime.nanosecondsSinceEpoch));
        expect(json['endTimeUnixNano'], isNull);
      });
    });
  });
}
