import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart' as http;
import 'package:flutter/material.dart';

const apiKey = 'YOUR_API_KEY_HERE';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BugsnagPerformance.start(apiKey: apiKey);
  http.addSubscriber(BugsnagPerformance.networkInstrumentation);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Row( // Use Column for vertical alignment
            mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
            children: [
              TextButton(
                onPressed: sendCustomSpan, // Replace with your actual function
                child: Text('Send Custom Span'),
              ),
              SizedBox(width: 20), // Spacing between buttons, adjust as needed
              TextButton(
                onPressed: sendNetworkSpan, // You'll need to define this function
                child: Text('Send Network Span'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendCustomSpan() {
    BugsnagPerformance.startSpan('test').end();
  }

  void sendNetworkSpan() {
    http.get(Uri.parse('https://httpbin.org/get'));
  }
}



