// Example usage of the AppStart span name customization API

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';

void main() async {
  // Start Bugsnag Performance
  await bugsnag_performance.start(
    apiKey: 'YOUR_API_KEY',
  );

  // Get the AppStart span control to customize the span name
  final appStartControl = bugsnag_performance.getSpanControl(appStart);
  
  if (appStartControl != null) {
    // Set a custom name suffix for the AppStart span
    // This will change the span name from "[AppStart/FlutterInit]" to "[AppStart/FlutterInit]FirstOpen"
    // and add a "bugsnag.app_start.name" attribute with value "FirstOpen"
    appStartControl.setType('FirstOpen');
    
    // Later, you can clear the custom name to revert to the default
    // This will change the span name back to "[AppStart/FlutterInit]"
    // and remove the "bugsnag.app_start.name" attribute
    appStartControl.clearType();
    
    // You can also set it to null explicitly (same as clearType)
    appStartControl.setType(null);
  }

  // Measure the runApp execution
  await bugsnag_performance.measureRunApp(() async {
    // Your app initialization code here
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

// The custom name can only be set while the AppStart span is still open.
// The AppStart span ends when the first ViewLoad span ends (or when UI initialization completes).
// This provides a reasonable time window for any app developer to set the custom name,
// especially when using BugsnagLoadingIndicator or similar utilities to hold the first ViewLoad open.