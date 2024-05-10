import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/widget_instrumentation_node.dart';
import 'package:flutter/widgets.dart';

class WidgetInstrumentationNodeProvider extends InheritedWidget {
  const WidgetInstrumentationNodeProvider({
    super.key,
    required this.node,
    required super.child,
  });

  final WidgetInstrumentationNode node;

  @override
  bool updateShouldNotify(
      covariant WidgetInstrumentationNodeProvider oldWidget) {
    return oldWidget.node != node;
  }
}
