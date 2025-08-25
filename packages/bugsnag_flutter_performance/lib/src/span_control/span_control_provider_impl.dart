import 'dart:ffi';
import '../client.dart';
import 'span_control_provider.dart';
import 'span_control.dart';
import 'span_query.dart';
import 'composite_span_control_provider.dart';
import 'app_start_span_control_provider.dart';

class SpanControlProviderImpl implements SpanControlProvider {
  final BugsnagPerformanceClient _client;
  final CompositeSpanControlProvider _compositeProvider;
  AppStartSpanControlProvider? _appStartProvider;

  static const int internalPriority = 999999;
  static const int highPriority = 100000;
  static const int normalPriority = 50000;
  static const int lowPriority = 0;

  SpanControlProviderImpl(this._client)
      : _compositeProvider = CompositeSpanControlProvider(){
    _initialize();
  }

  void _initialize() {
    _compositeProvider.batchAddProviders((addProvider) {
        _appStartProvider = AppStartSpanControlProvider(
            clientImpl._appStartInstrumentation
        );
        addProvider(_appStartProvider!, internalPriority);
    });
  }

  @override
  R? getSpanControl<R extends SpanControl>(SpanQuery<R> query) {
    return _compositeProvider.getSpanControl<R>(query);
  }

}