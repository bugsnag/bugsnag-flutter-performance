Feature: Manual Spans

  Scenario: Manual Span
    When I run "ManualSpanScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span field "name" equals "ManualSpanScenario"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" is true
    * every span string attribute "bugsnag.span.category" equals "custom"
    * a span double attribute "bugsnag.sampling.p" equals 1.0

  Scenario: Manual Span isFirstClass false
    When I run "ManualSpanIsFirstClassFalseScenario"
    And I wait for 1 span
    Then every span field "name" equals "ManualSpanIsFirstClassFalseScenario"
    * every span bool attribute "bugsnag.span.first_class" is false


  Scenario: Max Batch Age
    When I run "MaxBatchAgeScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span field "name" equals "MaxBatchAgeScenario"

  Scenario: Get Current Context
    When I run "GetCurrentContextScenario"
    And I wait for 3 spans
    * the span named "part 1: null" exists
    * the span named "part 2: not null" exists
    * the span named "context" is the parent of the span named "part 2: not null"    

  @skip
  Scenario: Custom timings
    When I run "CustomSpanTimeScenario"
    And I wait for 1 span
    * every span field "startTimeUnixNano" equals "473385600000000000"
    * every span field "endTimeUnixNano" equals "504921600000000000"

  Scenario: Span With No Parent
    When I run "SpanWithNoParentScenario"
    And I wait for 2 spans
    * the span named "parent" exists
    * the span named "no-parent" exists
    * the span named "no-parent" has no parent

Scenario: Manual Navigation Span
    When I run "ManualNavigationSpanScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span field "name" equals "[Navigation]customNavigator/navigationScenarioRoute"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span string attribute "bugsnag.span.category" equals "navigation"
    * every span string attribute "bugsnag.navigation.route" equals "navigationScenarioRoute"
    * every span string attribute "bugsnag.navigation.navigator" equals "customNavigator"
    * every span string attribute "bugsnag.navigation.triggered_by" equals "manual"
    * every span string attribute "bugsnag.navigation.previous_route" equals "navigationScenarioPreviousRoute"
    * a span double attribute "bugsnag.sampling.p" equals 1.0


