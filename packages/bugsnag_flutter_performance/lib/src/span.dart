import 'package:bugsnag_flutter_performance/src/extensions/date_time.dart';
import 'package:bugsnag_flutter_performance/src/extensions/int.dart';
import 'package:bugsnag_flutter_performance/src/span_attributes.dart';
import 'package:bugsnag_flutter_performance/src/span_context.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:bugsnag_flutter_performance/src/util/random.dart';

typedef TraceId = BigInt;
typedef SpanId = BigInt;

abstract class BugsnagPerformanceSpan implements BugsnagPerformanceSpanContext {
  @override
  TraceId get traceId;
  @override
  SpanId get spanId;
  SpanId? parentSpanId;
  void end({
    int? httpStatusCode,
    int? requestContentLength,
    int? responseContentLength,
    bool cancelled = false,
    DateTime? endTime,
  });
  String get encodedTraceId;
  String get encodedSpanId;
  dynamic toJson();
}

class BugsnagPerformanceSpanImpl
    implements BugsnagPerformanceSpan, BugsnagPerformanceSpanContext {
  BugsnagPerformanceSpanImpl(
      {required this.name,
      required this.startTime,
      void Function(BugsnagPerformanceSpan)? onEnded,
      void Function(BugsnagPerformanceSpan)? onCanceled,
      TraceId? traceId,
      SpanId? spanId,
      this.parentSpanId,
      BugsnagPerformanceSpanAttributes? attributes}) {
    this.traceId = traceId ?? randomTraceId();
    this.spanId = spanId ?? randomSpanId();
    this.onEnded = onEnded ?? _onEnded;
    this.onCanceled = onCanceled ?? _onCanceled;
    this.attributes = attributes ?? BugsnagPerformanceSpanAttributes();
  }
  final String name;
  @override
  late final TraceId traceId;
  @override
  late final SpanId spanId;
  @override
  SpanId? parentSpanId;
  final DateTime startTime;
  late final BugsnagPerformanceSpanAttributes attributes;
  DateTime? endTime;
  var isSampled = false;
  late final void Function(BugsnagPerformanceSpan) onEnded;
  late final void Function(BugsnagPerformanceSpan) onCanceled;
  late final BugsnagClock clock;

  @override
  void end({
    int? httpStatusCode,
    int? requestContentLength,
    int? responseContentLength,
    bool cancelled = false,
    DateTime? endTime,
  }) {
    if (!isOpen()) {
      return;
    }
    this.endTime = endTime ?? clock.now();
    if (cancelled) {
      onCanceled(this);
      return;
    }
    // Update span attributes with network information if provided
    if (httpStatusCode != null) attributes.httpStatusCode = httpStatusCode;
    if (requestContentLength != null && requestContentLength > 0) {
      attributes.requestContentLength = requestContentLength;
    }
    if (responseContentLength != null && responseContentLength > 0) {
      attributes.responseContentLength = responseContentLength;
    }
    onEnded(this);
  }

  BugsnagPerformanceSpanImpl.fromJson(Map<String, dynamic> json,
      [void Function(BugsnagPerformanceSpan)? onEnded])
      : startTime = int.parse(json['startTimeUnixNano']).timeFromNanos,
        name = json['name'] as String,
        endTime = json['endTimeUnixNano'] != null
            ? int.parse(json['endTimeUnixNano']).timeFromNanos
            : null,
        traceId = _decodeTraceId(json['traceId'] as String?) ?? randomTraceId(),
        spanId = _decodeSpanId(json['spanId'] as String?) ?? randomSpanId(),
        parentSpanId = _decodeSpanId(json['parentSpanId'] as String?),
        onEnded = onEnded ?? _onEnded,
        attributes =
            BugsnagPerformanceSpanAttributes.fromJson(json['attributes']);

  @override
  dynamic toJson() => {
        'startTimeUnixNano': startTime.nanosecondsSinceEpoch.toString(),
        'name': name,
        if (endTime != null)
          'endTimeUnixNano': endTime!.nanosecondsSinceEpoch.toString(),
        'traceId': encodedTraceId,
        'spanId': encodedSpanId,
        'kind': 1,
        if (parentSpanId != null)
          'parentSpanId': _encodeSpanId(parentSpanId ?? BigInt.zero),
        'attributes': attributes.toJson(),
      };

  @override
  bool operator ==(dynamic other) =>
      other is BugsnagPerformanceSpan &&
      other.spanId == spanId &&
      other.traceId == traceId;

  @override
  int get hashCode => toJson().hashCode;

  void updateSamplingProbability(double samplingProbability) {
    double? currentSamplingProbability = attributes.samplingProbability;
    if (currentSamplingProbability == null ||
        samplingProbability < currentSamplingProbability) {
      attributes.samplingProbability = samplingProbability;
    }
  }

  @override
  bool isOpen() {
    return endTime == null;
  }

  String get encodedTraceId => _encodeTraceId(traceId);
  String get encodedSpanId => _encodeSpanId(spanId);
}

String _encodeSpanId(SpanId spanId) {
  return spanId.toRadixString(16).padLeft(16, '0');
}

String _encodeTraceId(TraceId traceId) {
  return traceId.toRadixString(16).padLeft(32, '0');
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

void _onCanceled(BugsnagPerformanceSpan span) {}
