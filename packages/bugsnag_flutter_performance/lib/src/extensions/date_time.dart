extension DateTimeNanos on DateTime {
  int get nanosecondsSinceEpoch => (microsecondsSinceEpoch * 1000);
}
