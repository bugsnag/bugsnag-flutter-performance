Feature: Automatic instrumentation spans

  Scenario: AutoInstrumentAppStartsScenario
    Given I run "AutoInstrumentAppStartsScenario"
    And I wait for 4 spans
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:4"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[AppStart/FlutterInit]"
    * a span field "name" equals "[AppStartPhase/pre runApp()]"
    * a span field "name" equals "[AppStartPhase/runApp()]"
    * a span field "name" equals "[AppStartPhase/UI init]"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * a span string attribute "bugsnag.phase" equals "pre runApp()"
    * a span string attribute "bugsnag.phase" equals "runApp()"
    * a span string attribute "bugsnag.phase" equals "UI init"
    * a span string attribute "bugsnag.span.category" equals "app_start"
    * a span string attribute "bugsnag.span.category" equals "app_start_phase"
    * every span bool attribute "bugsnag.span.first_class" does not exist
    * every span string attribute "bugsnag.app_start.type" equals "FlutterInit"
    * the span named "[AppStart/FlutterInit]" is the parent of the span named "[AppStartPhase/pre runApp()]"
    * the span named "[AppStart/FlutterInit]" is the parent of the span named "[AppStartPhase/runApp()]"
    * the span named "[AppStart/FlutterInit]" is the parent of the span named "[AppStartPhase/UI init]"

  Scenario: AutoInstrumentNavigationBasicScenario
    Given I run "AutoInstrumentNavigationBasicScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[Navigation]/AutoInstrumentNavigationBasicScenarioScreen"
    * a span string attribute "bugsnag.span.category" equals "navigation"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist

  Scenario: AutoInstrumentNavigationPhasedScenario
    Given I run "AutoInstrumentNavigationPhasedScenario"
    And I wait for 5 seconds
    * no span named "[Navigation]/AutoInstrumentNavigationPhasedScenarioScreen" exists
    And I invoke "step2"
    And I wait for 5 spans
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:5"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[Navigation]/AutoInstrumentNavigationPhasedScenarioScreen"
    * a span field "name" equals "[NavigationPhase/pre-build]/AutoInstrumentNavigationPhasedScenarioScreen"
    * a span field "name" equals "[NavigationPhase/build]/AutoInstrumentNavigationPhasedScenarioScreen"
    * a span field "name" equals "[NavigationPhase/appearing]/AutoInstrumentNavigationPhasedScenarioScreen"
    * a span field "name" equals "[NavigationPhase/loading]/AutoInstrumentNavigationPhasedScenarioScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationPhasedScenarioScreen" is the parent of the span named "[NavigationPhase/pre-build]/AutoInstrumentNavigationPhasedScenarioScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationPhasedScenarioScreen" is the parent of the span named "[NavigationPhase/build]/AutoInstrumentNavigationPhasedScenarioScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationPhasedScenarioScreen" is the parent of the span named "[NavigationPhase/appearing]/AutoInstrumentNavigationPhasedScenarioScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationPhasedScenarioScreen" is the parent of the span named "[NavigationPhase/loading]/AutoInstrumentNavigationPhasedScenarioScreen"
    * a span string attribute "bugsnag.phase" equals "pre-build"
    * a span string attribute "bugsnag.phase" equals "build"
    * a span string attribute "bugsnag.phase" equals "appearing"
    * a span string attribute "bugsnag.phase" equals "loading"
    * a span string attribute "bugsnag.span.category" equals "navigation"
    * a span string attribute "bugsnag.span.category" equals "navigation_phase"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist

  Scenario: AutoInstrumentNavigationBasicDeferScenario
    Given I run "AutoInstrumentNavigationBasicDeferScenario"
    And I wait for 5 seconds
    * no span named "[Navigation]/AutoInstrumentNavigationBasicDeferScenarioScreen" exists
    And I invoke "step2"
    Then I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[Navigation]/AutoInstrumentNavigationBasicDeferScenarioScreen"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist

  Scenario: AutoInstrumentNavigationComplexDeferScenario
    Given I run "AutoInstrumentNavigationComplexDeferScenario"
    And I wait for 3 seconds
    * no span named "[Navigation]/AutoInstrumentNavigationComplexDeferScenarioScreen" exists
    Then I invoke "step2"
    And I wait for 3 seconds
    * no span named "[Navigation]/AutoInstrumentNavigationComplexDeferScenarioScreen" exists
    Then I invoke "step3"
    And I wait for 3 seconds
    * no span named "[Navigation]/AutoInstrumentNavigationComplexDeferScenarioScreen" exists
    Then I invoke "step4"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[Navigation]/AutoInstrumentNavigationComplexDeferScenarioScreen"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist

  Scenario: AutoInstrumentNavigationEmbededPhasedScenario
    Given I run "AutoInstrumentNavigationEmbededPhasedScenario"
    And I wait for 3 seconds
    * no span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioScreen" exists
    * no span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen" exists
    * no span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen" exists
    Then I invoke "step2"
    And I wait for 10 spans
    And I wait for 2 seconds
    * no span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioScreen" exists
    * no span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen" exists
    * a span field "name" equals "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen"
    * a span field "name" equals "[NavigationPhase/pre-build]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen"
    * a span field "name" equals "[NavigationPhase/build]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen"
    * a span field "name" equals "[NavigationPhase/appearing]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen"
    * a span field "name" equals "[NavigationPhase/loading]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen" is the parent of the span named "[NavigationPhase/pre-build]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen" is the parent of the span named "[NavigationPhase/build]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen" is the parent of the span named "[NavigationPhase/appearing]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen" is the parent of the span named "[NavigationPhase/loading]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen"
    Then I invoke "step3"
    And I wait for 13 spans
    And I wait for 2 seconds
    * no span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen" exists
    * a span field "name" equals "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioScreen"
    * a span field "name" equals "[NavigationPhase/pre-build]/AutoInstrumentNavigationEmbededPhasedScenarioScreen"
    * a span field "name" equals "[NavigationPhase/build]/AutoInstrumentNavigationEmbededPhasedScenarioScreen"
    * a span field "name" equals "[NavigationPhase/appearing]/AutoInstrumentNavigationEmbededPhasedScenarioScreen"
    * a span field "name" equals "[NavigationPhase/loading]/AutoInstrumentNavigationEmbededPhasedScenarioScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioScreen" is the parent of the span named "[NavigationPhase/pre-build]/AutoInstrumentNavigationEmbededPhasedScenarioScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioScreen" is the parent of the span named "[NavigationPhase/build]/AutoInstrumentNavigationEmbededPhasedScenarioScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioScreen" is the parent of the span named "[NavigationPhase/appearing]/AutoInstrumentNavigationEmbededPhasedScenarioScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioScreen" is the parent of the span named "[NavigationPhase/loading]/AutoInstrumentNavigationEmbededPhasedScenarioScreen"
    Then I invoke "step4"
    And I wait for 15 spans
    * a span field "name" equals "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen"
    * a span field "name" equals "[NavigationPhase/pre-build]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen"
    * a span field "name" equals "[NavigationPhase/build]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen"
    * a span field "name" equals "[NavigationPhase/appearing]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen"
    * a span field "name" equals "[NavigationPhase/loading]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen" is the parent of the span named "[NavigationPhase/pre-build]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen" is the parent of the span named "[NavigationPhase/build]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen" is the parent of the span named "[NavigationPhase/appearing]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen" is the parent of the span named "[NavigationPhase/loading]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioScreen" is the parent of the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioFirstSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioScreen" is the parent of the span named "[Navigation]/AutoInstrumentNavigationEmbededPhasedScenarioLastSubScreen"
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist

  Scenario: AutoInstrumentNavigationNestedNavigationPhasedScenario
    Given I run "AutoInstrumentNavigationNestedNavigationPhasedScenario"
    And I wait for 2 spans
    * a span field "name" equals "[Navigation]/AutoInstrumentNavigationNestedNavigationPhasedScenarioNestedNavigatorScreen"
    Then I invoke "step2"
    And I wait for 5 spans
    * no span named "[Navigation]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen" exists
    * a span field "name" equals "[NavigationPhase/pre-build]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen"
    * a span field "name" equals "[NavigationPhase/build]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen"
    * a span field "name" equals "[NavigationPhase/appearing]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen"
    Then I invoke "step3"
    And I wait for 7 spans
    * a span field "name" equals "[Navigation]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen"
    * a span field "name" equals "[NavigationPhase/loading]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen" is the parent of the span named "[NavigationPhase/pre-build]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen" is the parent of the span named "[NavigationPhase/build]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen" is the parent of the span named "[NavigationPhase/appearing]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen"
    * the span named "[Navigation]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen" is the parent of the span named "[NavigationPhase/loading]/AutoInstrumentNavigationNestedNavigationPhasedScenarioSubScreen"
    Then I invoke "step4"
    And I wait for 8 spans
    * a span field "name" equals "[Navigation]/AutoInstrumentNavigationNestedNavigationPhasedScenarioPushedScreen"
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist