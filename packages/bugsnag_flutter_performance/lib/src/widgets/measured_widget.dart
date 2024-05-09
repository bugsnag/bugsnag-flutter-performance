import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/widget_instrumentation_node.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/widget_instrumentation_state.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/view_load/measured_widget_callbacks.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/view_load/view_load_instrumentation_state.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:bugsnag_flutter_performance/src/widgets/widget_instrumentation_node_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MeasuredWidget extends StatefulWidget {
  const MeasuredWidget({
    super.key,
    required this.name,
    required this.builder,
  });

  final String name;
  final Widget Function(BuildContext) builder;

  @override
  State<MeasuredWidget> createState() => _MeasuredWidgetState();
}

class _MeasuredWidgetState extends State<MeasuredWidget> {
  WidgetInstrumentationNode? _currentNode;

  @override
  Widget build(BuildContext context) {
    _currentNode?.dispose();
    final parentNode = WidgetInstrumentationNode.of(context);
    final newNode = WidgetInstrumentationNode(
      state: WidgetInstrumentationState(
        name: widget.name,
        startTime: BugsnagClockImpl.instance.now(),
      ),
    );
    _currentNode = newNode;
    parentNode.addChild(newNode);
    return WidgetInstrumentationNodeProvider(
      node: newNode,
      child: _MeasuredWidgetContent(
        name: widget.name,
        builder: widget.builder,
      ),
    );
  }

  @override
  void dispose() {
    _currentNode?.dispose();
    super.dispose();
  }
}

class _MeasuredWidgetContent extends StatefulWidget {
  const _MeasuredWidgetContent({
    required this.name,
    required this.builder,
  });

  final String name;
  final Widget Function(BuildContext) builder;

  @override
  State<_MeasuredWidgetContent> createState() => _MeasuredWidgetContentState();

  @override
  StatefulElement createElement() {
    return _MeasuredWidgetContentElement(this);
  }
}

class _MeasuredWidgetContentState extends State<_MeasuredWidgetContent> {
  ViewLoadInstrumentationState? _state;

  @override
  Widget build(BuildContext context) {
    _state ??= ViewLoadInstrumentationState(
      name: widget.name,
      startTime: BugsnagClockImpl.instance.now(),
    );
    measuredWidgetCallbacks.willBuildWidget(
      state: _state!,
      context: context,
    );
    return widget.builder(context);
  }
}

class _MeasuredWidgetContentElement extends StatefulElement {
  _MeasuredWidgetContentElement(super.widget);

  var didBuild = false;

  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    final result = super.updateChild(child, newWidget, newSlot);
    final instrumentationState = (state as _MeasuredWidgetContentState)._state;
    if (didBuild || instrumentationState == null) {
      return result;
    }
    measuredWidgetCallbacks.didBuildWidget(
      state: instrumentationState,
      context: this,
    );
    didBuild = true;
    return result;
  }
}
