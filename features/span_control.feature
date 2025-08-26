Feature: span control

  Background:
    Given I clear the Bugsnag cache

  Scenario: Custom AppStart span name
    Given I run "SetCustomAppStartNameScenario"
    And I wait for 4 spans
      * a span field "name" equals "[AppStart/FlutterInit]"
    * a span field "name" equals "[AppStartPhase/pre runApp()]"
    * a span field "name" equals "[AppStartPhase/runApp()]"
    * a span field "name" equals "[AppStartPhase/UI init]"
    * every span string attribute "bugsnag.app_start.type" equals "FlutterInit"
    * a span string attribute "bugsnag.app_start.name" equals "FirstOpen"

  Scenario: Clear custom AppStart span name
    Given I run "ClearCustomAppStartNameScenario"
    And I wait for 4 spans
    * a span field "name" equals "[AppStart/FlutterInit]"
    * a span field "name" equals "[AppStartPhase/pre runApp()]"
    * a span field "name" equals "[AppStartPhase/runApp()]"
    * a span field "name" equals "[AppStartPhase/UI init]"
    * every span string attribute "bugsnag.app_start.type" equals "FlutterInit"
    * every span string attribute "bugsnag.app_start.name" does not exist
