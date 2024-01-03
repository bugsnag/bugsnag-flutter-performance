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
    * the span named "[AppStart/FlutterInit]" is the parent of the span named "[AppStartPhase/pre runApp()]"
    * the span named "[AppStart/FlutterInit]" is the parent of the span named "[AppStartPhase/runApp()]"
    * the span named "[AppStart/FlutterInit]" is the parent of the span named "[AppStartPhase/UI init]"
