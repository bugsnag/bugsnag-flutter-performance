import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_flutter_performance/src/uploader/model/otlp_package.dart';
import 'package:crypto/crypto.dart';

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
    final uncompressedData = payload;
    if (payload.length >= _minSizeForGzip) {
      payload = GZipCodec().encode(payload);
      isZipped = true;
    }
    final headers = _buildHeaders(
      payload: uncompressedData,
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
    final jsonList = spans.map((span) => span.toJson()).toList();
    final jsonRequest = {
      'resourceSpans': [
        {
          'scopeSpans': [
            {
              'spans': jsonList,
            }
          ],
          'resource': {
            'attributes': [
              {
                'key': 'deployment.environment',
                'value': {
                  'stringValue': 'staging',
                }
              },
              {
                'key': 'telemetry.sdk.name',
                'value': {
                  'stringValue': 'bugsnag.performance.flutter',
                }
              },
              {
                'key': 'telemetry.sdk.version',
                'value': {
                  'stringValue': '0.0.1',
                }
              }
            ],
          },
        }
      ]
    };
    final json = jsonEncode(jsonRequest);
    return utf8.encode(json);
  }

  Map<String, String> _buildHeaders({
    required List<int> payload,
    required bool isZipped,
  }) {
    return {
      'Content-Type': 'application/json',
      'Bugsnag-Integrity': _integrityDigestForData(payload: payload),
      'Bugsnag-Uncompressed-Content-Length': payload.length.toString(),
      if (isZipped) 'Content-Encoding': 'gzip'
    };
  }

  String _integrityDigestForData({
    required List<int> payload,
  }) {
    return 'sha1 ${sha1.convert(payload)}';
  }
}
