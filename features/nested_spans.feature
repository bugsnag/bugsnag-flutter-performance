Feature: Nested Spans

  Scenario: Simple Nested Span
    When I run "SimpleNestedSpanScenario"
    * I wait for 2 spans
    * the span named "span1" exists
    * the span named "span2" exists
    * the span named "span1" is the parent of the span named "span2"
    * the span named "span1" has no parent

  Scenario: New Zone New Context
    When I run "NewZoneNewContextScenario"
    * I wait for 4 spans
    * the span named "span1" exists
    * the span named "span2" exists
    * the span named "span3" exists
    * the span named "span4" exists

    * the span named "span1" has no parent
    * the span named "span3" has no parent

    * the span named "span1" is the parent of the span named "span2"    
    * the span named "span3" is the parent of the span named "span4"

  Scenario: Pass Context To New Zone
    When I run "PassContextToNewZoneScenario"
    * I wait for 3 spans
    * the span named "span1" exists
    * the span named "span2" exists
    * the span named "span3" exists

    * the span named "span1" has no parent

    * the span named "span1" is the parent of the span named "span2"    
    * the span named "span1" is the parent of the span named "span3"
