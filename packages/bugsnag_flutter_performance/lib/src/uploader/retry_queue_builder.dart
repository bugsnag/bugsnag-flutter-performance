import 'package:bugsnag_flutter_performance/src/uploader/retry_queue.dart';
import 'package:bugsnag_flutter_performance/src/uploader/uploader.dart';

abstract class RetryQueueBuilder {
  RetryQueue build(Uploader uploader);
}

class RetryQueueBuilderImpl implements RetryQueueBuilder {
  @override
  RetryQueue build(Uploader uploader) {
    return FileRetryQueue(uploader);
  }
}
