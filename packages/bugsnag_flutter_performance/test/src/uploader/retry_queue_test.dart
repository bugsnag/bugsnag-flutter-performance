import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bugsnag_flutter_performance/src/uploader/model/otlp_package.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:bugsnag_flutter_performance/src/uploader/uploader.dart';
import 'package:bugsnag_flutter_performance/src/uploader/retry_queue.dart';

class TestUploader implements Uploader {
  final RequestResult resultToReturn;
  final bool throwError;

  TestUploader({this.resultToReturn = RequestResult.success, this.throwError = false});

  @override
  Future<RequestResult> upload({required OtlpPackage package}) async {
    if (throwError) {
      throw Exception('Upload error');
    }
    return resultToReturn;
  }
}

class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async {
    final directory = await Directory.systemTemp.createTemp('bugsnag_test');
    return directory.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileRetryQueue', () {
    late FileRetryQueue retryQueue;
    late TestUploader testUploader;
    late Directory mockCacheDirectory;

    setUp(() async {
      BugsnagClockImpl.ensureInitialized();
      PathProviderPlatform.instance = MockPathProviderPlatform();
      final supportDir = await getApplicationSupportDirectory();
      final mockCachePath = '${supportDir.path}/bugsnag-performance/v1/batches';
      mockCacheDirectory = Directory(mockCachePath);
      await mockCacheDirectory.create(recursive: true);

    });

    tearDown(() async {
      if (await mockCacheDirectory.exists()) {
        await mockCacheDirectory.delete(recursive: true);
      }
    });

    test('should delete the file after successful upload', () async {
      // Setup uploader to return success
      testUploader = TestUploader(resultToReturn: RequestResult.success);
      retryQueue = FileRetryQueue(testUploader, cacheDirectory: mockCacheDirectory);

      // Create a valid payload file
      final fileName = '${mockCacheDirectory.path}/payload_success.json';
      final file = File(fileName);
      final payloadModel = CachedPayloadModel(headers: {}, body: Uint8List(0));
      await file.writeAsString(jsonEncode(payloadModel.toJson()));

      await retryQueue.flush();

      // Ensure the file is deleted after flush
      expect(await file.exists(), isFalse);
    });

    test('should not delete the file after failed upload', () async {
      // Setup uploader to return failure
      testUploader = TestUploader(resultToReturn: RequestResult.retriableFailure);
      retryQueue = FileRetryQueue(testUploader, cacheDirectory: mockCacheDirectory);

      // Create a valid payload file
      final fileName = '${mockCacheDirectory.path}/payload_failure.json';
      final file = File(fileName);
      final payloadModel = CachedPayloadModel(headers: {}, body: Uint8List(0));
      await file.writeAsString(jsonEncode(payloadModel.toJson()));

      await retryQueue.flush();

      // Ensure the file is not deleted after flush
      expect(await file.exists(), isTrue);
    });

    test('should handle malformed JSON and delete the file', () async {
      testUploader = TestUploader();
      retryQueue = FileRetryQueue(testUploader, cacheDirectory: mockCacheDirectory);
      // Create a file with malformed JSON
      final fileName = '${mockCacheDirectory.path}/malformed_payload.json';
      final file = File(fileName);
      await file.writeAsString('malformed_json');

      await retryQueue.flush();

      // Ensure the file is deleted after flush
      expect(await file.exists(), isFalse);
    });

    test('should delete files older than 24 hours', () async {
      testUploader = TestUploader();
      retryQueue = FileRetryQueue(testUploader, cacheDirectory: mockCacheDirectory);
      // Create a file older than 24 hours
      final oldTimestamp = BugsnagClockImpl.instance.now().subtract(const Duration(hours: 25));
      final fileName = '${mockCacheDirectory.path}/old_payload.json';
      final file = File(fileName);
      await file.writeAsString('{"headers": {}, "body": ""}');
      file.setLastModifiedSync(oldTimestamp);

      await retryQueue.flush();

      // Ensure the file is deleted after flush
      expect(file.existsSync(), isFalse);
    });
  });
}
