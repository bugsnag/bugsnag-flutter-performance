import 'auto_instrument_app_starts_scenario.dart';
import 'initial_p_scenario.dart';
import 'manual_span_scenario.dart';
import 'probability_expiry_scenario.dart';
import 'start_sdk_default.dart';
import 'simple_nested_span_scenario.dart';
import 'new_zone_new_context_scenario.dart';
import 'pass_context_scenario.dart';
import 'make_current_context.dart';
import 'http_get_scenario.dart';
import 'scenario.dart';

class ScenarioInfo<T extends Scenario> {
  const ScenarioInfo(this.name, this.init);
  final String name;
  final Scenario Function() init;
}

// Flutter obfuscation *requires* that we specify the name as a raw String in order to match the runtime class
final List<ScenarioInfo<Scenario>> scenarios = [
  ScenarioInfo('ManualSpanScenario', () => ManualSpanScenario()),
  ScenarioInfo('StartSdkDefault', () => StartSdkDefault()),
  ScenarioInfo('InitialPScenario', () => InitialPScenario()),
  ScenarioInfo('ProbabilityExpiryScenario', () => ProbabilityExpiryScenario()),
  ScenarioInfo('SimpleNestedSpanScenario', () => SimpleNestedSpanScenario()),
  ScenarioInfo('NewZoneNewContextScenario', () => NewZoneNewContextScenario()),
  ScenarioInfo(
      'PassContextToNewZoneScenario', () => PassContextToNewZoneScenario()),
  ScenarioInfo(
      'MakeCurrentContextScenario', () => MakeCurrentContextScenario()),
  ScenarioInfo('AutoInstrumentAppStartsScenario',
      () => AutoInstrumentAppStartsScenario()),
  ScenarioInfo('HttpGetScenario', () => HttpGetScenario())

];
