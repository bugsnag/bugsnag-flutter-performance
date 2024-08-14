Feature: Persistence

Background:
    Given I clear the Bugsnag cache

  Scenario: Device Id Persists Between Launches
    When I run "ManualSpanScenario"
    * I wait to receive a trace
    * I relaunch the app
    * I run "ManualSpanScenario"
    * I wait to receive 2 traces
    * every trace deviceid is valid and the same

  Scenario: Receive a persisted trace
    When I set the HTTP status code to 408
    * I run "ManualSpanScenario"
    * I wait for 1 span
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.spanId" is stored as the value "original_span_id"
    * I wait for requests to persist
    * I discard the oldest trace
    * I set the HTTP status code to 200
    * I relaunch the app
    * I run "StartSdkDefault"
    * I wait for 1 span
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.spanId" equals the stored value "original_span_id"

