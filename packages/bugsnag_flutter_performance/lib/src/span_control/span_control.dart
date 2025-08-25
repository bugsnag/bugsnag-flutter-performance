/// Base interface for span queries - acts as a type-safe key
abstract class SpanQuery<R> {
  const SpanQuery();
}

/// Provider interface for accessing span controls
abstract class SpanControlProvider {
  R? getSpanControl<R>(SpanQuery<R> key);
}