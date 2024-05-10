import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/widget_instrumentation_node.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/widget_instrumentation_state.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/view_load/measured_widget_callbacks.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/view_load/view_load_instrumentation_state.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:bugsnag_flutter_performance/src/widgets/widget_instrumentation_node_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MeasuredWidget extends StatelessWidget {
  const MeasuredWidget({
    super.key,
    required this.name,
    required this.builder,
  });

  final String name;
  final Widget Function(BuildContext) builder;

  @override
  Widget build(BuildContext context) {
    if (context is _MeasuredWidgetElement) {
      context._currentNode?.dispose();
      final parentNode = WidgetInstrumentationNode.of(context);
      final newNode = WidgetInstrumentationNode(
        state: WidgetInstrumentationState(
          name: name,
          startTime: BugsnagClockImpl.instance.now(),
        ),
      );
      context._currentNode = newNode;
      parentNode.addChild(newNode);
      return WidgetInstrumentationNodeProvider(
        node: newNode,
        child: _MeasuredWidgetContent(
          name: name,
          builder: builder,
        ),
      );
    } else {
      return builder(context);
    }
  }

  @override
  StatelessElement createElement() {
    return _MeasuredWidgetElement(this);
  }
}

class _MeasuredWidgetElement extends StatelessElement {
  _MeasuredWidgetElement(super.widget);

  WidgetInstrumentationNode? _currentNode;

  @override
  void unmount() {
    _currentNode?.dispose();
    super.unmount();
  }
}

class _MeasuredWidgetContent extends StatelessWidget {
  const _MeasuredWidgetContent({
    required this.name,
    required this.builder,
  });

  final String name;
  final Widget Function(BuildContext) builder;

  @override
  Widget build(BuildContext context) {
    if (context is _MeasuredWidgetContentElement) {
      context._state ??= ViewLoadInstrumentationState(
        name: name,
        startTime: BugsnagClockImpl.instance.now(),
      );
      measuredWidgetCallbacks.willBuildWidget(
        state: context._state!,
        context: context,
      );
    }
    return builder(context);
  }

  @override
  StatelessElement createElement() {
    return _MeasuredWidgetContentElement(this);
  }
}

class _MeasuredWidgetContentElement extends StatelessElement {
  _MeasuredWidgetContentElement(super.widget);

  ViewLoadInstrumentationState? _state;
  var didBuild = false;

  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    final result = super.updateChild(child, newWidget, newSlot);
    if (didBuild || _state == null) {
      return result;
    }
    measuredWidgetCallbacks.didBuildWidget(
      state: _state!,
      context: this,
    );
    didBuild = true;
    return result;
  }
}
