import 'dart:math';

BigInt randomSpanId() {
  return randomValue(8);
}

BigInt randomTraceId() {
  return randomValue(16);
}

BigInt randomValue(int length) {
  BigInt result = BigInt.zero;
  final random = Random.secure();
  for (var i = 0; i < length; i++) {
    int byte = random.nextInt(256);
    result = (result << 8) | BigInt.from(byte & 0xff);
  }
  return result;
}
