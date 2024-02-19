import 'dart:typed_data';

import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:bugsnag_flutter_performance/src/extensions/bugsnag_lifecycle_listener.dart';
import 'package:bugsnag_flutter_performance/src/extensions/date_time.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';
import 'package:bugsnag_flutter_performance/src/uploader/retry_queue.dart';
import 'package:bugsnag_flutter_performance/src/uploader/retry_queue_builder.dart';
import 'package:bugsnag_flutter_performance/src/uploader/uploader.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRetryQueue implements RetryQueue {
  @override
  Future<void> enqueue(
      {required Map<String, String> headers, required Uint8List body}) async {}
  @override
  Future<void> flush() async {}
}

class MockRetryQueueBuilder implements RetryQueueBuilder {
  @override
  RetryQueue build(Uploader uploader) {
    return MockRetryQueue();
  }
}

class MockLifecycleListener implements BugsnagLifecycleListener {
  @override
  void startObserving(void Function() onAppBackgrounded) {}
}

void main() {
  const apiKey = 'TestApiKey';
  final endpoint = Uri.tryParse('https://bugsnag.com')!;
  BugsnagClockImpl.ensureInitialized();
  group('BugsnagPerformanceClient', () {
    late BugsnagPerformanceClientImpl client;

    setUp(() {
      client = BugsnagPerformanceClientImpl();
      client.retryQueueBuilder = MockRetryQueueBuilder();
      client.lifecycleListener = MockLifecycleListener();
    });
    group('start', () {
      test('should set configuration with the provided parameters', () async {
        await client.start(apiKey: apiKey, endpoint: endpoint);

        expect(client.configuration!.apiKey, equals(apiKey));
        expect(client.configuration!.endpoint, equals(endpoint));
      });
    });

    group('startSpan', () {
      const name = 'TestSpanName';
      test(
          'should return a running span with the provided name and current time',
          () {
        final timeBeforeStart = BugsnagClockImpl.instance.now();
        final span = client.startSpan(name) as BugsnagPerformanceSpanImpl;
        final timeAfterStart = BugsnagClockImpl.instance.now();

        expect(span.name, equals(name));
        expect(
            span.startTime.nanosecondsSinceEpoch >=
                timeBeforeStart.nanosecondsSinceEpoch,
            isTrue);
        expect(
            span.startTime.nanosecondsSinceEpoch <=
                timeAfterStart.nanosecondsSinceEpoch,
            isTrue);
        expect(span.endTime, isNull);
      });
    });
  });
}
