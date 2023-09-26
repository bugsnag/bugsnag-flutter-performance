import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bugsnag_flutter_performance_method_channel.dart';

abstract class BugsnagFlutterPerformancePlatform extends PlatformInterface {
  /// Constructs a BugsnagFlutterPerformancePlatform.
  BugsnagFlutterPerformancePlatform() : super(token: _token);

  static final Object _token = Object();

  static BugsnagFlutterPerformancePlatform _instance = MethodChannelBugsnagFlutterPerformance();

  /// The default instance of [BugsnagFlutterPerformancePlatform] to use.
  ///
  /// Defaults to [MethodChannelBugsnagFlutterPerformance].
  static BugsnagFlutterPerformancePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BugsnagFlutterPerformancePlatform] when
  /// they register themselves.
  static set instance(BugsnagFlutterPerformancePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
