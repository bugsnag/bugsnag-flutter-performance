import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'scenario.dart';

/// Scenario that enables all metrics (rendering, CPU, memory)
/// and creates a span that runs long enough to generate multiple samples.
class MetricsScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
      enabledMetrics: const EnabledMetrics(
        rendering: true,
        cpu: true,
        memory: true,
      ),
    );
    setMaxBatchSize(1);

    // Create a span that runs for 4 seconds to generate enough samples
    // CPU/Memory sample every ~1 second, so 4 seconds should give us 4 samples
    final span = bugsnag_performance.startSpan('MetricsScenarioSpan');
    
    // Simulate some work to generate frame timing data
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Wait to ensure we get multiple samples
    await Future.delayed(const Duration(seconds: 4));
    
    span.end();
  }
}

/// Scenario with metrics disabled to verify attributes are not present
class MetricsDisabledScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
      enabledMetrics: const EnabledMetrics(
        rendering: false,
        cpu: false,
        memory: false,
      ),
    );
    setMaxBatchSize(1);

    final span = bugsnag_performance.startSpan('MetricsDisabledSpan');
    await Future.delayed(const Duration(seconds: 2));
    span.end();
  }
}

/// Scenario with only rendering metrics enabled
class RenderingMetricsOnlyScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag(
      enabledMetrics: const EnabledMetrics(
        rendering: true,
        cpu: false,
        memory: false,
      ),
    );
    setMaxBatchSize(1);

    final span = bugsnag_performance.startSpan('RenderingOnlySpan');
    await Future.delayed(const Duration(seconds: 2));
    span.end();
  }
}

/// Scenario with per-span metrics override
class PerSpanMetricsOverrideScenario extends Scenario {
  @override
  Future<void> run() async {
    // Enable all metrics globally
    await startBugsnag(
      enabledMetrics: const EnabledMetrics(
        rendering: true,
        cpu: true,
        memory: true,
      ),
    );
    setMaxBatchSize(1);

    // Create span with per-span override that disables CPU metrics
    final span = bugsnag_performance.startSpan(
      'PerSpanOverrideSpan',
      options: const SpanOptions(
        metrics: SpanMetrics(cpu: false),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 4));
    span.end();
  }
}
