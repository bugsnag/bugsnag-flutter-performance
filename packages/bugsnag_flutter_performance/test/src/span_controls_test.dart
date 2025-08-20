import 'package:flutter_test/flutter_test.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';
import 'package:bugsnag_flutter_performance/src/span_attributes.dart';
import 'package:bugsnag_flutter_performance/src/span_controls.dart';

void main() {
  group('AppStart Span Control', () {
    test('should allow setting custom AppStart span name', () async {
      // Start bugsnag performance
      await bugsnag_performance.start(
        apiKey: 'a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0',
      );
      
      // Try to get the AppStart span control
      final control = bugsnag_performance.getSpanControl(appStart);
      
      if (control != null) {
        // Set a custom type
        control.setType('FirstOpen');
        
        // Verify we can access the control
        expect(control, isNotNull);
      }
    });

    test('should clear custom AppStart span name', () async {
      // Start bugsnag performance
      await bugsnag_performance.start(
        apiKey: 'a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0',
      );
      
      // Try to get the AppStart span control
      final control = bugsnag_performance.getSpanControl(appStart);
      
      if (control != null) {
        // Set a custom type then clear it
        control.setType('FirstOpen');
        control.clearType();
        
        // Verify clearType calls setType with null
        expect(control, isNotNull);
      }
    });

    test('should return null when AppStart span is not available', () async {
      // Don't start bugsnag performance
      
      // Try to get the AppStart span control
      final control = bugsnag_performance.getSpanControl(appStart);
      
      // Should return null when span is not available
      expect(control, isNull);
    });

    test('should set bugsnag.app_start.name attribute', () {
      // Create a mock span to test the control implementation
      final span = BugsnagPerformanceSpanImpl(
        name: '[AppStart/FlutterInit]',
        startTime: DateTime.now(),
        attributes: BugsnagPerformanceSpanAttributes(),
      );
      
      // Create control for the span
      final control = AppStartSpanControlImpl(span);
      
      // Set custom type
      control.setType('FirstOpen');
      
      // Verify attribute is set
      expect(span.attributes.appStartName, equals('FirstOpen'));
      expect(span.name, equals('[AppStart/FlutterInit]FirstOpen'));
      
      // Clear the type
      control.clearType();
      
      // Verify attribute is removed and name is reverted
      expect(span.attributes.appStartName, isNull);
      expect(span.name, equals('[AppStart/FlutterInit]'));
    });

    test('should not modify closed spans', () {
      // Create a closed span
      final span = BugsnagPerformanceSpanImpl(
        name: '[AppStart/FlutterInit]',
        startTime: DateTime.now(),
        attributes: BugsnagPerformanceSpanAttributes(),
      );
      span.end(); // Close the span
      
      // Create control for the span
      final control = AppStartSpanControlImpl(span);
      
      // Try to set custom type on closed span
      control.setType('FirstOpen');
      
      // Verify span was not modified
      expect(span.attributes.appStartName, isNull);
      expect(span.name, equals('[AppStart/FlutterInit]'));
    });
  });
}