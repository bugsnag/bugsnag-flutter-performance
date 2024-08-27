Feature: Configuration overrides

  Scenario: Setting fixed sampling probability of 1 with dynamic probability of 0 should send all spans
    Given I set the sampling probability for the next traces to "0"
    And I enter unmanaged traces mode
    And I run "FixedSamplingProbabilityOneScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Integrity" header matches the regex "^sha1 [A-Fa-f0-9]{40}$"
    * the trace "Bugsnag-Span-Sampling" header is not present
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * every span field "name" equals "FixedSamplingProbabilitySpan1"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    Then I discard the oldest trace
    Then I set the sampling probability for the next traces to "0"
    And I invoke "step2"
    And I wait for 1 span
    * the trace "Bugsnag-Span-Sampling" header is not present
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * every span field "name" equals "FixedSamplingProbabilitySpan2"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"

  Scenario: Setting fixed sampling probability of 0 with dynamic probability of 1 should send no spans
    Given I set the sampling probability for the next traces to "0"
    And I enter unmanaged traces mode
    And I run "FixedSamplingProbabilityZeroScenario"
    And I should receive no traces