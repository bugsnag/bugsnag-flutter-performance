import 'package:bugsnag_flutter_performance/src/span.dart';
import 'package:bugsnag_flutter_performance/src/span_attributes.dart';

/// Abstract base class for span queries
abstract class SpanQuery<R> {}

/// Interface for controlling AppStart spans
abstract class AppStartSpanControl {
  /// Set a custom name suffix for the AppStart span
  void setType(String? name);
  
  /// Clear the custom name suffix (revert to default)
  void clearType() => setType(null);
}

/// Query class for accessing AppStart span controls
class AppStartQuery extends SpanQuery<AppStartSpanControl> {
  const AppStartQuery();
}

/// Singleton instance for AppStart queries
const AppStartQuery appStart = AppStartQuery();

/// Implementation of AppStartSpanControl
class AppStartSpanControlImpl implements AppStartSpanControl {
  final BugsnagPerformanceSpanImpl span;
  String? _customType;
  final String _originalName;

  AppStartSpanControlImpl(this.span) : _originalName = span.name;

  @override
  void setType(String? name) {
    if (!span.isOpen()) return;
    
    _customType = name;
    
    // Set or remove the bugsnag.app_start.name attribute
    span.attributes.setAttribute('bugsnag.app_start.name', name);
    
    // Update the span name directly
    span.name = name != null 
        ? '$_originalName$name'
        : _originalName;
  }
}