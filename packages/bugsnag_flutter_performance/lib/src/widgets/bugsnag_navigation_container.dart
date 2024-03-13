import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_instrumentation_node.dart';
import 'package:bugsnag_flutter_performance/src/instrumentation/navigation/navigation_state.dart';
import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:bugsnag_flutter_performance/src/widgets/navigation_instrumentation_node_provider.dart';
import 'package:flutter/widgets.dart';

class BugsnagNavigationContainer extends StatelessWidget {
  const BugsnagNavigationContainer({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NavigationInstrumentationNodeProvider(
      node: NavigationInstrumentationNode(
          state: ScreenInstrumentationState(
              name: 'NavigationContainer',
              startTime: BugsnagClockImpl.instance.now())),
      child: child,
    );
  }
}
