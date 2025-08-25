import '../configuration.dart';
import 'span_control_provider.dart';
import 'prioritized_store.dart';

abstract class Plugin {
  BugsnagPerformanceConfiguration? get configuration;
  void install(PluginContext context) {}
  void start() {}
}

class PluginContext {
  static const int highPriority = 100000;
  static const int normPriority = 50000;
  static const int lowPriority = 0;

  final PrioritizedStore<SpanControlProvider> _spanControlProviders = PrioritizedStore();

  void addSpanControlProvider(
      SpanControlProvider provider, {
        int priority = normPriority,
      }) {
    _spanControlProviders.addObject(provider, priority: priority);
  }

  List<SpanControlProvider> get providers => _spanControlProviders.objects;
}