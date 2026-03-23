import 'dart:typed_data';
import 'package:bugsnag_flutter_performance/src/client.dart';
import 'package:bugsnag_flutter_performance/src/extensions/bugsnag_lifecycle_listener.dart';
import 'package:bugsnag_flutter_performance/src/uploader/retry_queue.dart';
import 'package:bugsnag_flutter_performance/src/uploader/retry_queue_builder.dart';
import 'package:bugsnag_flutter_performance/src/uploader/uploader.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockRetryQueue implements RetryQueue {
  @override
  Future<void> enqueue(
      {required Map<String, String> headers, required Uint8List body}) async {}
  @override
  Future<void> flush() async {}
}

class _MockRetryQueueBuilder implements RetryQueueBuilder {
  @override
  RetryQueue build(Uploader uploader) => _MockRetryQueue();
}

class _MockLifecycleListener implements BugsnagLifecycleListener {
  @override
  void startObserving({void Function()? onAppBackgrounded}) {
  }
}

void main() {
  const validKey = 'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6';
  const secondaryKey = '00000deadbeefdeadbeefdeadbeef00';
  final explicitEndpoint = Uri.parse('https://example.com/otel');
  final defaultBugsnag = Uri.parse('https://otlp.bugsnag.com/v1/traces');
  final defaultWithKey =
      Uri.parse('https://$validKey.otlp.bugsnag.com/v1/traces');
  final defaultSecondaryHost =
      Uri.parse('https://$secondaryKey.otlp.bugsnag.smartbear.com/v1/traces');

  BugsnagPerformanceClientImpl freshClient(_MockLifecycleListener listener) {
    final c = BugsnagPerformanceClientImpl(lifecycleListener: listener);
    c.retryQueueBuilder = _MockRetryQueueBuilder();
    return c;
  }

  BugsnagClockImpl.ensureInitialized();

  group('Endpoint selection', () {
    test('defaults to Bugsnag OTLP when no apiKey supplied', () async {
      final client = freshClient(_MockLifecycleListener());
      await client.start();
      expect(client.configuration!.endpoint, defaultBugsnag);
    });

    test('prefixes apiKey subdomain when apiKey supplied', () async {
      final client = freshClient(_MockLifecycleListener());
      await client.start(apiKey: validKey);
      expect(client.configuration!.endpoint, defaultWithKey);
    });

    test('uses caller-supplied endpoint unchanged', () async {
      final client = freshClient(_MockLifecycleListener());
      await client.start(apiKey: validKey, endpoint: explicitEndpoint);
      expect(client.configuration!.endpoint, explicitEndpoint);
    });

    test('prefixes hub subdomain when secondary key (00000…) supplied',
        () async {
      final client = freshClient(_MockLifecycleListener());
      await client.start(apiKey: secondaryKey);
      expect(client.configuration!.endpoint, defaultSecondaryHost);
    });
  });
}
