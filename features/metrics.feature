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
    # Verify CPU metrics (arrays with at least 2 samples)
    * a span array attribute "bugsnag.system.cpu_measures_timestamps" contains at least 2 items
    * a span array attribute "bugsnag.system.cpu_measures_total" contains at least 2 items
    * a span array attribute "bugsnag.system.cpu_measures_total" is greater than -1.0 at index 0
    * a span array attribute "bugsnag.system.cpu_measures_main_thread" contains at least 2 items
    * a span array attribute "bugsnag.system.cpu_measures_main_thread" is greater than -1.0 at index 0
    # Verify memory metrics (arrays with at least 1 sample)
    * a span array attribute "bugsnag.system.memory.timestamps" contains at least 1 items
    * a span array attribute "bugsnag.system.memory.spaces.device.used" contains at least 1 items

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
