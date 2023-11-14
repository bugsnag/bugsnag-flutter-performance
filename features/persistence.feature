Feature: Persistence

  Scenario: Device Id Persists Between Launches
    When I run "ManualSpanScenario"
    And I relaunch the app
    And I run "ManualSpanScenario"
    And I wait for 2 spans
    * every span deviceid is valid and the same
