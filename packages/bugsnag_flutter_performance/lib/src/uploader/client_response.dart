import 'dart:io';

abstract class ClientResponse {
  int get statusCode;
}

class ClientResponseImpl implements ClientResponse {
  HttpClientResponse response;
  ClientResponseImpl({
    required this.response,
  });

  @override
  int get statusCode => response.statusCode;
}
