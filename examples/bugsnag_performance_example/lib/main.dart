import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart';
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
                onPressed: sendTestSpan, child: Text('send test span'))),
      ),
    );
  }
}

void sendTestSpan() {
  BugsnagPerformance.start(apiKey: apiKey);
  BugsnagPerformance.startSpan('test').end();
}

void sendNetworkSpan() {
  BugsnagPerformance.start(
      apiKey: apiKey,
      networkRequestCallback: (info) {
        info.url = "sanitised_url";
        return info;
      });
  BugSnagHttpClient()
      .withSubscriber(BugsnagPerformance.networkInstrumentation)
      .get(Uri.parse("https://www.google.com"));
}
