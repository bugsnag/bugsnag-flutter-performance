extension IntToNanos on int {
  DateTime get timeFromNanos =>
      DateTime.fromMicrosecondsSinceEpoch(this ~/ 1000);
}
