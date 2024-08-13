import 'dart:io';

import 'package:bugsnag_flutter_performance/src/configuration.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';
import 'package:bugsnag_flutter_performance/src/uploader/sampling_probability_store.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';

abstract class Sampler {
  Future<bool> hasValidSamplingProbabilityValue();
  Future<bool> sample(BugsnagPerformanceSpan span);
  Future<List<BugsnagPerformanceSpan>> sampled(
      List<BugsnagPerformanceSpan> spans);
  Future<void> handleResponseHeaders(HttpHeaders headers);
}

class SamplerImpl implements Sampler {
  BugsnagPerformanceConfiguration configuration;
  SamplingProbabilityStore probabilityStore;
  BugsnagClock clock;

  static final BigInt baselineInt =
      BigInt.parse('18446744073709551', radix: 10);

  SamplerImpl({
    required this.configuration,
    required this.probabilityStore,
    required this.clock,
  });

  @override
  Future<bool> hasValidSamplingProbabilityValue() async {
    return await probabilityStore.samplingProbability != null;
  }

  @override
  Future<bool> sample(BugsnagPerformanceSpan span) async {
    final samplingProbability =
        await probabilityStore.samplingProbability ?? 1.0;
    return _sample(span, samplingProbability);
  }

  @override
  Future<List<BugsnagPerformanceSpan>> sampled(
      List<BugsnagPerformanceSpan> spans) async {
    final samplingProbability =
        await probabilityStore.samplingProbability ?? 1.0;
    return spans
        .where((element) => _sample(
              element,
              samplingProbability,
            ))
        .toList();
  }

  bool _sample(BugsnagPerformanceSpan span, double samplingProbability) {
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
    (span as BugsnagPerformanceSpanImpl?)?.isSampled = isSampled;
    return isSampled;
  }

  @override
  Future<void> handleResponseHeaders(HttpHeaders headers) async {
    final samplingProbabilityHeader =
        headers.value('Bugsnag-Sampling-Probability');
    if (samplingProbabilityHeader == null) {
      return;
    }
    final headerComponents = samplingProbabilityHeader.split(';');
    final probability = double.tryParse(headerComponents.firstOrNull ?? '');
    if (probability == null || probability > 1 || probability < 0) {
      return;
    }
    var duration = configuration.probabilityValueExpireTime / 1000;
    if (headerComponents.length > 1) {
      final durationFromHeader = double.tryParse(headerComponents
              .firstWhere(
                (element) => element.contains('duration='),
                orElse: () => '',
              )
              .split('=')
              .lastOrNull ??
          '');
      if (durationFromHeader != null && durationFromHeader < duration) {
        duration = durationFromHeader;
      }
    }
    await probabilityStore.store(probability,
        clock.now().add(Duration(milliseconds: (duration * 1000).toInt())));
  }
}
