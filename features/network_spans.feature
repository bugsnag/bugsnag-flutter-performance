Feature: Network Spans

  Background:
    Given I clear the Bugsnag cache

  Scenario: HTTP Get
    When I run "HttpGetScenario"
    And I wait to receive at least 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span bool attribute "bugsnag.span.first_class" does not exist
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HTTP/GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "network"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.method" equals "GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.url" matches the regex "^http:\/\/\S*:\d{4}(\/.*)?"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.status_code" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.response.header.content-length" is greater than 0

  Scenario: HTTP Post
    When I run "HttpPostScenario"
    And I wait to receive at least 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span bool attribute "bugsnag.span.first_class" does not exist
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HTTP/POST"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "network"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.method" equals "POST"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.url" matches the regex "^http:\/\/\S*:\d{4}(\/.*)?"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.status_code" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.request.header.content-length" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.response.header.content-length" is greater than 0

    #this is to make sure that mutliple spans wont be created for the same request
  Scenario: HTTP Get Multiple Subscribers
    When I run "HttpGetMultipleSubscribersScenario"
    And I wait to receive at least 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span bool attribute "bugsnag.span.first_class" does not exist
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HTTP/GET"

  Scenario: HTTP Callback Url Edit
    When I run "HttpCallbackEditScenario"
    And I wait to receive at least 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span bool attribute "bugsnag.span.first_class" does not exist
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HTTP/GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "network"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.method" equals "GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.url" equals "edited"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.status_code" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.response.header.content-length" is greater than 0

  Scenario: HTTP Callback Cancel Span
    When I run "HttpCallbackCancelSpan"
    And I wait to receive at least 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span bool attribute "bugsnag.span.first_class" is true
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HttpCallbackCancelSpanScenario"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "custom"

  Scenario: Http client trace parent header
    When I run "HttpClientTraceparentScenario"

    And I wait to receive 1 reflection
    * the reflection "traceparent" header matches the regex "^00-[A-Fa-f0-9]{32}-[A-Fa-f0-9]{16}-01"

  Scenario: Http client trace propagation urls header
    When I run "HttpClientTracePropagationUrlsScenario"

    And I wait to receive 2 reflections
    * the reflection "traceparent" header is not present
    * I discard the oldest reflection
    * the reflection "traceparent" header matches the regex "^00-[A-Fa-f0-9]{32}-[A-Fa-f0-9]{16}-01"

  Scenario: Uncompressed request/response body sizes
    When I run "UncompressedNetworkBodySizesScenario"
    And I wait to receive at least 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "UncompressedBodySizes"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.request.body.size" equals 123
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.response.body.size" equals 456

    #DIO WRAPPER

  Scenario: DIO Get
    When I run "DIOGetScenario"
    And I wait to receive at least 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HTTP/GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "network"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.method" equals "GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.url" matches the regex "^http:\/\/\S*:\d{4}(\/.*)?"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.status_code" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.response.header.content-length" is greater than 0

  Scenario: DIO Post
    When I run "DIOPostScenario"
    And I wait to receive at least 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HTTP/POST"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "network"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.method" equals "POST"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.url" matches the regex "^http:\/\/\S*:\d{4}(\/.*)?"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.status_code" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.request.header.content-length" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.response.header.content-length" is greater than 0

  Scenario: DIO Callback Url Edit
    When I run "DIOCallbackEditScenario"
    And I wait to receive at least 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HTTP/GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "network"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.method" equals "GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.url" equals "edited"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.status_code" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.response.header.content-length" is greater than 0

  Scenario: DIO Callback Cancel Span
    When I run "DIOCallbackCancelSpan"
    And I wait to receive at least 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "DIOCallbackCancelSpanScenario"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "custom"

    #DART IO WRAPPER
  Scenario: DIO Get
    When I run "DartIoGetScenario"
    And I wait to receive at least 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0.name" equals "HTTP/GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "bugsnag.span.category" equals "network"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.method" equals "GET"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" string attribute "http.url" matches the regex "^http:\/\/\S*:\d{4}(\/.*)?"
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.status_code" is greater than 0
    * the trace payload field "resourceSpans.0.scopeSpans.0.spans.0" integer attribute "http.response.header.content-length" is greater than 0

  Scenario: Network callback type
    When I run "CheckNetworkCallbackTypeScenario"
    And I wait to receive a span named "GET"
    Then the trace "Content-Type" header equals "application/json"

  Scenario: Dart io trace parent header
    When I run "DartIoTraceparentScenario"

    And I wait to receive 1 reflection
    * the reflection "traceparent" header matches the regex "^00-[A-Fa-f0-9]{32}-[A-Fa-f0-9]{16}-01"



    