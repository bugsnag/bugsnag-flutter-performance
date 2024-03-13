import 'dart:math';

import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_instrumentation_node.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_state.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:bugsnag_flutter_performance/src/widgets/measured_screen/measured_screen_callbacks.dart';
import 'package:bugsnag_flutter_performance/src/widgets/navigation_instrumentation_node_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class MeasuredScreen extends StatefulWidget {
  const MeasuredScreen({
    required super.key,
    required this.name,
    required this.builder,
  });
  final String name;
  final Widget Function(BuildContext) builder;

  @override
  State<MeasuredScreen> createState() => _MeasuredScreenState();
}

class _MeasuredScreenState extends State<MeasuredScreen> {
  ScreenInstrumentationState? _state;

  @override
  Widget build(BuildContext context) {
    final parentNode = NavigationInstrumentationNode.of(context);
    if (parentNode.currentlyLoadedRoute != null) {
      parentNode.isLoadingPhasedRoute = true;
    }
    var node = parentNode.child(widget.name);

    final state = node?.state ??
        _state ??
        ScreenInstrumentationState(
          name: widget.name,
          startTime: BugsnagClockImpl.instance.now(),
          parent: parentNode.state,
        );
    if (node == null) {
      node = NavigationInstrumentationNode(state: state);
      parentNode.addChild(node);
    }

    measuredScreenCallbacks.didStartBuildingScreen(state);
    final body = widget.builder(context);
    measuredScreenCallbacks.didFinishBuildingScreen(state);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final isLoading = node!.isLoading();
      measuredScreenCallbacks.didShowScreen(state, isLoading: isLoading);
      print('Is loading: $isLoading');
      if (isLoading) {
        node.addDidFinishLoadingCallback(() {
          print('Finish loading callback');
          measuredScreenCallbacks.didFinishLoadingScreen(state);
        });
      }
    });
    return NavigationInstrumentationNodeProvider(
      key: Key(widget.name),
      node: node,
      child: body,
    );
  }
}
