import 'package:bugsnag_flutter_performance/src/configuration.dart';
import 'package:bugsnag_flutter_performance/src/extensions/bugsnag_lifecycle_listener.dart';
import 'package:bugsnag_flutter_performance/src/extensions/date_time.dart';
import 'package:bugsnag_flutter_performance/src/extensions/int.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:bugsnag_flutter_performance/src/util/random.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const millisecondsSinceEpoch = 1640979000000;
  BugsnagClockImpl.ensureInitialized();
  BugsnagLifecycleListenerImpl.ensureInitialized();

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
          'attributes': [
            {
              'key': 'custom',
              'value': {'stringValue': 'value'}
            },
            {
              'key': 'customArray',
              'value': {
                'arrayValue': {
                  'values': [
                    {'stringValue': 'testValue'},
                    {'intValue': '1'},
                    {'doubleValue': 4.2},
                    {'boolValue': true},
                  ]
                }
              }
            },
          ],
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
        expect(
            span.attributes.attributes['customArray'],
            equals([
              'testValue',
              1,
              4.2,
              true,
            ]));
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
          'attributes': [
            {
              'key': 'custom',
              'value': {'stringValue': 'value'}
            },
          ],
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
        span.setAttribute('customString', 'testValue');
        span.setAttribute('customInt', 2);
        span.setAttribute('list', [42, 43.0, 'testString', false, true, 1]);
        span.end();
        final json = span.toJson();
        expect(json['name'], equals(span.name));
        expect(int.parse(json['startTimeUnixNano']),
            equals(span.startTime.nanosecondsSinceEpoch));
        expect(int.parse(json['endTimeUnixNano']),
            equals(span.endTime!.nanosecondsSinceEpoch));
        expect(json['traceId'],
            equals(span.traceId.toRadixString(16).padLeft(32, '0')));
        expect(json['traceId'].toString().length, equals(32));
        expect(json['spanId'],
            equals(span.spanId.toRadixString(16).padLeft(16, '0')));
        expect(json['parentSpanId'],
            equals(span.parentSpanId!.toRadixString(16).padLeft(16, '0')));
        final attributes = json['attributes'] as List<Map<String, dynamic>>;
        expect(
          attributes[0],
          equals({
            'key': 'customString',
            'value': {'stringValue': 'testValue'},
          }),
        );
        expect(
          attributes[1],
          equals({
            'key': 'customInt',
            'value': {'intValue': '2'},
          }),
        );
        expect(
          attributes[2],
          equals({
            'key': 'list',
            'value': {
              'arrayValue': {
                'values': [
                  {'intValue': '42'},
                  {'doubleValue': 43.0},
                  {'stringValue': 'testString'},
                  {'boolValue': false},
                  {'boolValue': true},
                  {'intValue': '1'},
                ],
              }
            },
          }),
        );
        expect(json['droppedAttributesCount'], isNull);
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
        expect(json['droppedAttributesCount'], isNull);
      });

      test('should drop attributes with too long keys', () {
        const tooLongKey =
            'trberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwc';
        const tooLongKey2 =
            'Atrbesfsdffrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwc';
        final span = BugsnagPerformanceSpanImpl(
            name: 'Test name',
            startTime: DateTime.fromMillisecondsSinceEpoch(
                millisecondsSinceEpoch,
                isUtc: true));
        span.clock = BugsnagClockImpl.instance;
        span.setAttribute(tooLongKey, 'test');
        span.setAttribute(tooLongKey2, 'test2');
        span.setAttribute('TestBool', false);
        span.end();
        final json = span.toJson();
        final attributes = json['attributes'] as List<Map<String, dynamic>>;
        expect(attributes.length, equals(1));
        expect(
            attributes[0],
            equals({
              'key': 'TestBool',
              'value': {'boolValue': false},
            }));
        expect(json['droppedAttributesCount'], equals(2));
      });

      test(
          'should include attributes added over limit along with those with too long keys in droppedAttributesCount',
          () {
        const tooLongKey =
            'trberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwc';
        const tooLongKey2 =
            'Atrbesfsdffrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwctrberwfqfrefwefrgrewfrfwefwftvrvwreqwcwc';
        final span = BugsnagPerformanceSpanImpl(
          name: 'Test name',
          startTime: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
              isUtc: true),
          attributeCountLimit: 3,
        );
        span.clock = BugsnagClockImpl.instance;
        span.setAttribute('TestInt', 1);
        span.setAttribute(tooLongKey, 'test');
        span.setAttribute(tooLongKey2, 'test2');
        span.setAttribute('TestBool', false);
        span.setAttribute('TestBool2', true);
        span.setAttribute('TestInt', 2);
        span.setAttribute('TestInt', 3);
        span.end();
        final json = span.toJson();
        final attributes = json['attributes'] as List<Map<String, dynamic>>;
        expect(attributes.length, equals(1));
        expect(
            attributes[0],
            equals({
              'key': 'TestInt',
              'value': {'intValue': '3'},
            }));
        expect(json['droppedAttributesCount'], equals(4));
      });

      test('should truncate strings and arrays that go over the limits', () {
        final span = BugsnagPerformanceSpanImpl(
          name: 'Test name',
          startTime: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
              isUtc: true),
        );
        span.clock = BugsnagClockImpl.instance;
        span.setAttribute('TestString', 'test');
        span.setAttribute('LongTestString', 'This is a very long string');
        span.setAttribute('TestArray', [true, '2', 3.0, 4, '5', 6.0, 7]);
        span.end();
        final config = BugsnagPerformanceConfiguration(
          attributeCountLimit: 100,
          attributeStringValueLimit: 10,
          attributeArrayLengthLimit: 4,
        );
        final json = span.toJson(config: config);
        final attributes = json['attributes'] as List<Map<String, dynamic>>;
        expect(attributes.length, equals(3));
        expect(
            attributes[0],
            equals({
              'key': 'TestString',
              'value': {'stringValue': 'test'},
            }));
        expect(
            attributes[1],
            equals({
              'key': 'LongTestString',
              'value': {'stringValue': 'This is a *** 16 CHARS TRUNCATED'},
            }));
        expect(
            attributes[2],
            equals({
              'key': 'TestArray',
              'value': {
                'arrayValue': {
                  'values': [
                    {'boolValue': true},
                    {'stringValue': '2'},
                    {'doubleValue': 3.0},
                    {'intValue': '4'}
                  ],
                }
              },
            }));
        expect(json['droppedAttributesCount'], isNull);
      });
    });
  });
}
