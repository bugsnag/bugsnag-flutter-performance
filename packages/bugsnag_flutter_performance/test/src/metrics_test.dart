import 'package:flutter_test/flutter_test.dart';
import 'package:bugsnag_flutter_performance/src/metrics/enabled_metrics.dart';
import 'package:bugsnag_flutter_performance/src/metrics/span_metrics.dart';
import 'package:bugsnag_flutter_performance/src/span_options.dart';

void main() {
  group('EnabledMetrics', () {
    test('defaults to all disabled', () {
      const metrics = EnabledMetrics();
      expect(metrics.rendering, false);
      expect(metrics.cpu, false);
      expect(metrics.memory, false);
      expect(metrics.hasAnyEnabled, false);
    });

    test('can enable individual metrics', () {
      const metrics = EnabledMetrics(
        rendering: true,
        cpu: false,
        memory: true,
      );
      expect(metrics.rendering, true);
      expect(metrics.cpu, false);
      expect(metrics.memory, true);
      expect(metrics.hasAnyEnabled, true);
    });

    test('copyWith preserves unchanged values', () {
      const original =
          EnabledMetrics(rendering: true, cpu: false, memory: true);
      final copy = original.copyWith(cpu: true);

      expect(copy.rendering, true);
      expect(copy.cpu, true);
      expect(copy.memory, true);
    });

    test('equality works correctly', () {
      const m1 = EnabledMetrics(rendering: true, cpu: true);
      const m2 = EnabledMetrics(rendering: true, cpu: true);
      const m3 = EnabledMetrics(rendering: false, cpu: true);

      expect(m1, equals(m2));
      expect(m1, isNot(equals(m3)));
    });
  });

  group('SpanMetrics', () {
    test('defaults to all null', () {
      const metrics = SpanMetrics();
      expect(metrics.rendering, isNull);
      expect(metrics.cpu, isNull);
      expect(metrics.memory, isNull);
    });

    test('SpanMetrics.all() enables all metrics', () {
      const metrics = SpanMetrics.all();
      expect(metrics.rendering, true);
      expect(metrics.cpu, true);
      expect(metrics.memory, true);
    });

    test('SpanMetrics.none() disables all metrics', () {
      const metrics = SpanMetrics.none();
      expect(metrics.rendering, false);
      expect(metrics.cpu, false);
      expect(metrics.memory, false);
    });

    test('can override individual metrics', () {
      const metrics = SpanMetrics(
        rendering: true,
        cpu: null,
        memory: false,
      );
      expect(metrics.rendering, true);
      expect(metrics.cpu, isNull);
      expect(metrics.memory, false);
    });

    test('equality works correctly', () {
      const m1 = SpanMetrics(rendering: true, cpu: null, memory: false);
      const m2 = SpanMetrics(rendering: true, cpu: null, memory: false);
      const m3 = SpanMetrics(rendering: false, cpu: null, memory: false);

      expect(m1, equals(m2));
      expect(m1, isNot(equals(m3)));
    });
  });

  group('SpanOptions', () {
    test('defaults to no metrics', () {
      const options = SpanOptions();
      expect(options.metrics, isNull);
    });

    test('can be created with metrics', () {
      const metrics = SpanMetrics.all();
      const options = SpanOptions(metrics: metrics);
      expect(options.metrics, equals(metrics));
    });

    test('withMetrics defaults to all when called without args', () {
      const options = SpanOptions();
      final withMetrics = options.withMetrics();
      expect(withMetrics.metrics, equals(const SpanMetrics.all()));
    });

    test('withMetrics accepts custom metrics', () {
      const options = SpanOptions();
      const customMetrics = SpanMetrics(rendering: true, cpu: false);
      final withMetrics = options.withMetrics(customMetrics);
      expect(withMetrics.metrics, equals(customMetrics));
    });

    test('withMetrics can enable all metrics', () {
      const options = SpanOptions();
      final withAll = options.withMetrics(const SpanMetrics.all());
      expect(withAll.metrics?.rendering, true);
      expect(withAll.metrics?.cpu, true);
      expect(withAll.metrics?.memory, true);
    });
  });
}
