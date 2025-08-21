import 'package:bugsnag_flutter_performance/src/span.dart';

// Constants for app start span
const String _appStartAttributeName = 'bugsnag.app_start.name';
const String _appStartSpanPrefix = '[AppStart/FlutterInit]';

abstract class AppStartSpanControl {
  void setType(String? name);
  void clearType();
}
abstract class SpanQuery<R> {}
class AppStartQuery extends SpanQuery<AppStartSpanControl> {
  AppStartQuery();
}
class AppStartSpanControlImpl implements AppStartSpanControl {

  final BugsnagPerformanceSpan span;

  AppStartSpanControlImpl(this.span);

  @override
  void setType(String? name) {
    if (span is! BugsnagPerformanceSpanImpl || !span.isOpen()) return;
    final impl = span as BugsnagPerformanceSpanImpl;
    impl.attributes.setAttribute(_appStartAttributeName, name);
    impl.name = '$_appStartSpanPrefix${name ?? ""}';
  }

  @override
  void clearType() {
    setType(null);
  }
}

AppStartQuery appStart = AppStartQuery();
