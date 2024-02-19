import 'package:flutter/widgets.dart';

class BugsnagLifecycleListener with WidgetsBindingObserver {
  static final BugsnagLifecycleListener _instance =
      BugsnagLifecycleListener._internal();
  void Function()? _onAppBackgrounded;

  factory BugsnagLifecycleListener() => _instance;

  BugsnagLifecycleListener._internal();

  void startObserving(void Function() onAppBackgrounded) {
    _onAppBackgrounded = onAppBackgrounded;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _onAppBackgrounded?.call();
    }
  }
}
