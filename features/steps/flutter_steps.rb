# frozen_string_literal: true

When('I clear the Bugsnag cache') do
  execute_command "clear_cache",""
end

When('I wait for requests to persist') do
  sleep 2
end

When('I run {string}') do |scenario_name|
  execute_command :run_scenario, scenario_name
end

When("I run {string} and relaunch the crashed app") do |event_type|
  step("I run \"#{event_type}\"")
  step('I relaunch the app after a crash')
end

When('I configure Bugsnag for {string}') do |scenario_name|
  execute_command :start_bugsnag, scenario_name
end

When('I configure the app to run in the {string} state') do |extra_config|
  $extra_config = extra_config
end

def execute_command(action, scenario_name)
  extra_config = $extra_config || ''
  command = { action: action, scenario_name: scenario_name, extra_config: extra_config }
  Maze::Server.commands.add command
  
  touch_action = Appium::TouchAction.new
  touch_action.tap({:x => 200, :y => 200})
  touch_action.perform

  $extra_config = ''
  # Ensure fixture has read the command
  count = 100
  sleep 0.1 until Maze::Server.commands.remaining.empty? || (count -= 1) < 1
  raise 'Test fixture did not GET /command' unless Maze::Server.commands.remaining.empty?
end

When('I relaunch the app') do
  Maze.driver.launch_app
end

When("I relaunch the app after a crash") do
  # Wait for the app to stop running before relaunching
  step 'the app is not running'
  Maze.driver.launch_app
end

Then('the app is not running') do
  Maze::Wait.new(interval: 1, timeout: 20).until do
    Maze.driver.app_state('com.bugsnag.flutter.test.app') == :not_running
  end
end

Then(/^on (Android|iOS), (.+)/) do |platform, step_text|
  current_platform = Maze::Helper.get_current_platform
  step(step_text) if current_platform.casecmp(platform).zero?
end

Then('every span bool attribute {string} is false') do |attribute|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze::check.false span['attributes'].find { |a| a['key'] == attribute }['value']['boolValue'] }
end

Then('every span bool attribute {string} does not exist') do |attribute|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze.check.nil span['attributes'].find { |a| a['key'] == attribute } }
end

Then('every span string attribute {string} does not exist') do |attribute|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  spans.map { |span| Maze.check.nil span['attributes'].find { |a| a['key'] == attribute } }
end

Then('all span bool attribute {string} is true') do |attribute|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('boolValue') } }.compact
  selected_attributes.map { |a| Maze::check.true a['value']['boolValue'] }
end

Then('a span bool attribute {string} is true') do |attribute|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('boolValue') } }.compact
  selected_attributes = selected_attributes.map { |a| a['value']['boolValue'] == true }
  Maze.check.false(selected_attributes.empty?)
end

Then('all span bool attribute {string} is false') do |attribute|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('boolValue') } }.compact
  selected_attributes.map { |a| Maze::check.false a['value']['boolValue'] }
end

Then('a span bool attribute {string} is false') do |attribute|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('boolValue') } }.compact
  selected_attributes = selected_attributes.map { |a| a['value']['boolValue'] == false }
  Maze.check.false(selected_attributes.empty?)
end

Then('a span bool attribute {string} does not exist') do |attribute|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_keys = spans.map { |span| !span['attributes'].find { |a| a['key'] == attribute } }
  Maze.check.false(selected_keys.empty?)
end

Then('a span string attribute {string} matches the regex {string}') do |attribute, pattern|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('stringValue') } }.compact
  attribute_values = selected_attributes.map { |a| a['value']['stringValue'] }
  attribute_values.map { |v| Maze.check.match pattern, v }
end

Then('a span integer attribute {string} is greater than {int}') do |attribute, expected|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('intValue') } }.compact
  attribute_values = selected_attributes.map { |a| a['value']['intValue'].to_i > expected }
  Maze.check.false(attribute_values.empty?)
end

Then('a span integer attribute {string} equals {int}') do |attribute, expected|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('intValue') } }.compact
  attribute_values = selected_attributes.map { |a| a['value']['intValue'].to_i == expected }
  Maze.check.false(attribute_values.empty?)
end

Then('a span double attribute {string} equals {float}') do |attribute, value|
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) && a['value'].has_key?('doubleValue') } }.compact
  selected_attributes = selected_attributes.map { |a| a['value']['doubleValue'] == value }
  Maze.check.false(selected_attributes.empty?)
end

When('every trace deviceid is valid and the same') do
  list = Maze::Server.list_for 'trace'
  resource_spans = Maze::Helper.read_key_path(list.current[:body], 'resourceSpans')

  # Extract and validate device IDs
  device_ids = resource_spans.map do |resource_span|
    attributes = resource_span.dig('resource', 'attributes')
    device_id_attribute = attributes.find { |a| a['key'] == 'device.id' }
    device_id_value = device_id_attribute&.dig('value', 'stringValue')
    
    # Check device ID length and validity
    valid_device_id = device_id_value.is_a?(String) && device_id_value.length == 32

    # If device ID is not valid, you might want to handle it appropriately
    raise "Invalid device ID: #{device_id_value}" unless valid_device_id

    device_id_value
  end

  # Check if all device IDs are the same
  Maze.check.true(device_ids.uniq.length == 1)
end

When('I invoke {string}') do |method_name|
  Maze::Server.commands.add({ action: "invoke_method", args: [method_name] })
  # Ensure fixture has read the command
  touch_action = Appium::TouchAction.new
  touch_action.tap({:x => 200, :y => 200})
  touch_action.perform

  $extra_config = ''
  # Ensure fixture has read the command
  count = 100
  sleep 0.1 until Maze::Server.commands.remaining.empty? || (count -= 1) < 1
  raise 'Test fixture did not GET /command' unless Maze::Server.commands.remaining.empty?
end
Then('the span named {string} exists') do |span_name|
  spans = spans_from_request_list(Maze::Server.list_for("traces"))

  spans_with_name = spans.find_all { |span| span['name'].eql?(span_name) }

  Maze.check.true(spans_with_name.length() == 1);
end

Then('the span named {string} is the parent of the span named {string}') do |span1name, span2name|
  
  spans = spans_from_request_list(Maze::Server.list_for("traces"))

  span1 = spans.find_all { |span| span['name'].eql?(span1name) }.first

  span2 = spans.find_all { |span| span['name'].eql?(span2name) }.first

  Maze.check.true(span1['spanId'] == span2['parentSpanId']);

end

Then('the span named {string} has no parent') do |spanName|
  spans = spans_from_request_list(Maze::Server.list_for("traces"))

  span1 = spans.find_all { |span| span['name'].eql?(spanName) }.first

  Maze.check.true(span1['parentSpanId'] == nil);
end

Then('no span named {string} exists') do |span_name|
  spans = spans_from_request_list(Maze::Server.list_for("traces"))

  spans_with_name = spans.find_all { |span| span['name'].eql?(span_name) }

  Maze.check.true(spans_with_name.length() == 0);
end

Then('a span array attribute {string} contains the string value {string} at index {int}') do |attribute, expected, index|
  value = get_array_value_at_index(attribute, index, 'stringValue')
  Maze.check.true(value == expected)
end

Then('a span array attribute {string} contains the integer value {int} at index {int}') do |attribute, expected, index|
  value = get_array_value_at_index(attribute, index, 'intValue')
  Maze.check.true(value.to_i == expected)
end

Then('a span array attribute {string} contains the double value {float} at index {int}') do |attribute, expected, index|
  value = get_array_value_at_index(attribute, index, 'doubleValue')
  Maze.check.true(value == expected)
end

Then('a span array attribute {string} contains the value true at index {int}') do |attribute, index|
  value = get_array_value_at_index(attribute, index, 'boolValue')
  Maze.check.true(value == true)
end

Then('a span array attribute {string} contains the value false at index {int}') do |attribute, index|
  value = get_array_value_at_index(attribute, index, 'boolValue')
  Maze.check.true(value == false)
end

Then('a span array attribute {string} contains {int} items') do |attribute, length|
  array = get_array_attribute_contents(attribute)
  Maze.check.true(array.length() == length)
end

Then('a span array attribute {string} is empty') do |attribute|
  array_contents = get_array_attribute_contents(attribute)
  Maze.check.true(array_contents.empty?)
end

def get_array_value_at_index(attribute, index, type)
  array = get_array_attribute_contents(attribute)
  Maze.check.true(array.length() > index)
  value = array[index]
  Maze.check.true(value.has_key?(type))
  return value[type]
end

def get_array_attribute_contents(attribute)
  spans = spans_from_request_list(Maze::Server.list_for('traces'))
  selected_attributes = spans.map { |span| span['attributes'].find { |a| a['key'].eql?(attribute) &&
                                                                         a['value'].has_key?('arrayValue') &&
                                                                         a['value']['arrayValue'].has_key?('values') } }.compact
  array_attributes = selected_attributes.map { |a| a['value']['arrayValue']['values'] }
  Maze.check.false(array_attributes.empty?)
  return array_attributes[0]
end
