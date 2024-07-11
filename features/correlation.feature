Feature: Error correlation

  Scenario: CorrelationSimpleScenario
    When I run "CorrelationSimpleScenario"
    * I wait to receive an error
    * I wait for 1 span
    * the exception "message" equals "CorrelationSimpleScenario"

    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.traceId" matches the regex "^[A-Fa-f0-9]{32}$"

    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.spanId" is stored as the value "context_span_id"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.traceId" is stored as the value "context_trace_id"

    * the error payload field "events.0.correlation.spanid" equals the stored value "context_span_id"
    * the error payload field "events.0.correlation.traceid" equals the stored value "context_trace_id"

