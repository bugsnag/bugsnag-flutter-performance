import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bugsnag_flutter_performance/src/uploader/uploader.dart';
import 'package:uuid/uuid.dart';

import 'package:path_provider/path_provider.dart';

import 'model/otlp_package.dart';

abstract class RetryQueue {
  Future<void> enqueue({required Map<String, String> headers, required Uint8List body});
  Future<void> flush();
}

class FileRetryQueue implements RetryQueue {
  static const String _cacheDirectoryName = '/bugsnag-performance/v1/batches';
  static const Duration _maxAge = Duration(hours: 24);
  final Uuid _uuid = const Uuid();
  final Uploader? _uploader;

  FileRetryQueue(Uploader uploader) : _uploader = uploader;

  @override
  Future<void> enqueue({required Map<String, String> headers, required Uint8List body}) async {
    final id = _uuid.v4();
    final payload = _encodePayload(id, headers, body);
    final fileName = _generateFileName(id);
    await _writeToFile(fileName, payload);
  }

  @override
  Future<void> flush() async {
    final cacheDirectory = await _getCacheDirectory();
    if (!cacheDirectory.existsSync()) {
      return;
    }

    final files = cacheDirectory.listSync().cast<File>()..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    final now = DateTime.now();
    for (var file in files) {
      if (now.difference(file.lastModifiedSync()) > _maxAge) {
        file.deleteSync();
      } else {
        final payload = await file.readAsString();
        await _sendPayload(payload);
        file.deleteSync();
      }
    }
  }

  String _encodePayload(String id, Map<String, String> headers, Uint8List body) {
    final payload = {
      'id': id,
      'headers': headers,
      'body': base64Encode(body),
    };

    return jsonEncode(payload);
  }

  String _generateFileName(String id) {
    return 'payload_$id.json';
  }

  Future<void> _writeToFile(String fileName, String payload) async {
    final cacheDirectory = await _getCacheDirectory();
    if (!cacheDirectory.existsSync()) {
      cacheDirectory.createSync(recursive: true);
    }

    final file = File('${cacheDirectory.path}/$fileName');
    await file.writeAsString(payload);
  }

  Future<void> _sendPayload(String payload) async {
    final decodedPayload = jsonDecode(payload);
    final id = decodedPayload['id'] as String;
    final headers = decodedPayload['headers'] as Map<String, String>;
    final bodyBase64 = decodedPayload['body'] as String;
    final bodyBytes = base64Decode(bodyBase64);

    final package = OtlpPackage(
      headers: headers,
      payload: bodyBytes,
    );
    final success = await _uploader?.upload(package: package);
    if (success == true) {
      await _deletePayloadById(id);
    }
  }

  Future<void> _deletePayloadById(String id) async {
    final cacheDirectory = await _getCacheDirectory();
    final fileName = _generateFileName(id);
    final file = File('${cacheDirectory.path}/$fileName');
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  Future<Directory> _getCacheDirectory() async {
    final appCacheDir = await getApplicationSupportDirectory();
    return Directory('${appCacheDir.path}/$_cacheDirectoryName');
  }
}
