Feature: Configuration overrides

  Background:
    Given I clear the Bugsnag cache

  Scenario: Setting fixed sampling probability of 1 with dynamic probability of 0 should send all spans
    Given I set the sampling probability for the next traces to "0"
    And I enter unmanaged traces mode
    And I run "FixedSamplingProbabilityOneScenario"
    And I wait to receive a span named "FixedSamplingProbabilitySpan1"
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header is not present
    Then I discard the oldest trace
    Then I set the sampling probability for the next traces to "0"
    And I invoke "step2"
    And I wait to receive a span named "FixedSamplingProbabilitySpan2"
    * the trace "Bugsnag-Span-Sampling" header is not present

  Scenario: Setting fixed sampling probability of 0 with dynamic probability of 1 should send no spans
    Given I set the sampling probability for the next traces to "0"
    And I enter unmanaged traces mode
    And I run "FixedSamplingProbabilityZeroScenario"
    And I should receive no traces
