import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_state.dart';
import 'package:bugsnag_flutter_performance/src/widgets/navigation_instrumentation_node_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

typedef DidFinishLoadingCallback = void Function();
final appRootNavigationNode = NavigationInstrumentationNode();

class NavigationInstrumentationNode {
  NavigationInstrumentationNode({
    this.state,
  });
  ScreenInstrumentationState? state;
  DateTime? routeLoadStartTime;
  Route? currentlyLoadedRoute;
  bool isLoadingPhasedRoute = false;
  final List<DidFinishLoadingCallback> _didFinishLoadingCallbacks = [];
  final Set<State<BugsnagLoadingIndicator>> _loadingIndicators = {};
  final List<NavigationInstrumentationNode> _children = [];

  bool isLoading() {
    return _loadingIndicators.where((element) => element.mounted).isNotEmpty;
  }

  void addDidFinishLoadingCallback(DidFinishLoadingCallback callback) {
    if (_didFinishLoadingCallbacks.isEmpty) {
      _waitForNextFrameAndCheckIfLoading();
    }
    _didFinishLoadingCallbacks.add(callback);
  }

  void registerLoadingIndicator(
      State<BugsnagLoadingIndicator> loadingIndicator) {
    _loadingIndicators.add(loadingIndicator);
  }

  void unregisterLoadingIndicator(
      State<BugsnagLoadingIndicator> loadingIndicator) {
    _loadingIndicators.remove(loadingIndicator);
  }

  void addChild(NavigationInstrumentationNode node) {
    _children.add(node);
  }

  NavigationInstrumentationNode? child(String name) {
    final nodes = _children.where((element) => element.state?.name == name);
    return nodes.isNotEmpty ? nodes.first : null;
  }

  void _waitForNextFrameAndCheckIfLoading() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (isLoading()) {
        _waitForNextFrameAndCheckIfLoading();
      } else {
        _didFinishLoading();
      }
    });
  }

  void _didFinishLoading() {
    for (var element in _didFinishLoadingCallbacks) {
      element();
    }
    _didFinishLoadingCallbacks.clear();
  }

  static NavigationInstrumentationNode of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<
        NavigationInstrumentationNodeProvider>();
    return widget != null ? widget.node : appRootNavigationNode;
  }
}
