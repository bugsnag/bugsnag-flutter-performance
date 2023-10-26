import 'package:flutter/foundation.dart';

abstract class BugsnagClock {
  DateTime now();
}

class BugsnagClockImpl extends BindingBase implements BugsnagClock {
  static BugsnagClockImpl get instance => BindingBase.checkInstance(_instance);
  static BugsnagClockImpl? _instance;

  final _clock = Stopwatch()..start();
  final _initTime = DateTime.now();

  BugsnagClockImpl() {
    _clock.start();
  }

  @override
  DateTime now() {
    return _initTime.add(_clock.elapsed);
  }

  static BugsnagClock ensureInitialized() {
    if (_instance == null) {
      BugsnagClockImpl();
    }
    return instance;
  }

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }
}
