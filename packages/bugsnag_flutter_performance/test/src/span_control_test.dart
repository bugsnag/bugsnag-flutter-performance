import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bugsnag_flutter_performance/src/span_controls.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';

class MockSpan extends BugsnagPerformanceSpanImpl {
  bool open;
  MockSpan({this.open = true}) : super(
    name: 'test',
    startTime: DateTime.now(),
  ) {
    clock = _MockClock() as BugsnagClock;
  }
  @override
  bool isOpen() => open;
}

class _MockClock implements BugsnagClock {
  @override
  DateTime now() => DateTime.now();
}

class RealOpenSpan extends BugsnagPerformanceSpanImpl {
  RealOpenSpan({required String name}) : super(
    name: name,
    startTime: DateTime.now(),
  ) {
    clock = _MockClock();
  }
  @override
  bool isOpen() => true;
}

class RealClosedSpan extends BugsnagPerformanceSpanImpl {
  RealClosedSpan({required String name}) : super(
    name: name,
    startTime: DateTime.now(),
  ) {
    clock = _MockClock();
  }
  @override
  bool isOpen() => false;
}

void main() {

  group('AppStartSpanControlImpl', () {
    test('setType sets attribute and name when span is open', () {
      final span = RealOpenSpan(name: 'real');
      final control = AppStartSpanControlImpl(span);
      control.setType('cold');
      expect(span.attributes.attributes['bugsnag.app_start.name'], 'cold');
      expect(span.name, '[AppStart/FlutterInit]cold');
    });

    test('setType does nothing if span is not open', () {
      final span = RealClosedSpan(name: 'real');
      final control = AppStartSpanControlImpl(span);
      control.setType('warm');
      expect(span.attributes.attributes['bugsnag.app_start.name'], isNull);
      expect(span.name, 'real');
    });

    test('clearType resets the type and updates the name', () {
      final span = RealOpenSpan(name: 'real');
      final control = AppStartSpanControlImpl(span);
      control.setType('cold');
      control.clearType();
      expect(span.attributes.attributes['bugsnag.app_start.name'], isNull);
      expect(span.name, '[AppStart/FlutterInit]');
    });
  });
}
