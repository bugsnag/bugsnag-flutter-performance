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