Feature: Resource Attributes

  Scenario: Common Attributes
    When I run "ManualSpanScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * every span field "name" equals "ManualSpanScenario"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"

    * the trace payload field "resourceSpans.0.resource" string attribute "deployment.environment" equals "development"
    * the trace payload field "resourceSpans.0.resource" string attribute "telemetry.sdk.name" equals "bugsnag.performance.flutter"
    * the trace payload field "resourceSpans.0.resource" string attribute "telemetry.sdk.version" exists
    * the trace payload field "resourceSpans.0.resource" string attribute "device.model.identifier" exists
    * the trace payload field "resourceSpans.0.resource" string attribute "service.version" equals "1.0.0"
    * the trace payload field "resourceSpans.0.resource" string attribute "device.manufacturer" exists
    * the trace payload field "resourceSpans.0.resource" string attribute "host.arch" exists
    * the trace payload field "resourceSpans.0.resource" string attribute "os.version" exists
    * the trace payload field "resourceSpans.0.resource" string attribute "net.host.connection.type" exists


  @android_only
  Scenario: Android Attributes
    When I run "ManualSpanScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * every span field "name" equals "ManualSpanScenario"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"

    * the trace payload field "resourceSpans.0.resource" string attribute "bugsnag.app.platform" equals "android"
    * the trace payload field "resourceSpans.0.resource" string attribute "bugsnag.app.version_code" equals "1"
    * the trace payload field "resourceSpans.0.resource" string attribute "bugsnag.device.android_api_version" exists
    * the trace payload field "resourceSpans.0.resource" string attribute "net.host.connection.type" exists


  @ios_only
  Scenario: iOS Attributes
    When I run "ManualSpanScenario"
    And I wait for 1 span
    Then the trace "Content-Type" header equals "application/json"
    * the trace "Bugsnag-Sent-At" header matches the regex "^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d\d\dZ$"
    * every span field "name" equals "ManualSpanScenario"
    * every span field "spanId" matches the regex "^[A-Fa-f0-9]{16}$"
    * every span field "traceId" matches the regex "^[A-Fa-f0-9]{32}$"
    * every span field "startTimeUnixNano" matches the regex "^[0-9]+$"
    * every span field "endTimeUnixNano" matches the regex "^[0-9]+$"

    * the trace payload field "resourceSpans.0.resource" string attribute "bugsnag.app.platform" equals "ios"
    * the trace payload field "resourceSpans.0.resource" string attribute "bugsnag.app.bundle_version" equals "1"
    * the trace payload field "resourceSpans.0.resource" string attribute "net.host.connection.type" exists
