import 'package:bugsnag_flutter_performance/src/span_control/span_control.dart';

sealed class SpanType<R> extends SpanQuery<R> {
  const SpanType();
}

// AppStart span type and control interface
class _AppStartSpanType extends SpanType<AppStartSpanControl> {
  const _AppStartSpanType._();
}

abstract class AppStartSpanControl {
  void setType(String? name);
  void clearType();
}

const AppStart = _AppStartSpanType._();

