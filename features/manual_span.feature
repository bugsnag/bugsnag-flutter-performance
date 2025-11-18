Feature: Manual Spans

  Background:
    Given I clear the Bugsnag cache

  Scenario: Manual Span
    When I run "ManualSpanScenario"
    And I wait to receive a span named "ManualSpanScenario"
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" is true
    * every span string attribute "bugsnag.span.category" equals "custom"
    * a span double attribute "bugsnag.sampling.p" equals 1.0

  Scenario: Manual Span isFirstClass false
    When I run "ManualSpanIsFirstClassFalseScenario"
    And I wait to receive a span named "ManualSpanIsFirstClassFalseScenario"
    * every span bool attribute "bugsnag.span.first_class" is false

  Scenario: Max Batch Age
    When I run "MaxBatchAgeScenario"
    And I wait to receive a span named "MaxBatchAgeScenario"
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"

  Scenario: Get Current Context
    When I run "GetCurrentContextScenario"
    And I wait to receive a span named "part 1: null"
    * I wait to receive a span named "part 2: not null"
    * I wait to receive a span named "context"
    * the span named "context" is the parent of the span named "part 2: not null"

  @skip
  Scenario: Custom timings
    When I run "CustomSpanTimeScenario"
    And I wait to receive at least 1 span
    * every span field "startTimeUnixNano" equals "473385600000000000"
    * every span field "endTimeUnixNano" equals "504921600000000000"

  Scenario: Span With No Parent
    When I run "SpanWithNoParentScenario"
    And I wait to receive at least 2 spans
    * the span named "parent" exists
    * the span named "no-parent" exists
    * the span named "no-parent" has no parent

  Scenario: Manual Navigation Span
    When I run "ManualNavigationSpanScenario"
    And I wait to receive a span named "[Navigation]customNavigator/navigationScenarioRoute"
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span string attribute "bugsnag.span.category" equals "navigation"
    * every span string attribute "bugsnag.navigation.route" equals "navigationScenarioRoute"
    * every span string attribute "bugsnag.navigation.navigator" equals "customNavigator"
    * every span string attribute "bugsnag.navigation.triggered_by" equals "manual"
    * every span string attribute "bugsnag.navigation.previous_route" equals "navigationScenarioPreviousRoute"
    * a span double attribute "bugsnag.sampling.p" equals 1.0

  Scenario: Custom attributes
    When I run "CustomSpanAttributesScenario"
    And I wait to receive a span named "CustomSpanAttributesScenarioSpan"
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "droppedAttributesCount" does not exist
    * every span bool attribute "bugsnag.span.first_class" is true
    * every span string attribute "bugsnag.span.category" equals "custom"
    * a span double attribute "bugsnag.sampling.p" equals 1.0
    * a span string attribute "customAttribute1" equals "C"
    * every span string attribute "customAttribute2" does not exist
    * a span integer attribute "customAttribute3" equals 3
    * a span double attribute "customAttribute4" equals 42.0
    * a span array attribute "customAttribute5" contains 4 items
    * a span array attribute "customAttribute5" contains the string value "customString" at index 0
    * a span array attribute "customAttribute5" contains the integer value 42 at index 1
    * a span array attribute "customAttribute5" contains the value true at index 2
    * a span array attribute "customAttribute5" contains the double value 43.0 at index 3
    * every span string attribute "customAttribute6" does not exist

  Scenario: Custom attributes - limits
    When I run "CustomSpanAttributesWithLimitsScenario"
    And  I wait to receive a span named "CustomSpanAttributesWithLimitsScenarioSpan"
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "droppedAttributesCount" equals 3
    * every span bool attribute "bugsnag.span.first_class" is true
    * every span string attribute "bugsnag.span.category" equals "custom"
    * a span double attribute "bugsnag.sampling.p" equals 1.0
    * a span integer attribute "customAttribute1" equals 42
    * every span string attribute "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" does not exist
    * a span string attribute "customAttribute2" equals "NotDropped"
    * a span array attribute "customAttribute3" contains 6 items
    * a span array attribute "customAttribute3" contains the integer value 1 at index 0
    * a span array attribute "customAttribute3" contains the integer value 2 at index 1
    * a span array attribute "customAttribute3" contains the integer value 3 at index 2
    * a span array attribute "customAttribute3" contains the integer value 4 at index 3
    * a span array attribute "customAttribute3" contains the integer value 5 at index 4
    * a span array attribute "customAttribute3" contains the integer value 6 at index 5
    * a span string attribute "customAttribute4" equals "VeryLongStringAttrib*** 27 CHARS TRUNCATED"
    * a span double attribute "customAttribute5" equals 42.0
    * every span string attribute "customAttribute6" does not exist
    * every span string attribute "customAttribute7" does not exist


