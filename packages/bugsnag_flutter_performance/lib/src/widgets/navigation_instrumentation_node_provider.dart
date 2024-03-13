import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_instrumentation_node.dart';
import 'package:flutter/widgets.dart';

class NavigationInstrumentationNodeProvider extends InheritedWidget {
  const NavigationInstrumentationNodeProvider({
    super.key,
    required this.node,
    required super.child,
  });

  final NavigationInstrumentationNode node;

  @override
  bool updateShouldNotify(
      covariant NavigationInstrumentationNodeProvider oldWidget) {
    return oldWidget.node != node;
  }
}
