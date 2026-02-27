Feature: Nested Spans

  Background:
    Given I clear the Bugsnag cache

  Scenario: Simple Nested Span
    When I run "SimpleNestedSpanScenario"
    *  I wait to receive a span named "span1"
    *  I wait to receive a span named "span2"
    * the span named "span1" is the parent of the span named "span2"
    * the span named "span1" has no parent

  Scenario: New Zone New Context
    When I run "NewZoneNewContextScenario"
    *  I wait to receive a span named "span1"
    *  I wait to receive a span named "span2"
    *  I wait to receive a span named "span3"
    *  I wait to receive a span named "span4"

    * the span named "span1" has no parent
    * the span named "span3" has no parent

    * the span named "span1" is the parent of the span named "span2"    
    * the span named "span3" is the parent of the span named "span4"

  Scenario: Pass Context To New Zone
    When I run "PassContextToNewZoneScenario"
    *  I wait to receive a span named "span1"
    *  I wait to receive a span named "span2"
    *  I wait to receive a span named "span3"

    * the span named "span1" has no parent

    * the span named "span1" is the parent of the span named "span2"    
    * the span named "span2" is the parent of the span named "span3"

 Scenario: Make Current Context False
    When I run "MakeCurrentContextScenario"
    *  I wait to receive a span named "span1"
    *  I wait to receive a span named "span2"
    *  I wait to receive a span named "span3"

    * the span named "span1" has no parent

    * the span named "span1" is the parent of the span named "span2"    
    * the span named "span1" is the parent of the span named "span3"
