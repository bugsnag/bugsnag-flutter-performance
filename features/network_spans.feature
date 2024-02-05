Feature: Network Spans

  Scenario: HTTP Get
    When I run "HttpGetScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * the trace "Bugsnag-Span-Sampling" header equals "1:1"
    * every span field "name" equals "HTTP/GET"
