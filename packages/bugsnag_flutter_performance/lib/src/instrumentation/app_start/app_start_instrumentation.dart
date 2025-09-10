import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';
import 'package:bugsnag_flutter_performance/src/span_attributes.dart';
import 'package:flutter/scheduler.dart';

abstract class AppStartInstrumentation {
  void didStartBugsnagPerformance();
  void willExecuteRunApp();
  void didExecuteRunApp();
  void setEnabled(bool enabled);
  BugsnagPerformanceSpan? getOverallSpan();
}

class AppStartInstrumentationImpl implements AppStartInstrumentation {
  final BugsnagPerformanceClient client;

  BugsnagPerformanceSpan? overallSpan;
  BugsnagPerformanceSpan? preRunAppPhaseSpan;
  BugsnagPerformanceSpan? runAppPhaseSpan;
  BugsnagPerformanceSpan? uiInitPhaseSpan;
  var enabled = true;

  AppStartInstrumentationImpl({required this.client});

  @override
  void didStartBugsnagPerformance() {
    if (!enabled) {
      return;
    }
    if (overallSpan != null) {
      return;
    }
    overallSpan = client.startSpan(
      '[AppStart/FlutterInit]',
      attributes: BugsnagPerformanceSpanAttributes(
          category: 'app_start', appStartType: 'FlutterInit'),
    );
    preRunAppPhaseSpan = client.startSpan(
      '[AppStartPhase/pre runApp()]',
      parentContext: overallSpan,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'app_start_phase',
        phase: 'pre runApp()',
        appStartType: 'FlutterInit',
      ),
    );
  }

  @override
  void willExecuteRunApp() {
    if (!enabled) {
      return;
    }
    if (overallSpan == null) {
      return;
    }
    preRunAppPhaseSpan?.end();
    runAppPhaseSpan = client.startSpan(
      '[AppStartPhase/runApp()]',
      parentContext: overallSpan,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'app_start_phase',
        phase: 'runApp()',
        appStartType: 'FlutterInit',
      ),
    );
  }

  @override
  void didExecuteRunApp() {
    if (!enabled) {
      return;
    }
    if (overallSpan == null) {
      return;
    }
    runAppPhaseSpan?.end();
    uiInitPhaseSpan = client.startSpan(
      '[AppStartPhase/UI init]',
      parentContext: overallSpan,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'app_start_phase',
        phase: 'UI init',
        appStartType: 'FlutterInit',
      ),
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      uiInitPhaseSpan?.end();
      overallSpan?.end();
    });
  }

  @override
  void setEnabled(bool enabled) {
    this.enabled = enabled;
    if (!enabled) {
      overallSpan = null;
      preRunAppPhaseSpan = null;
      runAppPhaseSpan = null;
      uiInitPhaseSpan = null;
    }
  }

  @override
  BugsnagPerformanceSpan? getOverallSpan() {
    return overallSpan;
  }
}
