import 'package:bugsnag_flutter_performance/src/extensions/date_time.dart';
import 'package:bugsnag_flutter_performance/src/extensions/int.dart';
import 'package:bugsnag_flutter_performance/src/util/random.dart';

typedef TraceId = BigInt;
typedef SpanId = BigInt;

abstract class BugsnagPerformanceSpan {
  TraceId get traceId;
  SpanId get spanId;
  SpanId? parentSpanId;
  void end();
  dynamic toJson();
}

class BugsnagPerformanceSpanImpl implements BugsnagPerformanceSpan {
  BugsnagPerformanceSpanImpl({
    required this.name,
    required this.startTime,
    void Function(BugsnagPerformanceSpan)? onEnded,
    TraceId? traceId,
    SpanId? spanId,
    this.parentSpanId,
  }) {
    this.traceId = traceId ?? randomTraceId();
    this.spanId = spanId ?? randomSpanId();
    this.onEnded = onEnded ?? _onEnded;
  }
  final String name;
  @override
  late final TraceId traceId;
  @override
  late final SpanId spanId;
  @override
  SpanId? parentSpanId;
  final DateTime startTime;
  DateTime? endTime;
  late final void Function(BugsnagPerformanceSpan) onEnded;

  @override
  void end() {
    if (endTime != null) {
      return;
    }

    endTime = DateTime.now();
  }

  BugsnagPerformanceSpanImpl.fromJson(Map<String, dynamic> json,
      [void Function(BugsnagPerformanceSpan)? onEnded])
      : startTime = (json['startTimeUnixNano'] as int).timeFromNanos,
        name = json['name'] as String,
        endTime = json['endTimeUnixNano'] != null
            ? (json['endTimeUnixNano'] as int).timeFromNanos
            : null,
        traceId = _decodeTraceId(json['traceId'] as String?) ?? randomTraceId(),
        spanId = _decodeSpanId(json['spanId'] as String?) ?? randomSpanId(),
        parentSpanId = _decodeSpanId(json['parentSpanId'] as String?),
        onEnded = onEnded ?? _onEnded;

  @override
  dynamic toJson() => {
        'startTimeUnixNano': startTime.nanosecondsSinceEpoch,
        'name': name,
        if (endTime != null) 'endTimeUnixNano': endTime!.nanosecondsSinceEpoch,
        'traceId': _encodeTraceId(traceId),
        'spanId': _encodeSpanId(spanId),
        if (parentSpanId != null)
          'parentSpanId': _encodeSpanId(parentSpanId ?? BigInt.zero),
      };

  @override
  bool operator ==(dynamic other) =>
      other is BugsnagPerformanceSpan &&
      other.spanId == spanId &&
      other.traceId == traceId;

  @override
  int get hashCode => toJson().hashCode;
}

String _encodeSpanId(SpanId spanId) {
  return spanId.toRadixString(16);
}

String _encodeTraceId(TraceId traceId) {
  return traceId.toRadixString(16);
}

TraceId? _decodeTraceId(String? traceIdString) {
  if (traceIdString == null) {
    return null;
  }
  return BigInt.tryParse(traceIdString, radix: 16);
}

SpanId? _decodeSpanId(String? spanIdString) {
  if (spanIdString == null) {
    return null;
  }
  return BigInt.tryParse(spanIdString, radix: 16);
}

void _onEnded(BugsnagPerformanceSpan span) {}
