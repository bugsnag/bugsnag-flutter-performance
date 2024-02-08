Feature: Network Spans

  Scenario: HTTP Get
    When I run "HttpGetScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HTTP/GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "network"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.method" equals "GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.url" matches the regex "^http:\/\/\S*:\d{4}(\/.*)?"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.status_code" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.response_content_length" is greater than 0

  Scenario: HTTP Post
    When I run "HttpPostScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HTTP/POST"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "network"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.method" equals "POST"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.url" matches the regex "^http:\/\/\S*:\d{4}(\/.*)?"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.status_code" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.request_content_length" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.response_content_length" is greater than 0

  Scenario: HTTP Callback Url Edit
    When I run "HttpCallbackEditScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HTTP/GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "network"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.method" equals "GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.url" equals "edited"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.status_code" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.response_content_length" is greater than 0

  Scenario: HTTP Callback Cancel Span
    When I run "HttpCallbackCancelSpan"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HttpCallbackCancelSpanScenario"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "custom"



    