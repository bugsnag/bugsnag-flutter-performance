import 'dart:async';
import 'dart:io';

import 'package:bugsnag_bridge/bugsnag_bridge.dart';
import 'package:bugsnag_flutter_performance/src/extensions/bugsnag_lifecycle_listener.dart';
import 'package:bugsnag_flutter_performance/src/extensions/resource_attributes.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/app_start/app_start_instrumentation.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/bugsnag_performance_navigator_observer_callbacks.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_instrumentation.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/view_load/measured_widget_callbacks.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/view_load/view_load_instrumentation.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'bugsnag_network_request_info.dart';
import 'configuration.dart';
import 'span.dart';

String _defaultEndpoint(String? apiKey) =>
    'https://${apiKey != null ? '$apiKey.' : ''}otlp.bugsnag.com/v1/traces';

abstract class BugsnagPerformanceClient {
  Future<void> start({
    String? apiKey,
    Uri? endpoint,
    BugsnagNetworkRequestInfo? Function(BugsnagNetworkRequestInfo)?
        networkRequestCallback,
    String? releaseStage,
    List<String>? enabledReleaseStages,
    String? serviceName,
    String? appVersion,
  });

  Future<void> measureRunApp(FutureOr<void> Function() runApp);

  BugsnagPerformanceSpan startSpan(
    String name, {
    DateTime? startTime,
    BugsnagPerformanceSpanContext? parentContext,
    bool? makeCurrentContext = true,
    BugsnagPerformanceSpanAttributes? attributes,
  });

  BugsnagPerformanceSpan startNetworkSpan(String url, String httpMethod);

  BugsnagPerformanceSpan startNavigationSpan({
    required String routeName,
    required String triggeredBy,
    String? navigatorName,
    String? previousRoute,
    BugsnagPerformanceSpanContext? parentContext,
    DateTime? startTime,
  });

  BugsnagPerformanceSpan startViewLoadSpan({
    required String viewName,
    BugsnagPerformanceSpanContext? parentContext,
    DateTime? startTime,
  });

  BugsnagPerformanceSpan startViewLoadPhaseSpan({
    required String viewName,
    required String phase,
    BugsnagPerformanceSpanContext? parentContext,
    DateTime? startTime,
  });

  BugsnagPerformanceSpanContext? getCurrentSpanContext();

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
  late final BugsnagLifecycleListener? _lifecycleListener;
  final Map<String, dynamic> _initialExtraConfig = {};
  late final SamplingProbabilityStore _probabilityStore;
  late final AppStartInstrumentation _appStartInstrumentation;
  late final NavigationInstrumentation _navigationInstrumentation;
  late final ViewLoadInstrumentation _viewLoadInstrumentation;
  final Map<String, BugsnagPerformanceSpan> _networkSpans = {};
  BugsnagNetworkRequestInfo? Function(BugsnagNetworkRequestInfo)?
      _networkRequestCallback;
  final Map<SpanId, BugsnagPerformanceSpan> _potentiallyOpenSpans = {};
  final spanContextStackExpando = Expando<BugsnagPerformanceSpanContextStack>();

  BugsnagPerformanceClientImpl({BugsnagLifecycleListener? lifecycleListener}) {
    retryQueueBuilder = RetryQueueBuilderImpl();
    BugsnagClockImpl.ensureInitialized();
    _packageBuilder = PackageBuilderImpl(
      attributesProvider: ResourceAttributesProviderImpl(),
    );
    _clock = BugsnagClockImpl.instance;
    _appStartInstrumentation = AppStartInstrumentationImpl(client: this);
    BugsnagLifecycleListenerImpl.ensureInitialized();
    _lifecycleListener =
        lifecycleListener ?? BugsnagLifecycleListenerImpl.instance;
    _navigationInstrumentation = NavigationInstrumentationImpl(
      client: this,
      clock: _clock,
    );
    _viewLoadInstrumentation = ViewLoadInstrumentationImpl(
      client: this,
      clock: _clock,
    );
  }

  @override
  Future<void> start({
    String? apiKey,
    Uri? endpoint,
    BugsnagNetworkRequestInfo? Function(BugsnagNetworkRequestInfo)?
        networkRequestCallback,
    String? releaseStage,
    List<String>? enabledReleaseStages,
    List<RegExp>? tracePropagationUrls,
    String? serviceName,
    String? appVersion,
    double? samplingProbability,
  }) async {
    if (!_isEnabledOnCurrentPlatform()) {
      _appStartInstrumentation.setEnabled(false);
      _navigationInstrumentation.setEnabled(false);
      return;
    }
    WidgetsFlutterBinding.ensureInitialized();
    _networkRequestCallback = networkRequestCallback;
    configuration = BugsnagPerformanceConfiguration(
      apiKey: apiKey,
      endpoint: endpoint ?? Uri.parse(_defaultEndpoint(apiKey)),
      releaseStage: releaseStage ?? getDeploymentEnvironment(),
      enabledReleaseStages: enabledReleaseStages,
      tracePropagationUrls: tracePropagationUrls,
      serviceName: serviceName,
      appVersion: appVersion,
      samplingProbability: samplingProbability,
    );
    _packageBuilder.setConfig(configuration);
    _initialExtraConfig.forEach((key, value) {
      setExtraConfig(key, value);
    });
    _appStartInstrumentation
        .setEnabled(configuration?.instrumentAppStart ?? false);
    _navigationInstrumentation
        .setEnabled(configuration?.instrumentNavigation ?? false);
    _viewLoadInstrumentation
        .setEnabled(configuration?.instrumentViewLoad ?? false);
    if (samplingProbability != null) {
      _probabilityStore = FixedSamplingProbabilityStore(samplingProbability);
    } else {
      _probabilityStore = SamplingProbabilityStoreImpl(_clock);
    }
    _setup(
      shouldUpdateSamplingProbabilityPeriodically: samplingProbability == null,
    );
    _appStartInstrumentation.didStartBugsnagPerformance();
    await _retryQueue?.flush();
    _lifecycleListener?.startObserving(onAppBackgrounded: _onAppBackgrounded);
  }

  String getDeploymentEnvironment() {
    final environment = Platform.environment['DEPLOYMENT_ENVIRONMENT'];
    return environment ?? 'development';
  }

  @override
  BugsnagPerformanceSpan startSpan(
    String name, {
    DateTime? startTime,
    BugsnagPerformanceSpanContext? parentContext,
    bool? makeCurrentContext = true,
    BugsnagPerformanceSpanAttributes? attributes,
  }) {
    final BugsnagPerformanceSpanContext? parent =
        parentContext != BugsnagPerformanceSpanContext.invalid
            ? parentContext ?? getCurrentSpanContext()
            : null;

    final span = BugsnagPerformanceSpanImpl(
      name: name,
      startTime: startTime ?? _clock.now(),
      onEnded: (endedSpan) async {
        await _updateSamplingProbabilityIfNeeded();
        if (await _sampler?.sample(endedSpan) ?? true) {
          _currentBatch?.add(endedSpan);
        }
        _potentiallyOpenSpans.remove(endedSpan.spanId);
      },
      onCanceled: (canceledSpan) {
        _potentiallyOpenSpans.remove(canceledSpan.spanId);
      },
      parentSpanId: parent?.spanId,
      traceId: parent?.traceId,
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
    _potentiallyOpenSpans[span.spanId] = span;
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

  void _setup({
    required bool shouldUpdateSamplingProbabilityPeriodically,
  }) {
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
    if (shouldUpdateSamplingProbabilityPeriodically) {
      Timer.periodic(
          Duration(milliseconds: configuration!.probabilityRequestsPause),
          (timer) {
        _updateSamplingProbabilityIfNeeded(force: true);
      });
    }
    BugsnagPerformanceNavigatorObserverCallbacks.setup(
      didPushNewRouteCallback: _navigationInstrumentation.didPushNewRoute,
      didReplaceRouteCallback: _navigationInstrumentation.didReplaceRoute,
      didRemoveRouteCallback: _navigationInstrumentation.didRemoveRoute,
      didPopRouteCallback: _navigationInstrumentation.didPopRoute,
    );
    MeasuredWidgetCallbacks.setup(
      willBuildCallback: _viewLoadInstrumentation.willBuildView,
      didBuildCallback: _viewLoadInstrumentation.didBuildView,
    );
    HttpHeadersProviderCallbacks.setup(
      httpRequestHeadersCallback: _requestHeaders,
    );
    BugsnagContextProviderCallbacks.setup(
      currentTraceContextCallback: _currentTraceContext,
    );
  }

  void _sendBatch(SpanBatch batch) async {
    if (!configuration!.releaseStageEnabled()) {
      batch.drain();
      return;
    }
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
    } else if (result == RequestResult.success) {
      await _retryQueue?.flush();
    }
  }

  Future<void> _updateSamplingProbabilityIfNeeded({
    bool force = false,
  }) async {
    if (configuration != null && configuration!.samplingProbability != null) {
      return;
    }
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
    var stack = spanContextStackExpando[Zone.current];
    if (stack == null) {
      stack = BugsnagPerformanceSpanContextStackImpl();
      spanContextStackExpando[Zone.current] = stack;
    }

    return stack;
  }

  void _addContext(BugsnagPerformanceSpanContext newContext) {
    var stack = _getContextStack();
    if (stack != null && stack.getCurrentContext() != newContext) {
      stack.pushContext(newContext);
    }
  }

  @override
  BugsnagPerformanceSpanContext? getCurrentSpanContext() {
    return _getContextStack()?.getCurrentContext();
  }

  @override
  BugsnagPerformanceSpan startNetworkSpan(String url, String httpMethod) {
    return startSpan("HTTP/$httpMethod",
        makeCurrentContext: false,
        attributes: BugsnagPerformanceSpanAttributes(
            category: "network", httpMethod: httpMethod, url: url));
  }

  @override
  BugsnagPerformanceSpan startNavigationSpan({
    required String routeName,
    required String triggeredBy,
    String? navigatorName,
    String? previousRoute,
    BugsnagPerformanceSpanContext? parentContext,
    DateTime? startTime,
  }) {
    final name = navigatorName != null
        ? '[Navigation]$navigatorName/$routeName'
        : '[Navigation]$routeName';
    return startSpan(
      name,
      parentContext: parentContext,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'navigation',
        additionalAttributes: {
          'bugsnag.navigation.route': routeName,
          'bugsnag.navigation.navigator': navigatorName,
          'bugsnag.navigation.triggered_by': triggeredBy,
          'bugsnag.navigation.previous_route': previousRoute,
        },
      ),
    );
  }

  @override
  BugsnagPerformanceSpan startViewLoadSpan({
    required String viewName,
    BugsnagPerformanceSpanContext? parentContext,
    DateTime? startTime,
  }) {
    return startSpan(
      '[ViewLoad]FlutterWidget/$viewName',
      parentContext: parentContext,
      startTime: startTime,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'view_load',
        additionalAttributes: {
          'bugsnag.view.type': 'FlutterWidget',
          'bugsnag.view.name': viewName,
        },
      ),
    );
  }

  @override
  BugsnagPerformanceSpan startViewLoadPhaseSpan({
    required String viewName,
    required String phase,
    BugsnagPerformanceSpanContext? parentContext,
    DateTime? startTime,
  }) {
    return startSpan(
      '[ViewLoadPhase]FlutterWidget/$viewName/$phase',
      parentContext: parentContext,
      startTime: startTime,
      attributes: BugsnagPerformanceSpanAttributes(
        category: 'view_load_phase',
        phase: phase,
        additionalAttributes: {
          'bugsnag.view.type': 'FlutterWidget',
          'bugsnag.view.name': viewName,
        },
      ),
    );
  }

  @override
  dynamic networkInstrumentation(dynamic data) {
    if (data is! Map<String, dynamic>) return true;
    String status = data["status"];
    String requestId = data["request_id"];

    if (status == "started") {
      String url = data["url"];
      final String method = data["http_method"];
      if (_networkRequestCallback != null) {
        BugsnagNetworkRequestInfo requestInfo =
            BugsnagNetworkRequestInfo(url: url, type: method);
        BugsnagNetworkRequestInfo? modifiedRequestInfo =
            _networkRequestCallback!(requestInfo);
        if (modifiedRequestInfo?.url == null ||
            modifiedRequestInfo!.url!.isEmpty) {
          return false;
        }
        url = modifiedRequestInfo.url!;
      }
      final span = startNetworkSpan(url, method);
      _networkSpans[requestId] = span;
    } else if (status == "complete") {
      final span = _networkSpans[requestId];
      if (span != null) {
        span.end(
          httpStatusCode: data["status_code"],
          requestContentLength: data["request_content_length"],
          responseContentLength: data["response_content_length"],
        );
        _networkSpans.remove(requestId);
      }
    } else {
      _networkSpans.remove(requestId);
    }
    return true;
  }

  Future<Map<String, String>?> _requestHeaders(
    String url,
    String requestId,
  ) async {
    if (!_shouldAddTraceHeader(url)) {
      return Future.value(null);
    }
    Map<String, String> result = {};
    final span = _networkSpans[requestId] ?? getCurrentSpanContext();
    if (span != null && span is BugsnagPerformanceSpanImpl) {
      await _sampler?.sample(span);
      result['traceparent'] = _buildTraceparentHeader(
        traceId: span.encodedTraceId,
        parentSpanId: span.encodedSpanId,
        sampled: span.isSampled,
      );
    }
    return result;
  }

  bool _shouldAddTraceHeader(String url) {
    final tracePropagationUrls = configuration?.tracePropagationUrls;
    if (tracePropagationUrls != null && tracePropagationUrls.isNotEmpty) {
      return tracePropagationUrls.any((regex) => regex.hasMatch(url));
    }
    return true;
  }

  String _buildTraceparentHeader({
    required String traceId,
    required String parentSpanId,
    required bool sampled,
  }) {
    return '00-$traceId-$parentSpanId-${sampled ? '01' : '00'}';
  }

  BugsnagTraceContext? _currentTraceContext() {
    final context = spanContextStackExpando[Zone.current]?.getCurrentContext();
    if (context != null && context is BugsnagPerformanceSpan) {
      return BugsnagTraceContext(
        spanId: context.encodedSpanId,
        traceId: context.encodedTraceId,
      );
    }
    return null;
  }

  void _onAppBackgrounded() {
    var keys = List<SpanId>.from(_potentiallyOpenSpans.keys);
    for (var key in keys) {
      _potentiallyOpenSpans[key]?.end(cancelled: true);
      _potentiallyOpenSpans.remove(key);
    }
    _potentiallyOpenSpans.clear();
  }

  bool _isEnabledOnCurrentPlatform() {
    return !kIsWeb;
  }
}
