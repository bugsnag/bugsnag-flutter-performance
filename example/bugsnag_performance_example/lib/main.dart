import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart' as http;
import 'package:flutter/material.dart';

const apiKey = 'YOUR_API_KEY_HERE';

Future<void> main() async {
  bugsnag_performance.start(apiKey: apiKey);
  http.addSubscriber(bugsnag_performance.networkInstrumentation);
  bugsnag_performance.measureRunApp(() async => runApp(const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: sendCustomSpan,
                  child: const Text('Send Custom Span'),
                ),
                TextButton(
                  onPressed: sendCpuSpan,
                  child: const Text('Send CPU Metrics Span'),
                ),
                TextButton(
                  onPressed: sendMemorySpan,
                  child: const Text('Send Memory Metrics Span'),
                ),
                TextButton(
                  onPressed: sendNetworkSpan,
                  child: const Text('Send Network Span'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendCustomSpan() {
    bugsnag_performance.startSpan('test').end();
  }

  Future<void> sendCpuSpan() async {
    final options = const SpanOptions().withMetrics(
      const SpanMetrics(cpu: true, rendering: false, memory: false),
    );
    final span = bugsnag_performance.startSpan(
      'example.per_span.cpu_only',
      options: options,
    );
    await Future<void>.delayed(const Duration(seconds: 3));
    span.end();
  }

  Future<void> sendMemorySpan() async {
    final options = const SpanOptions().withMetrics(
      const SpanMetrics(cpu: false, rendering: false, memory: true),
    );
    final span = bugsnag_performance.startSpan(
      'example.per_span.memory_only',
      options: options,
    );
    await Future<void>.delayed(const Duration(seconds: 3));
    span.end();
  }

  void sendNetworkSpan() {
    http.get(Uri.parse('https://httpbin.org/get'));
  }
}
