import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_instrumentation_node.dart';
import 'package:flutter/widgets.dart';

class BugsnagLoadingIndicator extends StatefulWidget {
  const BugsnagLoadingIndicator({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  State<BugsnagLoadingIndicator> createState() =>
      _BugsnagLoadingIndicatorState();
}

class _BugsnagLoadingIndicatorState extends State<BugsnagLoadingIndicator> {
  NavigationInstrumentationNode? _node;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _node = NavigationInstrumentationNode.of(context);
    _node?.registerLoadingIndicator(this);
  }

  @override
  void dispose() {
    _node?.unregisterLoadingIndicator(this);
    super.dispose();
  }
}
