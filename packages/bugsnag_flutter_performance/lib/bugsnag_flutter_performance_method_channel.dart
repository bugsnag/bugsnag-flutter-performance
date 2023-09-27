import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bugsnag_flutter_performance_platform_interface.dart';

/// An implementation of [BugsnagFlutterPerformancePlatform] that uses method channels.
class MethodChannelBugsnagFlutterPerformance extends BugsnagFlutterPerformancePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bugsnag_flutter_performance');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
