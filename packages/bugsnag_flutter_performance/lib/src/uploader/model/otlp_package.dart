import 'package:flutter/foundation.dart';

class OtlpPackage {
  final Map<String, String> headers;
  final Uint8List payload;

  OtlpPackage({
    required this.headers,
    required this.payload,
  });
}
