import 'dart:async';

import 'package:bugsnag_flutter_performance/src/configuration.dart';
import 'package:bugsnag_flutter_performance/src/span.dart';

abstract class SpanBatch {
  void configure(BugsnagPerformanceConfiguration configuration);
  void add(BugsnagPerformanceSpan span);
  void remove(TraceId traceId, SpanId spanId);
  void allowDrain();
  List<BugsnagPerformanceSpan> drain({bool? force});
  void Function(SpanBatch batch) onBatchFull = (_) {};
}

class SpanBatchImpl implements SpanBatch {
  List<BugsnagPerformanceSpan> _spans = [];
  int _maxBatchSize = 0;
  int _maxBatchAge = 0;
  bool _drainIsAllowed = false;
  DateTime _creationTime = DateTime.now();

  @override
  void Function(SpanBatch batch) onBatchFull = (_) {};

  @override
  void configure(BugsnagPerformanceConfiguration configuration) {
    _maxBatchSize = configuration.maxBatchSize;
    _maxBatchAge = configuration.maxBatchAge;
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _checkForMaxBatchAge();
    });
  }

  @override
  void add(BugsnagPerformanceSpan span) {
    _spans.add(span);
    if (_isFull) {
      _drainIsAllowed = true;
      onBatchFull(this);
    }
  }

  @override
  void allowDrain() {
    _drainIsAllowed = true;
  }

  @override
  List<BugsnagPerformanceSpan> drain({bool? force}) {
    final isForced = force ?? false;
    if (!(_drainIsAllowed || isForced)) {
      return [];
    }
    final spans = _spans.toList();
    _spans.clear();
    _creationTime = DateTime.now();
    _drainIsAllowed = false;
    return spans;
  }

  @override
  void remove(TraceId traceId, SpanId spanId) {
    final spans = _spans
        .where((span) => !(span.traceId == traceId && span.spanId == spanId))
        .toList();
    if (_spans.length != spans.length) {
      _spans = spans;
      _spans
          .where(
              (span) => span.traceId == traceId && span.parentSpanId == spanId)
          .forEach((span) {
        span.parentSpanId = null;
      });
    }
  }

  bool get _isFull => _spans.length >= _maxBatchSize;

  void _checkForMaxBatchAge() {
    if (_isFull) {
      return;
    }
    if (DateTime.now().difference(_creationTime).inMilliseconds >
        _maxBatchAge) {
      _drainIsAllowed = true;
      onBatchFull(this);
    }
  }
}
