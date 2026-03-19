Pod::Spec.new do |s|
  s.name             = 'bugsnag_flutter_performance'
  s.version          = '1.0.0'
  s.summary          = 'Bugsnag Flutter Performance plugin with metrics support'
  s.description      = <<-DESC
Bugsnag Flutter Performance plugin with CPU, memory, and rendering metrics support.
                       DESC
  s.homepage         = 'https://www.bugsnag.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bugsnag' => 'support@bugsnag.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.swift_version = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
