abstract class BugsnagClock {
  DateTime now();
}

class BugsnagClockImpl implements BugsnagClock {
  static BugsnagClockImpl get instance => _instance!;
  static BugsnagClockImpl? _instance;

  final _clock = Stopwatch()..start();
  final _initTime = DateTime.now();

  @override
  DateTime now() {
    return _initTime.add(_clock.elapsed);
  }

  static BugsnagClock ensureInitialized() {
    _instance = _instance ?? BugsnagClockImpl();
    return instance;
  }
}
