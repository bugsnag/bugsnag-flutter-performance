import 'span_control.dart';
import 'span_query.dart';

/// Base interface for providing span controls
abstract class SpanControlProvider {
  R? getSpanControl<R extends SpanControl>(SpanQuery<R> query);
}
