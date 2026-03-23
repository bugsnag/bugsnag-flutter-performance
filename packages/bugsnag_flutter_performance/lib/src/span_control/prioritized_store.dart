typedef AddBlock<T> = void Function(T object, int priority);
typedef BatchBlock<T> = void Function(AddBlock<T> addBlock);

class PrioritizedStoreEntry<T> {
  final T object;
  final int priority;
  PrioritizedStoreEntry(this.object, this.priority);
}

class PrioritizedStore<T> {
  final List<PrioritizedStoreEntry<T>> _store = [];
  final Set<T> _uniqueObjects = {};

  Iterable<T> get objects => _store.map((e) => e.object);

  void addObject(T object, {int priority = 50000}) {
    batchAddObjects((add) => add(object, priority));
  }

  void batchAddObjects(BatchBlock<T> batchBlock) {
    bool batchingInProgress = true;
    final temporaryStore = <PrioritizedStoreEntry<T>>[];

    batchBlock((object, priority) {
      if (!batchingInProgress) return;
      if (_uniqueObjects.contains(object)) return;
      for (final entry in temporaryStore) {
        if (entry.object == object) return;
      }
      temporaryStore.add(PrioritizedStoreEntry(object, priority));
    });

    batchingInProgress = false;

    _store.addAll(temporaryStore);
    _uniqueObjects.addAll(temporaryStore.map((e) => e.object));
    _sortStore();
  }

  void _sortStore() {
    _store.sort((a, b) => b.priority.compareTo(a.priority));
  }
}
