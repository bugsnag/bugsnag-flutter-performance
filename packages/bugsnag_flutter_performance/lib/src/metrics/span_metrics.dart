/// Per-span override for which performance metrics should be collected
class SpanMetrics {
  /// Whether rendering metrics (frames, FPS) should be collected for this span
  /// If null, uses the global configuration
  final bool? rendering;

  /// Whether CPU usage metrics should be collected for this span
  /// If null, uses the global configuration
  final bool? cpu;

  /// Whether memory usage metrics should be collected for this span
  /// If null, uses the global configuration
  final bool? memory;

  const SpanMetrics({
    this.rendering,
    this.cpu,
    this.memory,
  });

  /// Creates a SpanMetrics with all metrics enabled
  const SpanMetrics.all()
      : rendering = true,
        cpu = true,
        memory = true;

  /// Creates a SpanMetrics with all metrics disabled
  const SpanMetrics.none()
      : rendering = false,
        cpu = false,
        memory = false;

  /// Creates a copy of this configuration with the given fields replaced
  SpanMetrics copyWith({
    bool? rendering,
    bool? cpu,
    bool? memory,
  }) {
    return SpanMetrics(
      rendering: rendering ?? this.rendering,
      cpu: cpu ?? this.cpu,
      memory: memory ?? this.memory,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanMetrics &&
          runtimeType == other.runtimeType &&
          rendering == other.rendering &&
          cpu == other.cpu &&
          memory == other.memory;

  @override
  int get hashCode => rendering.hashCode ^ cpu.hashCode ^ memory.hashCode;

  @override
  String toString() =>
      'SpanMetrics(rendering: $rendering, cpu: $cpu, memory: $memory)';
}
