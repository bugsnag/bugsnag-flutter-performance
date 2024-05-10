import 'package:bugsnag_flutter_performance/src/instrumentation/view_load/view_load_instrumentation_state.dart';
import 'package:flutter/widgets.dart';

typedef MeasuredWidgetCallback = Function(
  ViewLoadInstrumentationState state,
  BuildContext context,
);

class MeasuredWidgetCallbacks {
  MeasuredWidgetCallback? _willBuildCallback;
  MeasuredWidgetCallback? _didBuildCallback;

  void willBuildWidget({
    required ViewLoadInstrumentationState state,
    required BuildContext context,
  }) {
    if (_willBuildCallback != null) {
      _willBuildCallback!(
        state,
        context,
      );
    }
  }

  void didBuildWidget({
    required ViewLoadInstrumentationState state,
    required BuildContext context,
  }) {
    if (_didBuildCallback != null) {
      _didBuildCallback!(
        state,
        context,
      );
    }
  }

  static setup({
    MeasuredWidgetCallback? willBuildCallback,
    MeasuredWidgetCallback? didBuildCallback,
  }) {
    if (willBuildCallback != null) {
      measuredWidgetCallbacks._willBuildCallback = willBuildCallback;
    }
    if (didBuildCallback != null) {
      measuredWidgetCallbacks._didBuildCallback = didBuildCallback;
    }
  }
}

final measuredWidgetCallbacks = MeasuredWidgetCallbacks();
