import 'package:bugsnag_flutter_performance/bugsnag_flutter_performance.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/widget_instrumentation_state.dart';
import 'package:bugsnag_flutter_performance/src/widgets/widget_instrumentation_node_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

typedef DidFinishLoadingCallback = void Function();
final appRootInstrumentationNode = WidgetInstrumentationNode();

class WidgetInstrumentationNode {
  WidgetInstrumentationNode({
    this.state,
  });
  WidgetInstrumentationState? state;
  WidgetInstrumentationNode? _parent;
  final List<DidFinishLoadingCallback> _didFinishLoadingCallbacks = [];
  final Set<State<BugsnagLoadingIndicator>> _loadingIndicators = {};
  final List<WidgetInstrumentationNode> _children = [];

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
    if (_parent != null) {
      _parent!.registerLoadingIndicator(loadingIndicator);
    }
  }

  void unregisterLoadingIndicator(
      State<BugsnagLoadingIndicator> loadingIndicator) {
    _loadingIndicators.remove(loadingIndicator);
    if (_parent != null) {
      _parent!.unregisterLoadingIndicator(loadingIndicator);
    }
  }

  void addChild(WidgetInstrumentationNode node) {
    node._parent = this;
    _children.add(node);
  }

  void removeChild(WidgetInstrumentationNode node) {
    _children.remove(node);
  }

  WidgetInstrumentationNode? child(String name) {
    final namedIndex =
        _children.indexWhere((element) => element.state?.name == name);
    return namedIndex != -1 ? _children[namedIndex] : null;
  }

  void dispose() {
    _parent?.removeChild(this);
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
    for (final element in _didFinishLoadingCallbacks) {
      element();
    }
    _didFinishLoadingCallbacks.clear();
  }

  static WidgetInstrumentationNode of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<
        NavigationInstrumentationNodeProvider>();
    return widget != null ? widget.node : appRootInstrumentationNode;
  }
}
