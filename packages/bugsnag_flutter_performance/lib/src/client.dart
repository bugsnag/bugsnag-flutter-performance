import 'dart:async';
import 'dart:io';

import 'package:bugsnag_flutter_performance/src/extensions/resource_attributes.dart';
import 'package:bugsnag_flutter_performance/src/span_context.dart';
import 'package:bugsnag_flutter_performance/src/uploader/package_builder.dart';
import 'package:bugsnag_flutter_performance/src/uploader/retry_queue.dart';
import 'package:bugsnag_flutter_performance/src/uploader/retry_queue_builder.dart';
import 'package:bugsnag_flutter_performance/src/uploader/sampler.dart';
import 'package:bugsnag_flutter_performance/src/uploader/span_batch.dart';
import 'package:bugsnag_flutter_performance/src/uploader/uploader.dart';
import 'package:bugsnag_flutter_performance/src/uploader/uploader_client.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';

import 'configuration.dart';
import 'span.dart';

const _defaultEndpoint = 'https://otlp.bugsnag.com/v1/traces';

abstract class BugsnagPerformanceClient {
  Future<void> start({String? apiKey, Uri? endpoint});
  BugsnagPerformanceSpan startSpan(String name, {DateTime? startTime});
}

class BugsnagPerformanceClientImpl implements BugsnagPerformanceClient {
  BugsnagPerformanceConfiguration? configuration;
  late RetryQueueBuilder retryQueueBuilder;
  Uploader? _uploader;
  SpanBatch? _currentBatch;
  RetryQueue? _retryQueue;
  Sampler? _sampler;
  late final PackageBuilder _packageBuilder;
  late final BugsnagClock _clock;
  final Map<String, dynamic> _initialExtraConfig = {};
  final Map<int, BugsnagPerformanceSpanContextStack> _zoneContextStacks = {};

  BugsnagPerformanceClientImpl() {
    retryQueueBuilder = RetryQueueBuilderImpl();
    BugsnagClockImpl.ensureInitialized();
    _packageBuilder = PackageBuilderImpl(
      attributesProvider: ResourceAttributesProviderImpl(),
    );
    _clock = BugsnagClockImpl.instance;
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
    _setup();
    await _retryQueue?.flush();
  }

  @override
  BugsnagPerformanceSpan startSpan(String name,
      {DateTime? startTime,
      BugsnagPerformanceSpanContext? parentContext,
      bool? makeCurrentContext = true}) {
    if (parentContext != null) {
      _addContext(parentContext);
    }
    final parent = parentContext ?? _getCurrentContext();

    final span = BugsnagPerformanceSpanImpl(
        name: name,
        startTime: startTime ?? _clock.now(),
        onEnded: (endedSpan) {
          if (_sampler?.sample(endedSpan) ?? true) {
            _currentBatch?.add(endedSpan);
          }
        },
        parentSpanId: parent?.spanId);
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

  void _setup() {
    _sampler = SamplerImpl();
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
  }

  void _sendBatch(SpanBatch batch) async {
    var spans = batch.drain();
    if (_sampler != null) {
      spans = _sampler!.sampled(spans);
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
}
