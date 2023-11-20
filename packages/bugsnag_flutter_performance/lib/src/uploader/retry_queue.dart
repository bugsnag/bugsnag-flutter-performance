import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:bugsnag_flutter_performance/src/uploader/uploader.dart';
import 'package:uuid/uuid.dart';

import 'model/otlp_package.dart';

class CachedPayloadModel {
  String id;
  Map<String, String> headers;
  Uint8List body;

  CachedPayloadModel({required this.id, required this.headers, required this.body});

  factory CachedPayloadModel.fromJson(Map<String, dynamic> json) {
    dynamic headersJson = json['headers'];
    Map<String, String> headers = Map<String, String>.from(
          headersJson.map((key, value) => MapEntry<String, String>(key, value.toString())));

    return CachedPayloadModel(
      id: json['id'],
      headers: headers,
      body: base64Decode(json['body']),
    );

  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'headers': headers, 'body': base64Encode(body)};
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

  final Uuid _uuid = const Uuid();
  final Uploader? _uploader;

  FileRetryQueue(Uploader uploader) : _uploader = uploader;

  @override
  Future<void> enqueue({
    required Map<String, String> headers,
    required Uint8List body,
  }) async {
    final id = _uuid.v4();
    final payload = jsonEncode(CachedPayloadModel(id: id, headers: headers, body: body));
    final fileName = _generateFileName(id);
    await _writeToFile(fileName, payload);
  }

  @override
  Future<void> flush() async {
    final cacheDirectory = await _getCacheDirectory();
    if (!cacheDirectory.existsSync()) {
      return;
    }

    final files = cacheDirectory.listSync().cast<File>()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    final now = DateTime.now();
    for (var file in files) {
      if (now.difference(file.lastModifiedSync()) > _maxAge) {
        file.deleteSync();
      } else {
        final payload = await file.readAsString();
        final cachedPayloadModel = CachedPayloadModel.fromJson(jsonDecode(payload));
        final success = await _sendPayload(cachedPayloadModel);
        if(success)
        {
          file.deleteSync();
        }
      }
    }
  }

  Future<bool> _sendPayload(CachedPayloadModel payloadModel) async {
      final package = OtlpPackage(
        headers: payloadModel.headers,
        payload: payloadModel.body,
      );
      final result = await _uploader?.upload(package: package);
      return result == RequestResult.success;
    }
  }

  Future<void> _writeToFile(String fileName, String payload) async {
    final cacheDirectory = await _getCacheDirectory();
    if (!cacheDirectory.existsSync()) {
      cacheDirectory.createSync(recursive: true);
    }

    final file = File('${cacheDirectory.path}/$fileName');
    await file.writeAsString(payload);
  }

  String _generateFileName(String id) {
    return 'payload_$id.json';
  }

  Future<Directory> _getCacheDirectory() async {
    final appCacheDir = await getApplicationSupportDirectory();
    return Directory('${appCacheDir.path}/$_cacheDirectoryName');
  }
}
