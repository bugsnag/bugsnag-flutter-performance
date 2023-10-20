import 'dart:io';

import 'package:bugsnag_flutter_performance/src/uploader/client_response.dart';
import 'package:flutter/foundation.dart';

abstract class ClientRequest {
  void setHeaders(Map<String, String> headers);
  void setBody(Uint8List body);
  Future<ClientResponse> send();
}

class ClientRequestImpl implements ClientRequest {
  final HttpClientRequest request;
  ClientRequestImpl({
    required this.request,
  });

  @override
  void setHeaders(Map<String, String> headers) {
    headers.forEach((key, value) {
      request.headers.add(key, value);
    });
  }

  @override
  void setBody(List<int> body) {
    request.add(body);
  }

  @override
  Future<ClientResponse> send() async {
    return ClientResponseImpl(response: await request.close());
  }
}
