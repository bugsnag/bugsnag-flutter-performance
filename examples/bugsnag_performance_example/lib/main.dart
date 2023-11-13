import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:flutter/material.dart';

const apiKey = 'add_your_api_key_here';

Future<void> main() async {
  await bugsnag.start(apiKey: '227df1042bc7772c321dbde3b31a03c2');
  runApp(const MainApp());

}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(onPressed: doSpan, child: Text('Hello World!'))
        ),
      ),
    );
  }


}

void doSpan()
{
  BugsnagPerformance.start(apiKey: apiKey, endpoint: Uri.parse( "https://webhook.site/1ddfa7ad-5ce3-4faf-9d2c-9ee3bf4a3d47" ));
  for(var i = 0; i < 200; i++) {
    BugsnagPerformance.startSpan("test " + i.toString()).end();
  }
}