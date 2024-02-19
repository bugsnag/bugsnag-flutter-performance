import 'package:flutter/widgets.dart';

abstract class BugsnagLifecycleListener {
  void startObserving(void Function() onAppBackgrounded);
}

class BugsnagLifecycleListenerImpl
    with WidgetsBindingObserver
    implements BugsnagLifecycleListener {
  static BugsnagLifecycleListenerImpl get instance => _instance!;
  static BugsnagLifecycleListenerImpl? _instance;

  void Function()? _onAppBackgrounded;

  static BugsnagLifecycleListener ensureInitialized() {
    _instance = _instance ?? BugsnagLifecycleListenerImpl();
    return instance;
  }

  @override
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
