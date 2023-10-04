import 'package:bugsnag_flutter_performance/src/extensions/date_time.dart';
import 'package:bugsnag_flutter_performance/src/extensions/int.dart';

abstract class BugsnagPerformanceSpan {
  void end();
}

class BugsnagPerformanceSpanImpl implements BugsnagPerformanceSpan {
  BugsnagPerformanceSpanImpl({required this.name, required this.startTime});
  final DateTime startTime;
  final String name;
  DateTime? endTime;

  @override
  void end() {
    if (endTime != null) {
      return;
    }

    endTime = DateTime.now();
  }

  BugsnagPerformanceSpanImpl.fromJson(Map<String, dynamic> json)
      : startTime = (json['startTimeUnixNano'] as int).timeFromNanos,
        name = json['name'] as String,
        endTime = json['endTimeUnixNano'] != null
            ? (json['endTimeUnixNano'] as int).timeFromNanos
            : null;

  dynamic toJson() => {
        'startTimeUnixNano': startTime.nanosecondsSinceEpoch,
        'name': name,
        if (endTime != null) 'endTimeUnixNano': endTime!.nanosecondsSinceEpoch,
      };
}
