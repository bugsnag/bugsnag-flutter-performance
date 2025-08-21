import 'package:bugsnag_flutter_performance/src/span.dart';

abstract class AppStartSpanControl {
  void setType(String? name);
  void clearType();
}
abstract class SpanQuery<R> {}
class AppStartQuery extends SpanQuery<AppStartSpanControl> {
  AppStartQuery();
}
AppStartQuery appStart = AppStartQuery();
class AppStartSpanControlImpl implements AppStartSpanControl {

  final BugsnagPerformanceSpan span;

  AppStartSpanControlImpl(this.span);

  @override
  void setType(String? name) {
    if (span is! BugsnagPerformanceSpanImpl || !span.isOpen()) return;
    final impl = span as BugsnagPerformanceSpanImpl;
    impl.attributes.setAttribute('bugsnag.app_start.name', name);
    impl.name = '[AppStart/FlutterInit]${name ?? ""}';
  }

  @override
  void clearType() {
    setType(null);
  }
}

