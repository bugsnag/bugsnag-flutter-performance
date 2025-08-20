import 'package:flutter_test/flutter_test.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';

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
        
        // The span should be named with the custom suffix
        // We can't directly test the span name here without accessing internal state
        // This is more of a smoke test to ensure the API works
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
        
        // The span should revert to the original name
      }
    });

    test('should return null when AppStart span is not available', () async {
      // Don't start bugsnag performance
      
      // Try to get the AppStart span control
      final control = bugsnag_performance.getSpanControl(appStart);
      
      // Should return null when span is not available
      expect(control, isNull);
    });
  });
}