import 'span_control_provider.dart';
import 'span_control.dart';
import 'span_query.dart';
import 'prioritized_store.dart';

class CompositeSpanControlProvider implements SpanControlProvider {
  final PrioritizedStore<SpanControlProvider> _providers = PrioritizedStore();

  void batchAddProviders(BatchBlock<SpanControlProvider> batchBlock) {
    _providers.batchAddObjects(batchBlock);
  }

  void addProvider(SpanControlProvider provider, {int priority = 50000}) {
    _providers.addObject(provider, priority: priority);
  }

  @override
  R? getSpanControl<R extends SpanControl>(SpanQuery<R> query) {
    for (final provider in _providers.objects) {
      final control = provider.getSpanControl<R>(query);
      if (control != null && control is R) {
        return control;
      }
    }
    return null;
  }
}
