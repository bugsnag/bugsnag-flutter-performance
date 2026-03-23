/// Ring buffer for storing items with a fixed capacity
class RingBuffer<T> {
  final List<T?> _buffer;
  final int capacity;
  int _head = 0;
  int _size = 0;

  RingBuffer({required this.capacity})
      : _buffer = List<T?>.filled(capacity, null);

  void push(T item) {
    _buffer[_head] = item;
    _head = (_head + 1) % capacity;
    if (_size < capacity) {
      _size++;
    }
  }

  Iterable<T> get items sync* {
    if (_size == 0) return;

    final start = _size < capacity ? 0 : _head;
    for (var i = 0; i < _size; i++) {
      final index = (start + i) % capacity;
      final item = _buffer[index];
      if (item != null) {
        yield item;
      }
    }
  }

  int get length => _size;

  void clear() {
    _buffer.fillRange(0, capacity, null);
    _head = 0;
    _size = 0;
  }
}
