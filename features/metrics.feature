Feature: Performance Metrics

  Background:
    Given I clear the Bugsnag cache

  Scenario: All metrics enabled
    When I run "MetricsScenario"
    And I wait to receive a span named "MetricsScenarioSpan"
    Then the trace "Content-Type" header equals "application/json"
    # Verify rendering metrics
    * a span double attribute "bugsnag.rendering.fps_target" is greater than 0
    * a span double attribute "bugsnag.rendering.fps_average" is greater than 0
    * a span integer attribute "bugsnag.rendering.total_frames" is greater than 0
    * a span integer attribute "bugsnag.rendering.frozen_frames" is greater than -1
    * a span integer attribute "bugsnag.rendering.slow_frames" is greater than -1
    * a span double attribute "bugsnag.rendering.fps_minimum" is greater than 0
    * a span double attribute "bugsnag.rendering.fps_maximum" is greater than 0

    # Verify CPU metrics (arrays with at least 2 samples)
    * a span array attribute "bugsnag.system.cpu_measures_timestamps" contains at least 2 items
    * a span array attribute "bugsnag.system.cpu_measures_total" contains at least 2 items
    * a span array attribute "bugsnag.system.cpu_measures_total" is greater than -1.0 at index 0
    * a span array attribute "bugsnag.system.cpu_measures_main_thread" contains at least 2 items
    * a span array attribute "bugsnag.system.cpu_measures_main_thread" is greater than -1.0 at index 0
    * a span double attribute "bugsnag.system.cpu_mean_total" is greater than 0.0
    * a span double attribute "bugsnag.system.cpu_mean_main_thread" is greater than 0.0
    * a span array attribute "bugsnag.system.cpu_measures_overhead" contains at least 2 items
    # Verify memory metrics (arrays with at least 1 sample)
    * a span array attribute "bugsnag.system.memory.timestamps" contains at least 1 items
    * a span array attribute "bugsnag.system.memory.spaces.device.used" contains at least 1 items
    * a span integer attribute "bugsnag.system.memory.spaces.device.mean" is greater than 0
    * a span integer attribute "bugsnag.device.physical_device_memory" is greater than 0
    * a span integer attribute "bugsnag.system.memory.spaces.device.size" is greater than 0

  @skip_ios
  Scenario: Android-specific ART memory metrics
    When I run "MetricsScenario"
    And I wait to receive a span named "MetricsScenarioSpan"
    # Verify Android-specific ART memory metrics
    * a span array attribute "bugsnag.system.memory.spaces.art.used" contains at least 1 items
    * a span integer attribute "bugsnag.system.memory.spaces.art.mean" is greater than 0
    * a span integer attribute "bugsnag.system.memory.spaces.art.size" is greater than 0

  Scenario: All metrics disabled
    When I run "MetricsDisabledScenario"
    And I wait to receive a span named "MetricsDisabledSpan"
    Then the trace "Content-Type" header equals "application/json"
    # Verify NO metrics attributes are present
    * every span string attribute "bugsnag.rendering.fps_target" does not exist
    * every span string attribute "bugsnag.rendering.fps_average" does not exist
    * every span string attribute "bugsnag.rendering.total_frames" does not exist
    * every span string attribute "bugsnag.system.cpu_measures_timestamps" does not exist
    * every span string attribute "bugsnag.system.cpu_measures_total" does not exist
    * every span string attribute "bugsnag.system.memory.timestamps" does not exist
    * every span string attribute "bugsnag.system.memory.spaces.device.used" does not exist

  Scenario: Metrics disabled by default (no enabledMetrics config)
    When I run "MetricsDefaultDisabledScenario"
    And I wait to receive a span named "MetricsDefaultDisabledSpan"
    Then the trace "Content-Type" header equals "application/json"
    # Verify NO metrics attributes are present when no enabledMetrics is configured
    * every span string attribute "bugsnag.rendering.fps_target" does not exist
    * every span string attribute "bugsnag.rendering.fps_average" does not exist
    * every span string attribute "bugsnag.rendering.total_frames" does not exist
    * every span string attribute "bugsnag.system.cpu_measures_timestamps" does not exist
    * every span string attribute "bugsnag.system.cpu_measures_total" does not exist
    * every span string attribute "bugsnag.system.memory.timestamps" does not exist
    * every span string attribute "bugsnag.system.memory.spaces.device.used" does not exist

  Scenario: Only rendering metrics enabled
    When I run "RenderingMetricsOnlyScenario"
    And I wait to receive a span named "RenderingOnlySpan"
    Then the trace "Content-Type" header equals "application/json"
    # Verify rendering metrics ARE present
    * a span double attribute "bugsnag.rendering.fps_target" is greater than 0
    * a span double attribute "bugsnag.rendering.fps_average" is greater than 0
    * a span integer attribute "bugsnag.rendering.total_frames" is greater than 0
    # Verify CPU and memory metrics are NOT present
    * every span string attribute "bugsnag.system.cpu_measures_timestamps" does not exist
    * every span string attribute "bugsnag.system.cpu_measures_total" does not exist
    * every span string attribute "bugsnag.system.memory.timestamps" does not exist
    * every span string attribute "bugsnag.system.memory.spaces.device.used" does not exist

  Scenario: Per-span metrics override
    When I run "PerSpanMetricsOverrideScenario"
    And I wait to receive a span named "PerSpanOverrideSpan"
    Then the trace "Content-Type" header equals "application/json"
    # Verify rendering metrics ARE present (enabled globally, not overridden)
    * a span double attribute "bugsnag.rendering.fps_target" is greater than 0
    * a span double attribute "bugsnag.rendering.fps_average" is greater than 0
    # Verify memory metrics ARE present (enabled globally, not overridden)
    * a span array attribute "bugsnag.system.memory.timestamps" contains at least 1 items
    * a span array attribute "bugsnag.system.memory.spaces.device.used" contains at least 1 items
    # Verify CPU metrics are NOT present (disabled by per-span override)
    * every span string attribute "bugsnag.system.cpu_measures_timestamps" does not exist
    * every span string attribute "bugsnag.system.cpu_measures_total" does not exist
    * every span string attribute "bugsnag.system.cpu_measures_main_thread" does not exist

  Scenario: Per-span memory disabled
    When I run "PerSpanMemoryDisabledScenario"
    And I wait to receive a span named "PerSpanMemoryDisabledSpan"
    Then the trace "Content-Type" header equals "application/json"
    # rendering present
    * a span double attribute "bugsnag.rendering.fps_target" is greater than 0
    * a span double attribute "bugsnag.rendering.fps_average" is greater than 0
    # cpu present
    * a span array attribute "bugsnag.system.cpu_measures_timestamps" contains at least 2 items
    * a span double attribute "bugsnag.system.cpu_mean_total" is greater than 0.0
    # memory absent
    * every span string attribute "bugsnag.system.memory.timestamps" does not exist
    * every span string attribute "bugsnag.system.memory.spaces.device.used" does not exist

  Scenario: Per-span rendering disabled
    When I run "PerSpanRenderingDisabledScenario"
    And I wait to receive a span named "PerSpanRenderingDisabledSpan"
    # rendering absent
    * every span string attribute "bugsnag.rendering.fps_target" does not exist
    * every span string attribute "bugsnag.rendering.total_frames" does not exist
    # cpu present
    * a span array attribute "bugsnag.system.cpu_measures_total" contains at least 2 items
    * a span double attribute "bugsnag.system.cpu_mean_main_thread" is greater than 0.0
    # memory present
    * a span array attribute "bugsnag.system.memory.timestamps" contains at least 1 items
    * a span integer attribute "bugsnag.system.memory.spaces.device.mean" is greater than 0

  Scenario: Per-span all metrics disabled (SpanMetrics.none)
    When I run "PerSpanAllDisabledScenario"
    And I wait to receive a span named "PerSpanAllDisabledSpan"
    # nothing present
    * every span string attribute "bugsnag.rendering.fps_target" does not exist
    * every span string attribute "bugsnag.system.cpu_measures_total" does not exist
    * every span string attribute "bugsnag.system.memory.timestamps" does not exist

  Scenario: Per-span all metrics enabled (SpanMetrics.all) despite global disabled
    When I run "PerSpanAllEnabledScenario"
    And I wait to receive a span named "PerSpanAllEnabledSpan"
    # rendering present
    * a span double attribute "bugsnag.rendering.fps_target" is greater than 0
    * a span double attribute "bugsnag.rendering.fps_minimum" is greater than 0
    * a span double attribute "bugsnag.rendering.fps_maximum" is greater than 0
    # cpu present
    * a span array attribute "bugsnag.system.cpu_measures_total" contains at least 2 items
    * a span array attribute "bugsnag.system.cpu_measures_overhead" contains at least 2 items
    # memory present
    * a span array attribute "bugsnag.system.memory.spaces.device.used" contains at least 1 items
    * a span integer attribute "bugsnag.system.memory.spaces.device.mean" is greater than 0

  Scenario: Only CPU metrics enabled globally
    When I run "CpuMetricsOnlyScenario"
    And I wait to receive a span named "CpuOnlySpan"
    # cpu present
    * a span array attribute "bugsnag.system.cpu_measures_timestamps" contains at least 2 items
    * a span double attribute "bugsnag.system.cpu_mean_total" is greater than 0.0
    * a span double attribute "bugsnag.system.cpu_mean_main_thread" is greater than 0.0
    * a span array attribute "bugsnag.system.cpu_measures_overhead" contains at least 2 items
    # rendering + memory absent
    * every span string attribute "bugsnag.rendering.fps_target" does not exist
    * every span string attribute "bugsnag.system.memory.timestamps" does not exist

  Scenario: Only memory metrics enabled globally
    When I run "MemoryMetricsOnlyScenario"
    And I wait to receive a span named "MemoryOnlySpan"
    # memory present
    * a span array attribute "bugsnag.system.memory.timestamps" contains at least 1 items
    * a span array attribute "bugsnag.system.memory.spaces.device.used" contains at least 1 items
    * a span integer attribute "bugsnag.system.memory.spaces.device.mean" is greater than 0
    * a span integer attribute "bugsnag.device.physical_device_memory" is greater than 0
    * a span integer attribute "bugsnag.system.memory.spaces.device.size" is greater than 0
    # cpu + rendering absent
    * every span string attribute "bugsnag.system.cpu_measures_total" does not exist
    * every span string attribute "bugsnag.rendering.fps_target" does not exist