import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:bugsnag_flutter_performance/src/metrics/ring_buffer.dart';

/// Collects rendering performance metrics (frames, FPS) from Flutter
class RenderingMetricsCollector {
  static const _methodChannel = MethodChannel('bugsnag_performance_metrics');

  /// Capacity for ~20 minutes at 60fps = 72000 frames
  /// We're using 20000 to keep memory reasonable
  static const int _bufferCapacity = 20000;

  final ValueNotifier<bool> enabled;
  final RingBuffer<_FrameMeasurement> _buffer =
      RingBuffer(capacity: _bufferCapacity);

  /// Tracks whether we've already registered the timings callback.
  bool _hasRegisteredCallback = false;
  double? _cachedFpsTarget;

  RenderingMetricsCollector(this.enabled);

  /// Attaches the rendering metrics collector to start capturing frame timings
  void attach() {
    // The timings callback cannot be removed once registered, so ensure we only
    // register it once and use [enabled] solely to gate processing.
    if (_hasRegisteredCallback) return;

    _hasRegisteredCallback = true;

    SchedulerBinding.instance.addTimingsCallback((timings) {
      if (!enabled.value) return;

      final nowNanos = DateTime.now().microsecondsSinceEpoch * 1000;
      for (final timing in timings) {
        final totalMs = timing.totalSpan.inMicroseconds / 1000.0;
        _buffer.push(_FrameMeasurement(totalMs, nowNanos));
      }
    });
  }

  /// Detaches the collector (note: callbacks can't be removed, but we check enabled flag)
  void detach() {
    // Leave the timings callback registered; just disable processing.
    enabled.value = false;
  }

  /// Gets the target FPS for the device
  Future<double> _getFpsTarget() async {
    if (_cachedFpsTarget != null) {
      return _cachedFpsTarget!;
    }

    // Try to get from Flutter View (3.16+)
    try {
      final view = PlatformDispatcher.instance.implicitView;
      if (view != null && view.display.refreshRate > 0) {
        _cachedFpsTarget = view.display.refreshRate;
        return _cachedFpsTarget!;
      }
    } catch (e) {
      // Fall through to platform-specific code
    }

    // Try platform-specific method
    try {
      final rate = await _getPlatformRefreshRate();
      if (rate != null && rate > 0) {
        _cachedFpsTarget = rate;
        return _cachedFpsTarget!;
      }
    } catch (e) {
      // Fall through to default
    }

    // Default to 60 Hz
    _cachedFpsTarget = 60.0;
    return _cachedFpsTarget!;
  }

  /// Gets the refresh rate from the native platform
  Future<double?> _getPlatformRefreshRate() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return null;
    }

    try {
      final result =
          await _methodChannel.invokeMethod<double>('getRefreshRate');
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Summarizes rendering metrics for the given time window
  Future<Map<String, Object>> summarize(int fromNanos, int toNanos) async {
    final fpsTarget = await _getFpsTarget();
    final frameBudgetMs = 1000.0 / fpsTarget;

    // Collect frames in the time window
    final frames = <_FrameMeasurement>[];
    for (final frame in _buffer.items) {
      if (frame.timestampNanos >= fromNanos &&
          frame.timestampNanos <= toNanos) {
        frames.add(frame);
      }
    }

    final totalFrames = frames.length;

    if (totalFrames == 0) {
      return {
        'bugsnag.rendering.frozen_frames': 0,
        'bugsnag.rendering.slow_frames': 0,
        'bugsnag.rendering.total_frames': 0,
        'bugsnag.rendering.fps_maximum': fpsTarget,
        'bugsnag.rendering.fps_minimum': 0.0,
        'bugsnag.rendering.fps_average': 0.0,
        'bugsnag.rendering.fps_target': fpsTarget,
      };
    }

    var frozenCount = 0;
    var slowCount = 0;
    var minFps = double.infinity;
    var maxFps = 0.0;
    var sumFps = 0.0;

    for (final frame in frames) {
      // Calculate observed FPS for this frame
      final fps = frame.totalMs <= 0
          ? fpsTarget
          : (1000.0 / frame.totalMs).clamp(0.0, fpsTarget);

      // Check for slow/frozen frames
      if (frame.totalMs > frameBudgetMs) {
        slowCount++;
      }
      if (frame.totalMs >= 700.0) {
        frozenCount++;
      }

      // Track FPS stats
      if (fps < minFps) minFps = fps;
      if (fps > maxFps) maxFps = fps;
      sumFps += fps;
    }

    return {
      'bugsnag.rendering.frozen_frames': frozenCount,
      'bugsnag.rendering.slow_frames': slowCount,
      'bugsnag.rendering.total_frames': totalFrames,
      'bugsnag.rendering.fps_maximum': maxFps,
      'bugsnag.rendering.fps_minimum': minFps.isFinite ? minFps : 0.0,
      'bugsnag.rendering.fps_average': sumFps / totalFrames,
      'bugsnag.rendering.fps_target': fpsTarget,
    };
  }

  /// Clears all collected measurements
  void clear() {
    _buffer.clear();
  }
}

/// Frame measurement data structure (internal use)
class _FrameMeasurement {
  final double totalMs;
  final int timestampNanos;

  _FrameMeasurement(this.totalMs, this.timestampNanos);
}
