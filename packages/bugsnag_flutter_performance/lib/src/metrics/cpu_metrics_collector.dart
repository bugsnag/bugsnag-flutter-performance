import 'dart:io';
import 'package:flutter/services.dart';

/// Data structure for CPU samples
class CpuSample {
  final double totalCpu;
  final double mainThreadCpu;
  final double overheadCpu;
  final int timestampNanos;

  CpuSample({
    required this.totalCpu,
    required this.mainThreadCpu,
    required this.overheadCpu,
    required this.timestampNanos,
  });

  factory CpuSample.fromMap(Map<dynamic, dynamic> map) {
    return CpuSample(
      totalCpu: (map['total'] as num).toDouble(),
      mainThreadCpu: (map['mainThread'] as num).toDouble(),
      overheadCpu: (map['overhead'] as num).toDouble(),
      timestampNanos: int.parse(map['timestamp'].toString()),
    );
  }
}

/// Collects CPU usage metrics via native platform code
class CpuMetricsCollector {
  static const _methodChannel = MethodChannel('bugsnag_performance_metrics');

  bool _initialized = false;

  /// Initializes the CPU metrics collector
  Future<void> initialize() async {
    if (_initialized || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      await _methodChannel.invokeMethod('initCpuSampler', {
        'period': 1000, // 1 second sampling period
      });
      _initialized = true;
    } catch (e) {
      // Initialization failed, metrics won't be available
    }
  }

  /// Disposes the CPU metrics collector and stops sampling
  Future<void> dispose() async {
    if (!_initialized) return;

    try {
      await _methodChannel.invokeMethod('stopCpuSampler');
      _initialized = false;
    } catch (e) {
      // Disposal failed, but mark as not initialized anyway
      _initialized = false;
    }
  }

  /// Gets CPU samples for the given time window
  /// Returns null if not available or not initialized
  Future<List<CpuSample>?> getSamples(int fromNanos, int toNanos) async {
    if (!_initialized) return null;

    try {
      final result = await _methodChannel.invokeMethod<Map>('getCpuSlice', {
        'fromNanos': fromNanos.toString(),
        'toNanos': toNanos.toString(),
      });

      if (result == null) return null;

      final samples = <CpuSample>[];
      final samplesList = result['samples'] as List?;

      if (samplesList != null) {
        for (final sampleData in samplesList) {
          samples.add(CpuSample.fromMap(sampleData as Map));
        }
      }

      return samples;
    } catch (e) {
      return null;
    }
  }

  /// Summarizes CPU metrics for a time window and returns span attributes
  Future<Map<String, Object>?> summarize(int fromNanos, int toNanos) async {
    final samples = await getSamples(fromNanos, toNanos);
    if (samples == null || samples.length < 2) return null;

    // Cap at 600 samples as per spec
    final cappedSamples =
        samples.length > 600 ? samples.sublist(samples.length - 600) : samples;

    final totalMeasures = <double>[];
    final mainThreadMeasures = <double>[];
    final overheadMeasures = <double>[];
    final timestamps = <int>[];

    var totalSum = 0.0;
    var mainThreadSum = 0.0;
    var overheadSum = 0.0;

    for (final sample in cappedSamples) {
      totalMeasures.add(sample.totalCpu);
      mainThreadMeasures.add(sample.mainThreadCpu);
      overheadMeasures.add(sample.overheadCpu);
      timestamps.add(sample.timestampNanos);

      totalSum += sample.totalCpu;
      mainThreadSum += sample.mainThreadCpu;
      overheadSum += sample.overheadCpu;
    }

    final count = cappedSamples.length;

    return {
      'bugsnag.system.cpu_measures_total': totalMeasures,
      'bugsnag.system.cpu_measures_main_thread': mainThreadMeasures,
      'bugsnag.system.cpu_measures_overhead': overheadMeasures,
      'bugsnag.system.cpu_measures_timestamps': timestamps,
      'bugsnag.system.cpu_mean_total': totalSum / count,
      'bugsnag.system.cpu_mean_main_thread': mainThreadSum / count,
      'bugsnag.system.cpu_mean_overhead': overheadSum / count,
    };
  }
}
