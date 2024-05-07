import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/widget_instrumentation_node.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/view_load/view_load_instrumentation_state.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

abstract class ViewLoadInstrumentation {
  void setEnabled(bool enabled);
  void willBuildView(
    ViewLoadInstrumentationState state,
    BuildContext context,
  );
  void didBuildView(
    ViewLoadInstrumentationState state,
    BuildContext context,
  );
}

class ViewLoadInstrumentationImpl implements ViewLoadInstrumentation {
  final BugsnagPerformanceClient client;
  final BugsnagClock clock;

  var _enabled = true;

  ViewLoadInstrumentationImpl({
    required this.client,
    required this.clock,
  });

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  @override
  void willBuildView(
    ViewLoadInstrumentationState state,
    BuildContext context,
  ) {
    if (!_enabled || state.viewLoadSpan != null) {
      return;
    }
    final viewLoadSpan = client.startViewLoadSpan(
      viewName: state.name,
    );
    state.viewLoadSpan = viewLoadSpan;
    state.buildingSpan = client.startViewLoadPhaseSpan(
      viewName: state.name,
      phase: 'building',
      parentContext: viewLoadSpan,
    );
  }

  @override
  void didBuildView(
    ViewLoadInstrumentationState state,
    BuildContext context,
  ) {
    final viewLoadSpan = state.viewLoadSpan;
    if (!_enabled ||
        viewLoadSpan == null ||
        state.buildingSpan == null ||
        !state.buildingSpan!.isOpen() ||
        state.appearingSpan != null) {
      return;
    }
    state.buildingSpan?.end();
    state.appearingSpan = client.startViewLoadPhaseSpan(
      viewName: state.name,
      phase: 'appearing',
      parentContext: viewLoadSpan,
    );
    final node = WidgetInstrumentationNode.of(context);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      state.appearingSpan?.end();
      if (node.isLoading()) {
        state.loadingSpan = client.startViewLoadPhaseSpan(
          viewName: state.name,
          phase: 'loading',
          parentContext: viewLoadSpan,
        );
        node.addDidFinishLoadingCallback(() {
          state.loadingSpan?.end();
          viewLoadSpan.end();
        });
      } else {
        viewLoadSpan.end();
      }
    });
  }
}
