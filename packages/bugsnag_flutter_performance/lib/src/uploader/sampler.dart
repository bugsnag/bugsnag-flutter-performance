import 'package:bugsnag_flutter_performance/src/span.dart';

abstract class Sampler {
  bool sample(BugsnagPerformanceSpan span);
  List<BugsnagPerformanceSpan> sampled(List<BugsnagPerformanceSpan> spans);
}

class SamplerImpl implements Sampler {
  double samplingProbability;

  static final BigInt baselineInt =
      BigInt.parse('18446744073709551', radix: 10);

  SamplerImpl({
    this.samplingProbability = 1.0,
  });

  @override
  bool sample(BugsnagPerformanceSpan span) {
    var isSampled = false;
    if (samplingProbability == 1.0) {
      isSampled = true;
    } else if (samplingProbability > 0.0) {
      isSampled = span.traceId.toUnsigned(64) <=
          baselineInt * BigInt.from(samplingProbability * 1000);
    }
    if (isSampled) {
      (span as BugsnagPerformanceSpanImpl?)
          ?.updateSamplingProbability(samplingProbability);
    }
    return isSampled;
  }

  @override
  List<BugsnagPerformanceSpan> sampled(List<BugsnagPerformanceSpan> spans) {
    return spans.where((element) => sample(element)).toList();
  }
}
