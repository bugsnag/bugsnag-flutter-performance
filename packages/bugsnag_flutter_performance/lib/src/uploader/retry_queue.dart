import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:bugsnag_flutter_performance/src/uploader/uploader.dart';

import '../util/clock.dart';
import 'model/otlp_package.dart';

class CachedPayloadModel {
  Map<String, String> headers;
  Uint8List body;

  CachedPayloadModel({required this.headers, required this.body});

  factory CachedPayloadModel.fromJson(Map<String, dynamic> json) {
    dynamic headersJson = json['headers'];
    Map<String, String> headers = Map<String, String>.from(headersJson
        .map((key, value) => MapEntry<String, String>(key, value.toString())));

    return CachedPayloadModel(
      headers: headers,
      body: base64Decode(json['body']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'headers': headers, 'body': base64Encode(body)};
  }
}

abstract class RetryQueue {
  Future<void> enqueue({
    required Map<String, String> headers,
    required Uint8List body,
  });

  Future<void> flush();
}

class FileRetryQueue implements RetryQueue {
  static const String _cacheDirectoryName = 'bugsnag-performance/v1/batches';
  static const Duration _maxAge = Duration(hours: 24);

  final Uploader? _uploader;
  var _isFlushing = false;
  final Directory? _cacheDirectory;

  FileRetryQueue(Uploader uploader, {Directory? cacheDirectory})
      : _uploader = uploader,
        _cacheDirectory = cacheDirectory;

  @override
  Future<void> enqueue({
    required Map<String, String> headers,
    required Uint8List body,
  }) async {
    final payload =
        jsonEncode(CachedPayloadModel(headers: headers, body: body));
    final fileName = _generateFileName();
    await _writeToFile(fileName, payload);
  }

  @override
  Future<void> flush() async {
    final cacheDirectory = _cacheDirectory ?? await _getCacheDirectory();
    if (_isFlushing || !cacheDirectory.existsSync()) {
      return;
    }
    _isFlushing = true;
    final files = cacheDirectory.listSync().cast<File>()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    final now = BugsnagClockImpl.instance.now();
    for (var file in files) {
      try {
        if (now.difference(file.lastModifiedSync()) > _maxAge) {
          file.deleteSync();
        } else {
          final payload = await file.readAsString();
          final cachedPayloadModel =
              CachedPayloadModel.fromJson(jsonDecode(payload));
          final success = await _sendPayload(cachedPayloadModel);
          if (success) {
            file.deleteSync();
          }
        }
      } catch (error) {
        try {
          file.deleteSync();
        } catch (_) {
          // deliberately ignored
        }
      }
    }
    _isFlushing = false;
  }

  Future<bool> _sendPayload(CachedPayloadModel payloadModel) async {
    final package = OtlpPackage(
      headers: payloadModel.headers,
      payload: payloadModel.body,
    );
    final result = await _uploader?.upload(package: package);
    return result == RequestResult.success;
  }

  Future<void> _writeToFile(String fileName, String payload) async {
    final cacheDirectory = await _getCacheDirectory();
    if (!cacheDirectory.existsSync()) {
      cacheDirectory.createSync(recursive: true);
    }

    final file = File('${cacheDirectory.path}/$fileName');
    await file.writeAsString(payload);
  }

  String _generateFileName() {
    final timestamp = BugsnagClockImpl.instance.now().millisecondsSinceEpoch;
    return 'payload_$timestamp.json';
  }

  Future<Directory> _getCacheDirectory() async {
    final appCacheDir = await getApplicationSupportDirectory();
    return Directory('${appCacheDir.path}/$_cacheDirectoryName');
  }
}
