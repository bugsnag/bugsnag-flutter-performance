import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_instrumentation_node.dart';
import 'package:flutter/widgets.dart';

class BugsnagLoadingIndicator extends StatefulWidget {
  const BugsnagLoadingIndicator({
    super.key,
    this.child = const Text(''),
  });
  final Widget child;

  @override
  State<BugsnagLoadingIndicator> createState() =>
      _BugsnagLoadingIndicatorState();
}

class _BugsnagLoadingIndicatorState extends State<BugsnagLoadingIndicator> {
  WidgetInstrumentationNode? _node;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _node = WidgetInstrumentationNode.of(context);
    _node?.registerLoadingIndicator(this);
  }

  @override
  void dispose() {
    _node?.unregisterLoadingIndicator(this);
    super.dispose();
  }
}
