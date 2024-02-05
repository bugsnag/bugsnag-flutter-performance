import 'dart:async';
import 'dart:io';

import 'package:bugsnag_flutter_performance/src/extensions/resource_attributes.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/app_start_instrumentation.dart';
import 'package:bugsnag_flutter_performance/src/span_attributes.dart';
import 'package:bugsnag_flutter_performance/src/span_context.dart';
import 'package:bugsnag_flutter_performance/src/uploader/package_builder.dart';
import 'package:bugsnag_flutter_performance/src/uploader/retry_queue.dart';
import 'package:bugsnag_flutter_performance/src/uploader/retry_queue_builder.dart';
import 'package:bugsnag_flutter_performance/src/uploader/sampler.dart';
import 'package:bugsnag_flutter_performance/src/uploader/sampling_probability_store.dart';
import 'package:bugsnag_flutter_performance/src/uploader/span_batch.dart';
import 'package:bugsnag_flutter_performance/src/uploader/uploader.dart';
import 'package:bugsnag_flutter_performance/src/uploader/uploader_client.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'configuration.dart';
import 'span.dart';

const _defaultEndpoint = 'https://otlp.bugsnag.com/v1/traces';

abstract class BugsnagPerformanceClient {
  Future<void> start({String? apiKey, Uri? endpoint});

  Future<void> measureRunApp(FutureOr<void> Function() runApp);
  BugsnagPerformanceSpan startSpan(
    String name, {
    DateTime? startTime,
    BugsnagPerformanceSpanContext? parentContext,
    bool? makeCurrentContext = true,
    BugsnagPerformanceSpanAttributes? attributes,
  });
  dynamic networkInstrumentation(dynamic);
}

class BugsnagPerformanceClientImpl implements BugsnagPerformanceClient {
  BugsnagPerformanceConfiguration? configuration;
  late RetryQueueBuilder retryQueueBuilder;
  Uploader? _uploader;
  SpanBatch? _currentBatch;
  RetryQueue? _retryQueue;
  Sampler? _sampler;
  DateTime? _lastSamplingProbabilityRefreshDate;
  late final PackageBuilder _packageBuilder;
  late final BugsnagClock _clock;
  final Map<String, dynamic> _initialExtraConfig = {};
  late final SamplingProbabilityStore _probabilityStore;
  late final AppStartInstrumentation _appStartInstrumentation;
  final Map<int, BugsnagPerformanceSpanContextStack> _zoneContextStacks = {};
  String? currentConnectionType;

  BugsnagPerformanceClientImpl() {
    retryQueueBuilder = RetryQueueBuilderImpl();
    BugsnagClockImpl.ensureInitialized();
    _packageBuilder = PackageBuilderImpl(
      attributesProvider: ResourceAttributesProviderImpl(),
    );
    _clock = BugsnagClockImpl.instance;
    _probabilityStore = SamplingProbabilityStoreImpl(_clock);
    _appStartInstrumentation = AppStartInstrumentationImpl(client: this);
    checkInitialConnectivity();
    listenForConnectivityChanges();
  }

  void checkInitialConnectivity() async
  {
    final connectivityResult = await (Connectivity().checkConnectivity());
    handleConnectivityResult(connectivityResult);
  }

  void listenForConnectivityChanges() {
    Connectivity().onConnectivityChanged.listen(handleConnectivityResult);
  }

  void handleConnectivityResult(ConnectivityResult result)
  {
    if (result == ConnectivityResult.mobile) {
      currentConnectionType = 'cell';
    } else if (result == ConnectivityResult.wifi) {
      currentConnectionType = 'wifi';
    } else {
      currentConnectionType = 'unavailable';
    }
  }

  @override
  Future<void> start({String? apiKey, Uri? endpoint}) async {
    configuration = BugsnagPerformanceConfiguration(
      apiKey: apiKey,
      endpoint: endpoint ?? Uri.parse(_defaultEndpoint),
    );
    _initialExtraConfig.forEach((key, value) {
      setExtraConfig(key, value);
    });
    _appStartInstrumentation
        .setEnabled(configuration?.instrumentAppStart ?? false);
    _setup();
    _appStartInstrumentation.didStartBugsnagPerformance();
    await _retryQueue?.flush();
  }

  @override
  BugsnagPerformanceSpan startSpan(
    String name, {
    DateTime? startTime,
    BugsnagPerformanceSpanContext? parentContext,
    bool? makeCurrentContext = true,
    BugsnagPerformanceSpanAttributes? attributes,
  }) {
    if (parentContext != null) {
      _addContext(parentContext);
    }

    final parent = parentContext ?? _getCurrentContext();

    final span = BugsnagPerformanceSpanImpl(
      name: name,
      startTime: startTime ?? _clock.now(),
      onEnded: (endedSpan) async {
        await _updateSamplingProbabilityIfNeeded();
        if (await _sampler?.sample(endedSpan) ?? true) {
          _currentBatch?.add(endedSpan);
        }
      },
      parentSpanId: parent?.spanId,
      attributes: attributes,
    );
    span.clock = _clock;
    if (configuration != null) {
      _currentBatch ??= SpanBatchImpl();
      _currentBatch?.configure(configuration!);
      _currentBatch?.onBatchFull = _sendBatch;
    }

    if (makeCurrentContext == true) {
      _addContext(span);
    }

    return span;
  }

  @override
  Future<void> measureRunApp(FutureOr<void> Function() runApp) async {
    _appStartInstrumentation.willExecuteRunApp();
    try {
      await runApp();
    } finally {
      _appStartInstrumentation.didExecuteRunApp();
    }
  }

  void _setup() {
    _sampler = SamplerImpl(
      configuration: configuration!,
      probabilityStore: _probabilityStore,
      clock: _clock,
    );
    if (configuration?.endpoint != null && configuration?.apiKey != null) {
      _uploader = UploaderImpl(
        apiKey: configuration!.apiKey!,
        url: configuration!.endpoint!,
        client: UploaderClientImpl(httpClient: HttpClient()),
        clock: _clock,
        sampler: _sampler!,
      );
      _retryQueue = retryQueueBuilder.build(_uploader!);
    }
    Timer.periodic(
        Duration(milliseconds: configuration!.probabilityRequestsPause),
        (timer) {
      _updateSamplingProbabilityIfNeeded(force: true);
    });
  }

  void _sendBatch(SpanBatch batch) async {
    await _updateSamplingProbabilityIfNeeded();
    var spans = batch.drain();
    if (_sampler != null) {
      spans = await _sampler!.sampled(spans);
    }
    if (spans.isEmpty) {
      return;
    }
    final package = await _packageBuilder.build(spans);
    final result = await _uploader?.upload(package: package);
    if (result == RequestResult.retriableFailure) {
      _retryQueue?.enqueue(headers: package.headers, body: package.payload);
    }
  }

  Future<void> _updateSamplingProbabilityIfNeeded({
    bool force = false,
  }) async {
    if (await _sampler?.hasValidSamplingProbabilityValue() ?? true) {
      return;
    }
    if (!_canSendSamplingProbabilityRequest() && !force) {
      return;
    }
    await _sendSamplingProbabilityRequest();
  }

  bool _canSendSamplingProbabilityRequest() {
    if (_lastSamplingProbabilityRefreshDate == null) {
      return true;
    }
    if (configuration == null) {
      return false;
    }
    return configuration!.probabilityRequestsPause >=
        _clock
            .now()
            .difference(_lastSamplingProbabilityRefreshDate!)
            .inMilliseconds;
  }

  Future<void> _sendSamplingProbabilityRequest() async {
    _lastSamplingProbabilityRefreshDate = _clock.now();
    final package = await _packageBuilder.buildEmptyPackage();
    await _uploader?.upload(package: package);
  }

  void setExtraConfig(String key, dynamic value) {
    if (configuration == null) {
      _initialExtraConfig[key] = value;
    } else {
      configuration?.applyExtraConfig(key, value);
    }
  }

  BugsnagPerformanceSpanContextStack? _getContextStack() {
    if (_zoneContextStacks.containsKey(Zone.current.hashCode)) {
      return _zoneContextStacks[Zone.current.hashCode];
    } else {
      _zoneContextStacks[Zone.current.hashCode] =
          BugsnagPerformanceSpanContextStackImpl();
      return _zoneContextStacks[Zone.current.hashCode];
    }
  }

  void _addContext(BugsnagPerformanceSpanContext newContext) {
    var stack = _getContextStack();
    if (stack?.getCurrentContext() != newContext) {
      _getContextStack()?.pushContext(newContext);
    }
  }

  BugsnagPerformanceSpanContext? _getCurrentContext() {
    return _getContextStack()?.getCurrentContext();
  }



  Map<String, BugsnagPerformanceSpan> _networkSpans = {};

  @override
  dynamic networkInstrumentation(dynamic data) {

    print("networkInstrumentation: $data");

    if (data is Map<String, dynamic>) {

      String status = data["status"];

      if (status == "start") {

        var span = startSpan(data["name"]);
        _networkSpans[data["id"]] = span;

      } else if (status == "complete") {

        var span = _networkSpans[data["id"]];
        if (span != null) {
          span.end( connectionType: currentConnectionType,
            url: data["url"],
            httpMethod: data["method"],
            httpStatusCode: data["status_code"],
            requestContentLength: data["response_content_length"],
            responseContentLength: data["request_content_length"]);
        }
      }else{
        // TODO cancel span

      }
    }
    return true;
  }
}
