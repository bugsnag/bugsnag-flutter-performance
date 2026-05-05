import 'package:flutter/foundation.dart';
import 'cpu_metrics_collector.dart';
import 'memory_metrics_collector.dart';
import 'rendering_metrics_collector.dart';
import 'enabled_metrics.dart';
import 'span_metrics.dart';

/// Manages all performance metrics collectors (CPU, memory, rendering)
class MetricsManager {
  final RenderingMetricsCollector _renderingCollector;
  final CpuMetricsCollector _cpuCollector;
  final MemoryMetricsCollector _memoryCollector;

  EnabledMetrics _globalMetrics;

  MetricsManager({
    EnabledMetrics globalMetrics = const EnabledMetrics(),
  })  : _globalMetrics = globalMetrics,
        _renderingCollector =
            RenderingMetricsCollector(ValueNotifier(globalMetrics.rendering)),
        _cpuCollector = CpuMetricsCollector(),
        _memoryCollector = MemoryMetricsCollector();

  /// Initializes all enabled metrics collectors
  Future<void> initialize() async {
    if (_globalMetrics.rendering) {
      _renderingCollector.attach();
    }

    if (_globalMetrics.cpu) {
      await _cpuCollector.initialize();
    }

    if (_globalMetrics.memory) {
      await _memoryCollector.initialize();
    }
  }

  /// Updates the global metrics configuration
  void updateGlobalMetrics(EnabledMetrics metrics) {
    final wasRenderingEnabled = _globalMetrics.rendering;
    final wasCpuEnabled = _globalMetrics.cpu;
    final wasMemoryEnabled = _globalMetrics.memory;
    _globalMetrics = metrics;

    // Update rendering collector state
    if (metrics.rendering && !wasRenderingEnabled) {
      _renderingCollector.enabled.value = true;
      _renderingCollector.attach();
    } else if (!metrics.rendering && wasRenderingEnabled) {
      _renderingCollector.detach();
    }

    // Initialize/teardown CPU metrics collector based on configuration changes
    if (metrics.cpu && !wasCpuEnabled) {
      // Fire-and-forget initialization; assumes idempotent behavior
      _cpuCollector.initialize();
    } else if (!metrics.cpu && wasCpuEnabled) {
      // Stop CPU metrics collection when CPU metrics are disabled
      _cpuCollector.dispose();
    }

    // Manage memory metrics collector based on memory metrics configuration
    if (metrics.memory && !wasMemoryEnabled) {
      // Fire-and-forget initialization; assumes idempotent behavior
      _memoryCollector.initialize();
    } else if (!metrics.memory && wasMemoryEnabled) {
      // Stop memory collection when memory metrics are disabled
      _memoryCollector.dispose();
    }
  }

  /// Determines which metrics should be collected for a span
  EnabledMetrics resolveMetrics(SpanMetrics? spanMetrics) {
    if (spanMetrics == null) {
      return _globalMetrics;
    }

    return EnabledMetrics(
      rendering: spanMetrics.rendering ?? _globalMetrics.rendering,
      cpu: spanMetrics.cpu ?? _globalMetrics.cpu,
      memory: spanMetrics.memory ?? _globalMetrics.memory,
    );
  }

  /// Collects metrics for a span's time window
  Future<Map<String, Object>> collectMetrics({
    required int startNanos,
    required int endNanos,
    SpanMetrics? spanMetrics,
  }) async {
    final effectiveMetrics = resolveMetrics(spanMetrics);
    final attributes = <String, Object>{};

    // Collect rendering metrics if enabled
    if (effectiveMetrics.rendering) {
      try {
        final renderingAttrs =
            await _renderingCollector.summarize(startNanos, endNanos);
        attributes.addAll(renderingAttrs);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to collect rendering metrics: $e');
        }
      }
    }

    // Collect CPU metrics if enabled
    if (effectiveMetrics.cpu) {
      try {
        final cpuAttrs = await _cpuCollector.summarize(startNanos, endNanos);
        if (cpuAttrs != null) {
          attributes.addAll(cpuAttrs);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to collect CPU metrics: $e');
        }
      }
    }

    // Collect memory metrics if enabled
    if (effectiveMetrics.memory) {
      try {
        final memoryAttrs =
            await _memoryCollector.summarize(startNanos, endNanos);
        if (memoryAttrs != null) {
          attributes.addAll(memoryAttrs);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to collect memory metrics: $e');
        }
      }
    }

    return attributes;
  }

  /// Clears all collected metrics
  void clear() {
    _renderingCollector.clear();
  }
}
