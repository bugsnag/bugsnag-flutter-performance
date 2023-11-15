Feature: Persistence

  Scenario: Device Id Persists Between Launches
    When I run "ManualSpanScenario"
    * the trace payload field "resourceSpans.0.resource.attributes.0.traceId" is stored as the value "parent_trace_id"
    * I relaunch the app
    * I run "ManualSpanScenario"
    * I wait to receive 2 traces
    * every trace deviceid is valid and the same
