import 'dart:io';

import 'package:bugsnag_flutter_performance/src/extensions/resource_attributes.dart';
import 'package:bugsnag_flutter_performance/src/uploader/package_builder.dart';
import 'package:bugsnag_flutter_performance/src/uploader/retry_queue.dart';
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
  Uploader? _uploader;
  SpanBatch? _currentBatch;
  RetryQueue? _retryQueue;
  Sampler? _sampler;
  late final PackageBuilder _packageBuilder;
  late final BugsnagClock _clock;

  BugsnagPerformanceClientImpl() {
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
    _setup();
    await _retryQueue?.flush();
  }

  @override
  BugsnagPerformanceSpan startSpan(String name, {DateTime? startTime}) {
    final span = BugsnagPerformanceSpanImpl(
      name: name,
      startTime: startTime ?? _clock.now(),
      onEnded: (endedSpan) {
        if (_sampler?.sample(endedSpan) ?? true) {
          _currentBatch?.add(endedSpan);
        }
      },
    );
    span.clock = _clock;
    if (configuration != null) {
      _currentBatch ??= SpanBatchImpl();
      _currentBatch?.configure(configuration!);
      _currentBatch?.onBatchFull = _sendBatch;
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
      _retryQueue = FileRetryQueue(_uploader!);
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

  void setBatchSize(int batchSize) {
    configuration?.autoTriggerExportOnBatchSize = batchSize;
  }
}
