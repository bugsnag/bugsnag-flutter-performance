import 'dart:io';

import 'package:bugsnag_flutter_performance/src/uploader/client_request.dart';

abstract class UploaderClient {
  Future<ClientRequest> post({required Uri url});
}

class UploaderClientImpl implements UploaderClient {
  final HttpClient httpClient;
  UploaderClientImpl({
    required this.httpClient,
  });

  @override
  Future<ClientRequest> post({required Uri url}) async {
    return ClientRequestImpl(request: await httpClient.postUrl(url));
  }
}
