import 'package:flutter_test/flutter_test.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance_platform_interface.dart';
import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBugsnagFlutterPerformancePlatform
    with MockPlatformInterfaceMixin
    implements BugsnagFlutterPerformancePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BugsnagFlutterPerformancePlatform initialPlatform = BugsnagFlutterPerformancePlatform.instance;

  test('$MethodChannelBugsnagFlutterPerformance is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBugsnagFlutterPerformance>());
  });

  test('getPlatformVersion', () async {
    BugsnagFlutterPerformance bugsnagFlutterPerformancePlugin = BugsnagFlutterPerformance();
    MockBugsnagFlutterPerformancePlatform fakePlatform = MockBugsnagFlutterPerformancePlatform();
    BugsnagFlutterPerformancePlatform.instance = fakePlatform;

    expect(await bugsnagFlutterPerformancePlugin.getPlatformVersion(), '42');
  });
}
