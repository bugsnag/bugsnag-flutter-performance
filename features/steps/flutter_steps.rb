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

