import 'package:flutter/foundation.dart';

abstract class BugsnagClock {
  DateTime now();
}

class BugsnagClockImpl extends BindingBase implements BugsnagClock {
  static BugsnagClockImpl get instance => BindingBase.checkInstance(_instance);
  static BugsnagClockImpl? _instance;

  final clock = Stopwatch();
  final initTime = DateTime.now();

  BugsnagClockImpl() {
    clock.start();
  }

  @override
  DateTime now() {
    return initTime.add(clock.elapsed);
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
