import 'span_control_provider.dart';
import 'span_control.dart';
import 'span_query.dart';
import 'app_start_span_control.dart';
import '../instrumentation/app_start/app_start_instrumentation.dart';

class AppStartSpanControlProvider implements SpanControlProvider {
  final AppStartInstrumentation _appStartInstrumentation;

  AppStartSpanControlProvider(this._appStartInstrumentation);

  @override
  R? getSpanControl<R extends SpanControl>(SpanQuery<R> query) {
    if (query.resultType == AppStartSpanControl) {
      final control = _getAppStartControl();
      return control as R?;
    }
    return null;
  }

  AppStartSpanControl? _getAppStartControl() {
    final overallSpan = _appStartInstrumentation.getOverallSpan();

    if (overallSpan != null && overallSpan.isOpen()) {
      return AppStartSpanControlImpl(overallSpan);
    }

    return null;
  }
}
