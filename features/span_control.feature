Feature: span control

  Background:
    Given I clear the Bugsnag cache

  Scenario: Custom AppStart span name
    Given I run "SetCustomAppStartNameScenario"
    And I wait to receive a span named "[AppStart/FlutterInit]FirstOpen"
    * I wait to receive a span named "[AppStartPhase/pre runApp()]"
    * I wait to receive a span named "[AppStartPhase/runApp()]"
    * I wait to receive a span named "[AppStartPhase/UI init]"
    * every span string attribute "bugsnag.app_start.type" equals "FlutterInit"
    * a span string attribute "bugsnag.app_start.name" equals "FirstOpen"

  Scenario: Clear custom AppStart span name
    Given I run "ClearCustomAppStartNameScenario"
    And I wait to receive a span named "[AppStart/FlutterInit]"
    * I wait to receive a span named "[AppStartPhase/pre runApp()]"
    * I wait to receive a span named "[AppStartPhase/runApp()]"
    * I wait to receive a span named "[AppStartPhase/UI init]"
    * every span string attribute "bugsnag.app_start.type" equals "FlutterInit"
    * every span string attribute "bugsnag.app_start.name" does not exist
