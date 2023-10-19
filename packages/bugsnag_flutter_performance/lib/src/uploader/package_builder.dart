import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_flutter_performance/src/uploader/model/otlp_package.dart';

const int _minSizeForGzip = 128;

abstract class PackageBuilder {
  OtlpPackage build(
    List<BugsnagPerformanceSpan> spans,
  );
}

class PackageBuilderImpl implements PackageBuilder {
  @override
  OtlpPackage build(List<BugsnagPerformanceSpan> spans) {
    var payload = _buildPayload(spans: spans);
    var isZipped = false;
    final uncompressedDataLength = payload.length;
    if (payload.length >= _minSizeForGzip) {
      payload = GZipCodec().encode(payload);
      isZipped = true;
    }
    final headers = _buildHeaders(
      payload: payload,
      uncompressedDataLength: uncompressedDataLength,
      isZipped: isZipped,
    );
    return OtlpPackage(
      headers: headers,
      payload: Uint8List.fromList(payload),
    );
  }

  List<int> _buildPayload({
    required List<BugsnagPerformanceSpan> spans,
  }) {
    final jsonList = spans.map((span) => span.toJson());
    final json = jsonEncode(jsonList);
    return utf8.encode(json);
  }

  Map<String, String> _buildHeaders({
    required List<int> payload,
    required int uncompressedDataLength,
    required bool isZipped,
  }) {
    return {
      'Content-Type': 'application/json',
      'Bugsnag-Integrity': _integrityDigestForData(payload: payload),
      'Bugsnag-Uncompressed-Content-Length': uncompressedDataLength.toString(),
      if (isZipped) 'Content-Encoding': 'gzip'
    };
  }

  String _integrityDigestForData({
    required List<int> payload,
  }) {
    return 'sha1 ${payload.map((e) => e.toRadixString(16)).join()}';
  }
}
