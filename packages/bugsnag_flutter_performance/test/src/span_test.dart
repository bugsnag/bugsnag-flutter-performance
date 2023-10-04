import 'package:bugsnag_flutter_performance/src/extensions/date_time.dart';
import 'package:bugsnag_flutter_performance/src/extensions/int.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const millisecondsSinceEpoch = 1640979000000;
  group('BugsnagPerformanceSpanImpl', () {
    test('should have the provided name and provided start time', () {
      final span = BugsnagPerformanceSpanImpl(
          name: 'Test name',
          startTime: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
              isUtc: true));
      expect(
        span.name,
        equals('Test name'),
      );
      expect(
        span.startTime,
        equals(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
            isUtc: true)),
      );
      expect(span.endTime, isNull);
    });

    group('end', () {
      test('should set the current time as end time if the span has not ended',
          () {
        final span = BugsnagPerformanceSpanImpl(
            name: 'Test name',
            startTime: DateTime.fromMillisecondsSinceEpoch(
                millisecondsSinceEpoch,
                isUtc: true));
        final timeBeforeEnd = DateTime.now();
        span.end();
        final timeAfterEnd = DateTime.now();
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
              .nanosecondsSinceEpoch,
          'endTimeUnixNano':
              DateTime.fromMillisecondsSinceEpoch(endTime, isUtc: true)
                  .nanosecondsSinceEpoch,
        };
        final span = BugsnagPerformanceSpanImpl.fromJson(json);
        expect(span.name, equals(name));
        expect(span.startTime,
            equals((json['startTimeUnixNano'] as int).timeFromNanos));
        expect(span.endTime,
            equals((json['endTimeUnixNano'] as int).timeFromNanos));
      });

      test('should decode a running span', () {
        const name = 'Test name';
        final json = {
          'name': name,
          'startTimeUnixNano': DateTime.fromMillisecondsSinceEpoch(
                  millisecondsSinceEpoch,
                  isUtc: true)
              .nanosecondsSinceEpoch,
        };
        final span = BugsnagPerformanceSpanImpl.fromJson(json);
        expect(span.name, equals(name));
        expect(span.startTime,
            equals((json['startTimeUnixNano'] as int).timeFromNanos));
        expect(span.endTime, isNull);
      });
    });

    group('toJson', () {
      test('should encode an ended span', () {
        final span = BugsnagPerformanceSpanImpl(
            name: 'Test name',
            startTime: DateTime.fromMillisecondsSinceEpoch(
                millisecondsSinceEpoch,
                isUtc: true));
        span.end();
        final json = span.toJson();
        expect(json['name'], equals(span.name));
        expect(json['startTimeUnixNano'],
            equals(span.startTime.nanosecondsSinceEpoch));
        expect(json['endTimeUnixNano'],
            equals(span.endTime!.nanosecondsSinceEpoch));
      });

      test('should encode a running span', () {
        final span = BugsnagPerformanceSpanImpl(
            name: 'Test name',
            startTime: DateTime.fromMillisecondsSinceEpoch(
                millisecondsSinceEpoch,
                isUtc: true));
        final json = span.toJson();
        expect(json['name'], equals(span.name));
        expect(json['startTimeUnixNano'],
            equals(span.startTime.nanosecondsSinceEpoch));
        expect(json['endTimeUnixNano'], isNull);
      });
    });
  });
}
