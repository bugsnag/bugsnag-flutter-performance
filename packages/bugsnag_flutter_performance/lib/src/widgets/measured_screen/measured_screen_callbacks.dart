import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_state.dart';

typedef ScreenStateCallback = void Function(ScreenInstrumentationState state);
typedef ScreenStateLoadingCallback = void
    Function(ScreenInstrumentationState state, {required bool isLoading});

final measuredScreenCallbacks = MeasuredScreenCallbacks();

class MeasuredScreenCallbacks {
  ScreenStateCallback? didStartBuildingScreenCallback;
  ScreenStateCallback? didFinishBuildingScreenCallback;
  ScreenStateLoadingCallback? didShowScreenCallback;
  ScreenStateCallback? didFinishLoadingScreenCallback;

  void didStartBuildingScreen(ScreenInstrumentationState state) {
    if (didStartBuildingScreenCallback == null) {
      return;
    }
    didStartBuildingScreenCallback!(state);
  }

  void didFinishBuildingScreen(ScreenInstrumentationState state) {
    if (didFinishBuildingScreenCallback == null) {
      return;
    }
    didFinishBuildingScreenCallback!(state);
  }

  void didShowScreen(
    ScreenInstrumentationState state, {
    required bool isLoading,
  }) {
    if (didShowScreenCallback == null) {
      return;
    }
    didShowScreenCallback!(state, isLoading: isLoading);
  }

  void didFinishLoadingScreen(ScreenInstrumentationState state) {
    if (didFinishLoadingScreenCallback == null) {
      return;
    }
    didFinishLoadingScreenCallback!(state);
  }

  void setup({
    ScreenStateCallback? didStartBuildingScreenCallback,
    ScreenStateCallback? didFinishBuildingScreenCallback,
    ScreenStateLoadingCallback? didShowScreenCallback,
    ScreenStateCallback? didFinishLoadingScreenCallback,
  }) {
    if (didStartBuildingScreenCallback != null) {
      this.didStartBuildingScreenCallback = didStartBuildingScreenCallback;
    }
    if (didFinishBuildingScreenCallback != null) {
      this.didFinishBuildingScreenCallback = didFinishBuildingScreenCallback;
    }
    if (didShowScreenCallback != null) {
      this.didShowScreenCallback = didShowScreenCallback;
    }
    if (didFinishLoadingScreenCallback != null) {
      this.didFinishLoadingScreenCallback = didFinishLoadingScreenCallback;
    }
  }
}
