import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_instrumentation_node.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/widget_instrumentation_state.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:bugsnag_flutter_performance/src/widgets/widget_instrumentation_node_provider.dart';
import 'package:flutter/widgets.dart';

class BugsnagNavigationContainer extends StatefulWidget {
  const BugsnagNavigationContainer({
    super.key,
    this.name,
    required this.child,
  });
  final Widget child;
  final String? name;

  @override
  State<BugsnagNavigationContainer> createState() =>
      _BugsnagNavigationContainerState();
}

class _BugsnagNavigationContainerState
    extends State<BugsnagNavigationContainer> {
  WidgetInstrumentationNode? _currentNode;

  @override
  Widget build(BuildContext context) {
    _currentNode?.dispose();
    final parentNode = WidgetInstrumentationNode.of(context);
    _currentNode = WidgetInstrumentationNode(
        state: WidgetInstrumentationState(
            name: widget.name ?? 'NavigationContainer',
            startTime: BugsnagClockImpl.instance.now()));
    parentNode.addChild(_currentNode!);
    return NavigationInstrumentationNodeProvider(
      node: _currentNode!,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _currentNode?.dispose();
    super.dispose();
  }
}
