import 'dart:io';

abstract class ClientResponse {
  int get statusCode;
  HttpHeaders get headers;
}

class ClientResponseImpl implements ClientResponse {
  HttpClientResponse response;
  ClientResponseImpl({
    required this.response,
  });

  @override
  int get statusCode => response.statusCode;

  @override
  HttpHeaders get headers => response.headers;
}
