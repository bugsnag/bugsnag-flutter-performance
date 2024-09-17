import 'dart:math';

BigInt randomSpanId() {
  return randomValue(8);
}

BigInt randomTraceId() {
  return randomValue(16);
}

BigInt randomValue(int length) {
  final random = _Random();
  BigInt result = BigInt.from(random.nextInt(256) & 0xff);
  for (var i = 1; i < length; i++) {
    int byte = random.nextInt(256);
    result = (result << 8) | BigInt.from(byte & 0xff);
  }
  return result;
}

class _Random {
  static final _sharedRandom = Random();
  late final Random? _secureRandom;

  _Random() {
    try {
      _secureRandom = Random.secure();
    } catch (e) {
      // deliberately ignored
    }
  }

  int nextInt(int max) {
    try {
      if (_secureRandom != null) {
        return _secureRandom!.nextInt(max);
      }
    } catch (e) {
      // deliberately ignored
    }
    return _sharedRandom.nextInt(max);
  }
}
