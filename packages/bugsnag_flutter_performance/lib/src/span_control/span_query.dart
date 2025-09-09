import 'span_control.dart';

/// Generic query for retrieving span controls
class SpanQuery<R extends SpanControl> {
  final Map<String, dynamic> params;
  final Type resultType;

  const SpanQuery(this.params) : resultType = R;

  dynamic operator [](String key) => params[key];
}
