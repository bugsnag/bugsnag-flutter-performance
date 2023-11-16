import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

import 'package:path_provider/path_provider.dart';

abstract class RetryQueue {
  Future<void> savePayload({required Map<String, String> headers, required String body});
  Future<void> deletePayloadById(String id);
  Future<void> flush();
}

class FileRetryQueue implements RetryQueue {
  static const String _cacheDirectoryName = '/bugsnag-performance/v1/batches';
  static const Duration _maxAge = Duration(hours: 24);
  final Uuid _uuid = const Uuid();

  @override
  Future<void> savePayload({required Map<String, String> headers, required String body}) async {
    final id = _uuid.v4();
    final payload = _encodePayload(id, headers, body);
    final fileName = _generateFileName(id);
    await _writeToFile(fileName, payload);
  }

  @override
  Future<void> deletePayloadById(String id) async {
    final cacheDirectory = await _getCacheDirectory();
    final fileName = _generateFileName(id);
    final file = File('${cacheDirectory.path}/$fileName');
    if (file.existsSync()) {
      file.deleteSync();
    }
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

  String _encodePayload(String id, Map<String, String> headers, String body) {
    final payload = {
      'id': id,
      'headers': headers,
      'body': base64Encode(Uint8List.fromList(utf8.encode(body))),
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


    // @ROBERT here is where i'm unsure on how to procced
    // What i would like is to have a method that tries to send the payload
    // if it works then it can delete the payload from cache by using the payload id
    // My question is, should i have my own instances of the package builder and uploader
    // or should i use the ones that are already created in the client?
    // notice how i have already added the method "buildFromCache" for a package built from a cached payload
    // Please let me know how i should move forward
  }

  Future<Directory> _getCacheDirectory() async {
    final appCacheDir = await getApplicationSupportDirectory();
    return Directory('${appCacheDir.path}/$_cacheDirectoryName');
  }
}