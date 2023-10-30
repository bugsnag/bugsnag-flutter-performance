import 'dart:io';

import 'package:bugsnag_flutter_performance/src/uploader/package_builder.dart';
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
  late final PackageBuilder _packageBuilder;
  late final BugsnagClock _clock;

  BugsnagPerformanceClientImpl() {
    BugsnagClockImpl.ensureInitialized();
    _packageBuilder = PackageBuilderImpl();
    _clock = BugsnagClockImpl.instance;
  }

  @override
  Future<void> start({String? apiKey, Uri? endpoint}) async {
    configuration = BugsnagPerformanceConfiguration(
      apiKey: apiKey,
      endpoint: endpoint ?? Uri.parse(_defaultEndpoint),
    );
    _setup();
  }

  @override
  BugsnagPerformanceSpan startSpan(String name, {DateTime? startTime}) {
    final span = BugsnagPerformanceSpanImpl(
      name: name,
      startTime: startTime ?? _clock.now(),
      onEnded: (endedSpan) {
        _currentBatch?.add(endedSpan);
      },
    );
    span.clock = _clock;
    if (configuration != null) {
      _currentBatch ??= SpanBatchImpl();
      _currentBatch?.configure(configuration!);
      _currentBatch?.onBatchFull = _sendBatch;
      _currentBatch?.add(span);
    }
    return span;
  }

  void _setup() {
    if (configuration?.endpoint != null && configuration?.apiKey != null) {
      _uploader = UploaderImpl(
        apiKey: configuration!.apiKey!,
        url: configuration!.endpoint!,
        client: UploaderClientImpl(httpClient: HttpClient()),
        clock: _clock,
      );
    }
  }

  void _sendBatch(SpanBatch batch) {
    final spans = batch.drain();
    if (spans.isEmpty) {
      return;
    }
    final package = _packageBuilder.build(spans);
    _uploader?.upload(package: package);
  }

  void setBatchSize(int batchSize) {
    configuration?.autoTriggerExportOnBatchSize = batchSize;
  }
}
