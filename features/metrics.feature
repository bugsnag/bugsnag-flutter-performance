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
    * a span integer attribute "bugsnag.rendering.frame_count" is greater than 0
    * a span integer attribute "bugsnag.rendering.frozen_frame_count" is greater than -1
    * a span integer attribute "bugsnag.rendering.slow_frame_count" is greater than -1
    * a span double attribute "bugsnag.rendering.frozen_frame_percentage" is greater than -1
    * a span double attribute "bugsnag.rendering.slow_frame_percentage" is greater than -1
    # Verify CPU metrics (arrays with at least 1 sample)
    * a span array attribute "bugsnag.cpu.time" contains at least 1 items
    * a span array attribute "bugsnag.cpu.time" is greater than 0 at index 0
    * a span array attribute "bugsnag.cpu.usage_percent" contains at least 1 items
    * a span array attribute "bugsnag.cpu.usage_percent" is greater than -1 at index 0
    * a span array attribute "bugsnag.cpu.user_percent" contains at least 1 items
    * a span array attribute "bugsnag.cpu.user_percent" is greater than -1 at index 0
    * a span array attribute "bugsnag.cpu.system_percent" contains at least 1 items
    * a span array attribute "bugsnag.cpu.system_percent" is greater than -1 at index 0
    # Verify memory metrics (arrays with at least 1 sample)
    * a span array attribute "bugsnag.memory.time" contains at least 1 items
    * a span array attribute "bugsnag.memory.time" is greater than 0 at index 0
    * a span array attribute "bugsnag.memory.pss_kb" contains at least 1 items
    * a span array attribute "bugsnag.memory.pss_kb" is greater than 0 at index 0
    * a span array attribute "bugsnag.memory.rss_kb" contains at least 1 items
    * a span array attribute "bugsnag.memory.rss_kb" is greater than 0 at index 0

  @skip_android
  Scenario: iOS-specific memory metrics
    When I run "MetricsScenario"
    And I wait to receive a span named "MetricsScenarioSpan"
    # Verify iOS-specific memory metrics
    * a span array attribute "bugsnag.memory.footprint_kb" contains at least 1 items
    * a span array attribute "bugsnag.memory.footprint_kb" is greater than 0 at index 0

  @skip_ios
  Scenario: Android-specific memory metrics
    When I run "MetricsScenario"
    And I wait to receive a span named "MetricsScenarioSpan"
    # Verify Android-specific memory metrics
    * a span array attribute "bugsnag.memory.dalvik_kb" contains at least 1 items
    * a span array attribute "bugsnag.memory.dalvik_kb" is greater than 0 at index 0
    * a span array attribute "bugsnag.memory.native_kb" contains at least 1 items
    * a span array attribute "bugsnag.memory.native_kb" is greater than 0 at index 0
    * a span array attribute "bugsnag.memory.other_kb" contains at least 1 items
    * a span array attribute "bugsnag.memory.other_kb" is greater than -1 at index 0

  Scenario: All metrics disabled
    When I run "MetricsDisabledScenario"
    And I wait to receive a span named "MetricsDisabledSpan"
    Then the trace "Content-Type" header equals "application/json"
    # Verify NO metrics attributes are present
    * every span string attribute "bugsnag.rendering.fps_target" does not exist
    * every span string attribute "bugsnag.rendering.fps_average" does not exist
    * every span string attribute "bugsnag.rendering.frame_count" does not exist
    * every span string attribute "bugsnag.cpu.time" does not exist
    * every span string attribute "bugsnag.cpu.usage_percent" does not exist
    * every span string attribute "bugsnag.memory.time" does not exist
    * every span string attribute "bugsnag.memory.pss_kb" does not exist

  Scenario: Only rendering metrics enabled
    When I run "RenderingMetricsOnlyScenario"
    And I wait to receive a span named "RenderingOnlySpan"
    Then the trace "Content-Type" header equals "application/json"
    # Verify rendering metrics ARE present
    * a span double attribute "bugsnag.rendering.fps_target" is greater than 0
    * a span double attribute "bugsnag.rendering.fps_average" is greater than 0
    * a span integer attribute "bugsnag.rendering.frame_count" is greater than 0
    # Verify CPU and memory metrics are NOT present
    * every span string attribute "bugsnag.cpu.time" does not exist
    * every span string attribute "bugsnag.cpu.usage_percent" does not exist
    * every span string attribute "bugsnag.memory.time" does not exist
    * every span string attribute "bugsnag.memory.pss_kb" does not exist

  Scenario: Per-span metrics override
    When I run "PerSpanMetricsOverrideScenario"
    And I wait to receive a span named "PerSpanOverrideSpan"
    Then the trace "Content-Type" header equals "application/json"
    # Verify rendering metrics ARE present (enabled globally, not overridden)
    * a span double attribute "bugsnag.rendering.fps_target" is greater than 0
    * a span double attribute "bugsnag.rendering.fps_average" is greater than 0
    # Verify memory metrics ARE present (enabled globally, not overridden)
    * a span array attribute "bugsnag.memory.time" contains at least 1 items
    * a span array attribute "bugsnag.memory.pss_kb" contains at least 1 items
    # Verify CPU metrics are NOT present (disabled by per-span override)
    * every span string attribute "bugsnag.cpu.time" does not exist
    * every span string attribute "bugsnag.cpu.usage_percent" does not exist
    * every span string attribute "bugsnag.cpu.user_percent" does not exist
