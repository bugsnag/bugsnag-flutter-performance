import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelBugsnagFlutterPerformance platform = MethodChannelBugsnagFlutterPerformance();
  const MethodChannel channel = MethodChannel('bugsnag_flutter_performance');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
