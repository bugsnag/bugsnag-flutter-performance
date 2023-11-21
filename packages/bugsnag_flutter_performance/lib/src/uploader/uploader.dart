import 'package:bugsnag_flutter_performance/src/uploader/sampler.dart';
import 'package:bugsnag_flutter_performance/src/uploader/uploader_client.dart';
import 'package:bugsnag_flutter_performance/src/uploader/model/otlp_package.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';

abstract class Uploader {
  Future<bool> upload({required OtlpPackage package});
}

class UploaderImpl implements Uploader {
  final String apiKey;
  final Uri url;
  final UploaderClient client;
  final BugsnagClock clock;
  final Sampler sampler;
  UploaderImpl({
    required this.apiKey,
    required this.url,
    required this.client,
    required this.clock,
    required this.sampler,
  });

  @override
  Future<bool> upload({
    required OtlpPackage package,
  }) async {
    final sentAtTime = clock.now().toUtc();
    var headers = {
      'Bugsnag-Api-Key': apiKey,
      'Bugsnag-Sent-At': sentAtTime
          .subtract(Duration(microseconds: sentAtTime.microsecond))
          .toIso8601String(),
      'Bugsnag-Span-Sampling': '1:1'
    };
    headers.addAll(package.headers);
    final request = await client.post(url: url);
    request.setHeaders(headers);
    request.setBody(package.payload);
    final response = await request.send();
    return response.statusCode / 100 == 2;
  }
}
