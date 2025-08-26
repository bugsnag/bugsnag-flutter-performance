import 'span_control.dart';
import '../span.dart';

abstract class AppStartSpanControl implements SpanControl {
  void setType(String? type);
  void clearType();
}

class AppStartSpanControlImpl implements AppStartSpanControl {
  final BugsnagPerformanceSpan _overallSpan;

  AppStartSpanControlImpl(this._overallSpan);

  @override
  void setType(String? type) {
    if (_overallSpan.isOpen()) {
      _overallSpan.setAttribute('bugsnag.app_start.type', type);
      _overallSpan
          .updateName(_overallSpan.name + (type != null ? '($type)' : ''));
    }
  }

  @override
  void clearType() {
    setType(null);
  }
}
