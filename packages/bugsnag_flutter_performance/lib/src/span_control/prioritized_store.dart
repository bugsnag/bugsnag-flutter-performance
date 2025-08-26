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
  List<T> _objects = [];

  List<T> get objects => List.unmodifiable(_objects);

  void addObject(T object, {int priority = 50000}) {
    batchAddObjects((addBlock) {
      addBlock(object, priority);
    });
  }

  void batchAddObjects(BatchBlock<T> batchBlock) {
    bool batchingInProgress = true;
    final temporaryStore = <PrioritizedStoreEntry<T>>[];

    batchBlock((object, priority) {
      if (!batchingInProgress) {
        return;
      }

      if (_uniqueObjects.contains(object)) {
        return;
      }

      for (final entry in temporaryStore) {
        if (entry.object == object) {
          return;
        }
      }

      temporaryStore.add(PrioritizedStoreEntry(object, priority));
    });

    batchingInProgress = false;

    _store.addAll(temporaryStore);
    _uniqueObjects.addAll(temporaryStore.map((e) => e.object));

    _sortStore();
    _updateObjects();
  }

  void _sortStore() {
    // Dart's sort is stable by default
    _store.sort((a, b) => b.priority.compareTo(a.priority));
  }

  void _updateObjects() {
    _objects = _store.map((entry) => entry.object).toList();
  }
}
