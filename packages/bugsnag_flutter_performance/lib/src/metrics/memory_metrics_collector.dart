import 'dart:io';
import 'package:flutter/services.dart';

/// Data structure for memory samples
class MemorySample {
  final int deviceUsed;
  final int? artSize;
  final int? artUsed;
  final int timestampNanos;

  MemorySample({
    required this.deviceUsed,
    this.artSize,
    this.artUsed,
    required this.timestampNanos,
  });

  factory MemorySample.fromMap(Map<dynamic, dynamic> map) {
    return MemorySample(
      deviceUsed: int.parse(map['deviceUsed'].toString()),
      artSize:
          map['artSize'] != null ? int.parse(map['artSize'].toString()) : null,
      artUsed:
          map['artUsed'] != null ? int.parse(map['artUsed'].toString()) : null,
      timestampNanos: int.parse(map['timestamp'].toString()),
    );
  }
}

/// Collects memory usage metrics via native platform code
class MemoryMetricsCollector {
  static const _methodChannel = MethodChannel('bugsnag_performance_metrics');

  bool _initialized = false;
  int? _physicalDeviceMemory;

  /// Initializes the memory metrics collector
  Future<void> initialize() async {
    if (_initialized || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      final result =
          await _methodChannel.invokeMethod<Map>('initMemorySampler', {
        'period': 1000, // 1 second sampling period
      });

      if (result != null && result['physicalMemory'] != null) {
        _physicalDeviceMemory = int.parse(result['physicalMemory'].toString());
      }

      _initialized = true;
    } catch (e) {
      // Initialization failed, metrics won't be available
    }
  }

  /// Disposes the memory metrics collector and stops sampling
  Future<void> dispose() async {
    if (!_initialized) return;

    try {
      await _methodChannel.invokeMethod('stopMemorySampler');
      _initialized = false;
    } catch (e) {
      // Disposal failed, but mark as not initialized anyway
      _initialized = false;
    }
  }

  /// Gets memory samples for the given time window
  /// Returns null if not available or not initialized
  Future<List<MemorySample>?> getSamples(int fromNanos, int toNanos) async {
    if (!_initialized) return null;

    try {
      final result = await _methodChannel.invokeMethod<Map>('getMemorySlice', {
        'fromNanos': fromNanos.toString(),
        'toNanos': toNanos.toString(),
      });

      if (result == null) return null;

      final samples = <MemorySample>[];
      final samplesList = result['samples'] as List?;

      if (samplesList != null) {
        for (final sampleData in samplesList) {
          samples.add(MemorySample.fromMap(sampleData as Map));
        }
      }

      return samples;
    } catch (e) {
      return null;
    }
  }

  /// Summarizes memory metrics for a time window and returns span attributes
  Future<Map<String, Object>?> summarize(int fromNanos, int toNanos) async {
    final samples = await getSamples(fromNanos, toNanos);
    if (samples == null || samples.isEmpty) return null;

    final deviceUsed = <int>[];
    final timestamps = <int>[];
    var deviceSum = 0;

    // Android-specific ART metrics
    final artUsed = <int>[];
    int? maxArtSize;
    var artSum = 0;
    var artCount = 0;

    for (final sample in samples) {
      deviceUsed.add(sample.deviceUsed);
      timestamps.add(sample.timestampNanos);
      deviceSum += sample.deviceUsed;

      // Collect ART metrics (Android only)
      if (sample.artUsed != null) {
        artUsed.add(sample.artUsed!);
        artSum += sample.artUsed!;
        artCount++;
      }

      if (sample.artSize != null) {
        if (maxArtSize == null || sample.artSize! > maxArtSize) {
          maxArtSize = sample.artSize;
        }
      }
    }

    final result = <String, Object>{
      'bugsnag.system.memory.spaces.device.used': deviceUsed,
      'bugsnag.system.memory.spaces.device.mean': deviceSum ~/ samples.length,
      'bugsnag.system.memory.timestamps': timestamps,
    };

    // Add physical memory if available
    if (_physicalDeviceMemory != null) {
      result['bugsnag.device.physical_device_memory'] = _physicalDeviceMemory!;
      result['bugsnag.system.memory.spaces.device.size'] =
          _physicalDeviceMemory!;
    }

    // Add ART metrics for Android
    if (artUsed.isNotEmpty) {
      result['bugsnag.system.memory.spaces.art.used'] = artUsed;
      result['bugsnag.system.memory.spaces.art.mean'] = artSum ~/ artCount;
    }

    if (maxArtSize != null) {
      result['bugsnag.system.memory.spaces.art.size'] = maxArtSize;
    }

    return result;
  }
}
