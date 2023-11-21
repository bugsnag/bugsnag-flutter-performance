import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';

const apiKey = 'add_your_api_key_here';

Future<void> main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
            child: TextButton(
                onPressed: startTestsSpan, child: Text('send test spans'))),
      ),
    );
  }
}

void startTestsSpan() {
  BugsnagPerformance.start(apiKey: apiKey);
  for (var i = 0; i < 200; i++) {
    BugsnagPerformance.startSpan("test " + i.toString()).end();
  }
}
