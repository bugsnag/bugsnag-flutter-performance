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
    * a span field "name" equals "[Navigation]basic_navigation_scenario"
    * a span string attribute "bugsnag.span.category" equals "navigation"
    * a span string attribute "bugsnag.navigation.route" equals "basic_navigation_scenario"
    * a span string attribute "bugsnag.navigation.triggered_by" equals "push"
    * a span string attribute "bugsnag.navigation.ended_by" equals "frame_render"
    * a span string attribute "bugsnag.navigation.previous_route" equals "/"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist

  Scenario: AutoInstrumentNavigationBasicDeferScenario
    Given I run "AutoInstrumentNavigationBasicDeferScenario"
    And I wait for 5 seconds
    * no span named "[Navigation]basic_defer_navigation_scenario" exists
    And I invoke "step2"
    Then I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[Navigation]basic_defer_navigation_scenario"
    * a span string attribute "bugsnag.navigation.route" equals "basic_defer_navigation_scenario"
    * a span string attribute "bugsnag.navigation.triggered_by" equals "push"
    * a span string attribute "bugsnag.navigation.ended_by" equals "loading_indicator"
    * a span string attribute "bugsnag.navigation.previous_route" equals "/"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist

  Scenario: AutoInstrumentNavigationComplexDeferScenario
    Given I run "AutoInstrumentNavigationComplexDeferScenario"
    And I wait for 3 seconds
    * no span named "[Navigation]complex_defer_navigation_scenario" exists
    Then I invoke "step2"
    And I wait for 3 seconds
    * no span named "[Navigation]complex_defer_navigation_scenario" exists
    Then I invoke "step3"
    And I wait for 3 seconds
    * no span named "[Navigation]complex_defer_navigation_scenario" exists
    Then I invoke "step4"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[Navigation]complex_defer_navigation_scenario"
    * a span string attribute "bugsnag.navigation.route" equals "complex_defer_navigation_scenario"
    * a span string attribute "bugsnag.navigation.triggered_by" equals "push"
    * a span string attribute "bugsnag.navigation.ended_by" equals "loading_indicator"
    * a span string attribute "bugsnag.navigation.previous_route" equals "/"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist

  Scenario: AutoInstrumentNavigationNestedNavigationScenario
    Given I run "AutoInstrumentNavigationNestedNavigationScenario"
    And I wait for 3 seconds
    * no span named "[Navigation]nested_defer_navigation_scenario_parent" exists
    Then I invoke "step2"
    And I wait for 2 spans
    * a span field "name" equals "[Navigation]nested_defer_navigation_scenario_parent"
    * a span string attribute "bugsnag.navigation.route" equals "nested_defer_navigation_scenario_parent"
    * a span string attribute "bugsnag.navigation.triggered_by" equals "push"
    * a span string attribute "bugsnag.navigation.ended_by" equals "loading_indicator"
    * a span string attribute "bugsnag.navigation.previous_route" equals "/"

    * a span field "name" equals "[Navigation]nested_scenario_child_navigator/nested_scenario_child_route_initial"
    * a span string attribute "bugsnag.navigation.route" equals "nested_scenario_child_route_initial"
    * a span string attribute "bugsnag.navigation.triggered_by" equals "push"
    * a span string attribute "bugsnag.navigation.ended_by" equals "loading_indicator"
    * a span string attribute "bugsnag.navigation.previous_route" equals "/"
    * a span string attribute "bugsnag.navigation.navigator" equals "nested_scenario_child_navigator"
    Then I invoke "step3"
    And I wait for 3 spans
    * a span field "name" equals "[Navigation]nested_scenario_child_navigator/nested_scenario_child_route_2"
    * a span string attribute "bugsnag.navigation.route" equals "nested_scenario_child_route_2"
    * a span string attribute "bugsnag.navigation.triggered_by" equals "push"
    * a span string attribute "bugsnag.navigation.ended_by" equals "frame_render"
    * a span string attribute "bugsnag.navigation.previous_route" equals "nested_scenario_child_route_initial"
    * a span string attribute "bugsnag.navigation.navigator" equals "nested_scenario_child_navigator"
    Then I invoke "step4"
    And I wait for 4 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[Navigation]nested_scenario_child_navigator/nested_scenario_child_route_3"
    * a span string attribute "bugsnag.navigation.route" equals "nested_scenario_child_route_3"
    * a span string attribute "bugsnag.navigation.triggered_by" equals "replace"
    * a span string attribute "bugsnag.navigation.ended_by" equals "frame_render"
    * a span string attribute "bugsnag.navigation.previous_route" equals "nested_scenario_child_route_2"
    * a span string attribute "bugsnag.navigation.navigator" equals "nested_scenario_child_navigator"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist

  Scenario: AutoInstrumentNavigationPushAndPopScenario
    Given I run "AutoInstrumentNavigationPushAndPopScenario"
    And I wait for 1 span
    * a span field "name" equals "[Navigation]push_and_pop_scenario"
    * a span string attribute "bugsnag.navigation.route" equals "push_and_pop_scenario"
    * a span string attribute "bugsnag.navigation.triggered_by" equals "push"
    * a span string attribute "bugsnag.navigation.ended_by" equals "frame_render"
    * a span string attribute "bugsnag.navigation.previous_route" equals "/"
    And I invoke "step2"
    Then I wait for 2 spans
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[Navigation]push_and_pop_scenario"
    * a span string attribute "bugsnag.navigation.route" equals "push_and_pop_scenario"
    * a span string attribute "bugsnag.navigation.triggered_by" equals "pop"
    * a span string attribute "bugsnag.navigation.ended_by" equals "frame_render"
    * a span string attribute "bugsnag.navigation.previous_route" equals "push_and_pop_scenario"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist

  Scenario: AutoInstrumentViewLoadBasicScenario
    Given I run "AutoInstrumentViewLoadBasicScenario"
    And I wait for 3 spans
    And I wait for 3 seconds
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:3"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadBasicScenarioWidget"
    * a span string attribute "bugsnag.span.category" equals "view_load"
    * a span string attribute "bugsnag.span.category" equals "view_load_phase"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicScenarioWidget/building"
    * a span string attribute "bugsnag.phase" equals "building"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicScenarioWidget/appearing"
    * a span string attribute "bugsnag.phase" equals "appearing"
    * no span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicScenarioWidget/loading" exists
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadBasicScenarioWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicScenarioWidget/building"
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadBasicScenarioWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicScenarioWidget/appearing"

  Scenario: AutoInstrumentViewLoadBasicDeferScenario
    Given I run "AutoInstrumentViewLoadBasicDeferScenario"
    And I wait for 2 spans
    And I wait for 3 seconds
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget/building"
    * a span string attribute "bugsnag.phase" equals "building"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget/appearing"
    * a span string attribute "bugsnag.phase" equals "appearing"
    * a span string attribute "bugsnag.span.category" equals "view_load_phase"
    * no span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget" exists
    * no span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget/loading" exists
    And I invoke "step2"
    And I wait for 4 spans
    * a span field "name" equals "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget"
    * a span string attribute "bugsnag.span.category" equals "view_load"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget/loading"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget/building"
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget/appearing"
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadBasicDeferScenarioWidget/loading"

  Scenario: AutoInstrumentViewLoadNestedScenario
    Given I run "AutoInstrumentViewLoadNestedScenario"
    And I wait for 4 spans
    And I wait for 3 seconds
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget/building"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget/building"
    * a span string attribute "bugsnag.phase" equals "building"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget/appearing"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget/appearing"
    * a span string attribute "bugsnag.phase" equals "appearing"
    * a span string attribute "bugsnag.span.category" equals "view_load_phase"
    * no span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget" exists
    * no span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget/loading" exists
    * no span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget" exists
    * no span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget/loading" exists
    And I invoke "step2"
    And I wait for 8 spans
    * a span field "name" equals "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget"
    * a span field "name" equals "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget"
    * a span string attribute "bugsnag.span.category" equals "view_load"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget/loading"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget/loading"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget/building"
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget/appearing"
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioWidget/loading"
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget/building"
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget/appearing"
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentViewLoadNestedScenarioChildWidget/loading"

  Scenario: AutoInstrumentNavigationWithViewLoadScenario
    Given I run "AutoInstrumentNavigationWithViewLoadScenario"
    And I wait for 3 seconds
    * no span named "[Navigation]navigation_view_load_scenario" exists
    * no span named "[ViewLoad]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget" exists
    Then I invoke "step2"
    And I wait for 3 seconds
    * no span named "[Navigation]navigation_view_load_scenario" exists
    * no span named "[ViewLoad]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget" exists
    Then I invoke "step3"
    And I wait for 3 seconds
    * no span named "[Navigation]navigation_view_load_scenario" exists
    * no span named "[ViewLoad]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget" exists
    Then I invoke "step4"
    And I wait for 5 spans
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * a span field "name" equals "[Navigation]navigation_view_load_scenario"
    * a span string attribute "bugsnag.navigation.route" equals "navigation_view_load_scenario"
    * a span string attribute "bugsnag.navigation.triggered_by" equals "push"
    * a span string attribute "bugsnag.navigation.ended_by" equals "loading_indicator"
    * a span string attribute "bugsnag.navigation.previous_route" equals "/"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget/building"
    * a span string attribute "bugsnag.phase" equals "building"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget/appearing"
    * a span string attribute "bugsnag.phase" equals "appearing"
    * a span field "name" equals "[ViewLoadPhase]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget/loading"
    * a span string attribute "bugsnag.phase" equals "loading"
    * a span string attribute "bugsnag.span.category" equals "view_load_phase"
    * a span field "name" equals "[ViewLoad]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget"
    * a span string attribute "bugsnag.span.category" equals "view_load"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"
    * every span bool attribute "bugsnag.span.first_class" does not exist
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget/building"
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget/appearing"
    * the span named "[ViewLoad]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget" is the parent of the span named "[ViewLoadPhase]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget/loading"
    * the span named "[Navigation]navigation_view_load_scenario" is the parent of the span named "[ViewLoad]FlutterWidget/AutoInstrumentNavigationWithViewLoadWidget"