import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

abstract class NavigationInstrumentation {
  void setEnabled(bool enabled);
  void willShowRoute(
    Route<dynamic>? route,
    String? routeDescription,
  );
}

class NavigationInstrumentationImpl implements NavigationInstrumentation {
  final BugsnagPerformanceClient client;
  late final BugsnagClock clock;

  var _enabled = true;

  NavigationInstrumentationImpl({
    required this.client,
    required this.clock,
  });

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  @override
  void willShowRoute(Route? route, String? routeDescription) {
    if (!_enabled || routeDescription == null) {
      return;
    }
    final startTime = clock.now();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      client
          .startSpan('[Navigation]/$routeDescription', startTime: startTime)
          .end();
    });
  }
}
