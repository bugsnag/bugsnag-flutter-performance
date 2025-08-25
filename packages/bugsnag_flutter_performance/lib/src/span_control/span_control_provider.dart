import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:bugsnag_flutter_performance/src/span_control/span_control.dart';

abstract class SpanControlProvider {
  R? getSpanControl<R>(SpanQuery<R> key);
}

class SpanControlProviderImpl implements SpanControlProvider {
  final BugsnagPerformanceClientImpl _client;

  SpanControlProviderImpl(this._client);

  @override
  R? getSpanControl<R>(SpanQuery<R> key) {
    return switch (key.runtimeType) {
      Type() when key is AppStartSpanControl => _getAppStartControl() as R?,
      _ => null,
    };
  }

  AppStartSpanControl? _getAppStartControl() {
    // Implementation would go here when we add AppStart support
    return null; // Placeholder
  }
}