import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:bugsnag_flutter_performance/src/span_attributes.dart';
import 'package:flutter/scheduler.dart';

abstract class AppStartInstrumentation {
  void didStartBugsnagPerformance();
  void willExecuteRunApp();
  void didExecuteRunApp();
}

class AppStartInstrumentationImpl implements AppStartInstrumentation {
  final BugsnagPerformanceClient client;

  BugsnagPerformanceSpan? flutterInitSpan;
  BugsnagPerformanceSpan? preRunAppPhaseSpan;
  BugsnagPerformanceSpan? runAppPhaseSpan;
  BugsnagPerformanceSpan? uiInitPhaseSpan;

  AppStartInstrumentationImpl({required this.client});

  @override
  void didStartBugsnagPerformance() {
    if (flutterInitSpan != null) {
      return;
    }
    flutterInitSpan = client.startSpan(
      '[AppStart/FlutterInit]',
      attributes: BugsnagPerformanceSpanAttributes(category: 'app_start'),
    );
    preRunAppPhaseSpan = client.startSpan(
      '[AppStartPhase/pre runApp()]',
      parentContext: flutterInitSpan,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'app_start_phase',
        phase: 'pre runApp()',
      ),
    );
  }

  @override
  void willExecuteRunApp() {
    if (flutterInitSpan == null) {
      return;
    }
    preRunAppPhaseSpan?.end();
    runAppPhaseSpan = client.startSpan(
      '[AppStartPhase/runApp()]',
      parentContext: flutterInitSpan,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'app_start_phase',
        phase: 'runApp()',
      ),
    );
  }

  @override
  void didExecuteRunApp() {
    if (flutterInitSpan == null) {
      return;
    }
    runAppPhaseSpan?.end();
    uiInitPhaseSpan = client.startSpan(
      '[AppStartPhase/UI init]',
      parentContext: flutterInitSpan,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'app_start_phase',
        phase: 'UI init',
      ),
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      uiInitPhaseSpan?.end();
      flutterInitSpan?.end();
    });
  }
}
