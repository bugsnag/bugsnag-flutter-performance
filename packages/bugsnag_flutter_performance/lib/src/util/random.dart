import 'dart:math';

BigInt randomSpanId() {
  return randomValue(8);
}

BigInt randomTraceId() {
  return randomValue(16);
}

BigInt randomValue(int length) {
  final random = Random.secure();
  BigInt result = BigInt.from(random.nextInt(256) & 0xff);
  for (var i = 1; i < length; i++) {
    int byte = random.nextInt(256);
    result = (result << 8) | BigInt.from(byte & 0xff);
  }
  return result;
}
