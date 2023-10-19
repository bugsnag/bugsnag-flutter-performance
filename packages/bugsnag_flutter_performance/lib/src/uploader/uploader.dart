import 'package:bugsnag_flutter_performance/src/uploader/uploader_client.dart';
import 'package:bugsnag_flutter_performance/src/uploader/model/otlp_package.dart';

abstract class Uploader {
  Future<bool> upload({required OtlpPackage package});
}

class UploaderImpl implements Uploader {
  final String apiKey;
  final Uri url;
  final UploaderClient client;
  UploaderImpl({
    required this.apiKey,
    required this.url,
    required this.client,
  });

  @override
  Future<bool> upload({
    required OtlpPackage package,
  }) async {
    var headers = {
      'Bugsnag-Api-Key': apiKey,
      'Bugsnag-Sent-At': DateTime.now().toUtc().toIso8601String(),
    };
    headers.addAll(package.headers);
    final request = await client.post(url: url);
    request.setHeaders(headers);
    request.setBody(package.payload);
    final response = await request.send();
    return response.statusCode == 200;
  }
}
