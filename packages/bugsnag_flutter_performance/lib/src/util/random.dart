import 'dart:math';

BigInt randomSpanId() {
  return randomValue(8, false);
}

BigInt randomTraceId() {
  return randomValue(16, true);
}

BigInt randomValue(int length, bool secure) {
  final random = _Random(secure);
  BigInt result = BigInt.from(random.nextInt(256) & 0xff);
  for (var i = 1; i < length; i++) {
    int byte = random.nextInt(256);
    result = (result << 8) | BigInt.from(byte & 0xff);
  }
  return result;
}

class _Random {
  static final _sharedRandom = _createSharedRandom();
  late final Random? _secureRandom;
  final bool secure;

  _Random(this.secure) {
    try {
      if (secure) {
        _secureRandom = Random.secure();
      }
    } catch (_) {
      // If the platform doesn't provide a secure random source then we fall back on a less secure version
    }
  }

  int nextInt(int max) {
    try {
      if (_secureRandom != null) {
        return _secureRandom!.nextInt(max);
      }
    } catch (_) {
      // When the system runs out of entropy, we fall back on a less secure random number source
      // Although the documentation doesn't mention it, nextInt can throw
    }
    return _sharedRandom.nextInt(max);
  }

  static Random _createSharedRandom() {
    try {
      final secureRandom = Random.secure();
      return Random(secureRandom.nextInt(1 << 32));
    } catch (_) {
      return Random();
    }
  }
}
