/// Configuration for which performance metrics are enabled globally
class EnabledMetrics {
  /// Whether rendering metrics (frames, FPS) should be collected
  final bool rendering;
  
  /// Whether CPU usage metrics should be collected
  final bool cpu;
  
  /// Whether memory usage metrics should be collected
  final bool memory;

  const EnabledMetrics({
    this.rendering = false,
    this.cpu = false,
    this.memory = false,
  });

  /// Creates a copy of this configuration with the given fields replaced
  EnabledMetrics copyWith({
    bool? rendering,
    bool? cpu,
    bool? memory,
  }) {
    return EnabledMetrics(
      rendering: rendering ?? this.rendering,
      cpu: cpu ?? this.cpu,
      memory: memory ?? this.memory,
    );
  }

  /// Returns true if any metrics are enabled
  bool get hasAnyEnabled => rendering || cpu || memory;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnabledMetrics &&
          runtimeType == other.runtimeType &&
          rendering == other.rendering &&
          cpu == other.cpu &&
          memory == other.memory;

  @override
  int get hashCode => rendering.hashCode ^ cpu.hashCode ^ memory.hashCode;

  @override
  String toString() => 'EnabledMetrics(rendering: $rendering, cpu: $cpu, memory: $memory)';
}
