import 'package:bugsnag_flutter_performance/src/metrics/span_metrics.dart';

/// Options for configuring a span
class SpanOptions {
  /// Per-span metrics override
  final SpanMetrics? _metrics;

  const SpanOptions({SpanMetrics? metrics}) : _metrics = metrics;

  /// Gets the metrics configuration for this span
  SpanMetrics? get metrics => _metrics;

  /// Creates a copy of these options with metrics override.
  ///
  /// If [metrics] is omitted, defaults to disabling all metrics for this span.
  /// To enable all metrics, pass [SpanMetrics.all()].
  /// To enable specific metrics, pass a custom [SpanMetrics] instance.
  SpanOptions withMetrics([SpanMetrics metrics = const SpanMetrics.none()]) {
    return SpanOptions(metrics: metrics);
  }

  /// Creates a copy of these options that clears any metrics override,
  /// causing the span to use global metrics configuration.
  SpanOptions clearMetricsOverride() {
    return const SpanOptions(metrics: null);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanOptions &&
          runtimeType == other.runtimeType &&
          _metrics == other._metrics;

  @override
  int get hashCode => _metrics.hashCode;

  @override
  String toString() => 'SpanOptions(metrics: $_metrics)';
}
