Feature: Persistence

  Scenario: Device Id Persists Between Launches
    When I run "ManualSpanScenario"
    * I relaunch the app
    * I run "ManualSpanScenario"
    * I wait to receive 2 traces
    * every trace deviceid is valid and the same
