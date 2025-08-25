/// Base interface for span queries - acts as a type-safe key
abstract class SpanQuery<R> {
  const SpanQuery();
}

sealed class SpanType<R> extends SpanQuery<R> {
  const SpanType();
}

// AppStart span type and control interface
class _AppStartSpanType extends SpanType<AppStartSpanControl> {
  const _AppStartSpanType._();
}

abstract class AppStartSpanControl {
  void setType(String? name);
  void clearType();
}

const AppStart = _AppStartSpanType._();

