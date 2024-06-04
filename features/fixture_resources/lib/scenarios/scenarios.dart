import 'package:mazerunner/scenarios/auto_instrument_navigation_basic_defer_scenario.dart';
import 'package:mazerunner/scenarios/auto_instrument_navigation_basic_scenario.dart';
import 'package:mazerunner/scenarios/auto_instrument_navigation_complex_defer_scenario.dart';
import 'package:mazerunner/scenarios/auto_instrument_navigation_nested_navigation_scenario.dart';
import 'package:mazerunner/scenarios/auto_instrument_navigation_push_and_pop_scenario.dart';
import 'package:mazerunner/scenarios/auto_instrument_view_load_basic_defer_scenario.dart';
import 'package:mazerunner/scenarios/auto_instrument_view_load_basic_scenario.dart';
import 'package:mazerunner/scenarios/auto_instrument_view_load_nested_scenario.dart';

import 'auto_instrument_app_starts_scenario.dart';
import 'auto_instrument_navigation_with_view_load_scenario.dart';
import 'dio_callback_cancel_span.dart';
import 'dio_callback_edit_scenario.dart';
import 'initial_p_scenario.dart';
import 'manual_navigation_span_scenario.dart';
import 'manual_span_scenario.dart';
import 'probability_expiry_scenario.dart';
import 'start_sdk_default.dart';
import 'simple_nested_span_scenario.dart';
import 'new_zone_new_context_scenario.dart';
import 'pass_context_scenario.dart';
import 'make_current_context.dart';
import 'http_get_scenario.dart';
import 'http_post_scenario.dart';
import 'http_callback_edit_scenario.dart';
import 'http_callback_cancel_span.dart';
import 'dio_get_scenario.dart';
import 'dio_post_scenario.dart';
import 'http_get_multiple_subscribers_scenario.dart';
import 'max_batch_age_scenario.dart';
import 'dart_io_get_scenario.dart';
import 'custom_release_stage_scenario.dart';
import 'custom_enabled_release_stage_scenario.dart';
import 'disable_custom_release_stage_scenario.dart';
import 'custom_app_version_scenario.dart';
import 'manual_span_isfirstclass_false_scenario.dart';
import 'get_current_context_scenario.dart';
import 'check_network_callback_type_scenario.dart';
import 'custom_span_time_scenario.dart';
import 'span_with_no_parent_scenario.dart';
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
  ScenarioInfo('HttpGetScenario', () => HttpGetScenario()),
  ScenarioInfo('HttpPostScenario', () => HttpPostScenario()),
  ScenarioInfo('HttpCallbackEditScenario', () => HttpCallbackEditScenario()),
  ScenarioInfo(
      'HttpCallbackCancelSpan', () => HttpCallbackCancelSpanScenario()),
  ScenarioInfo('DIOGetScenario', () => DIOGetScenario()),
  ScenarioInfo('DIOPostScenario', () => DIOPostScenario()),
  ScenarioInfo('DIOCallbackCancelSpan', () => DIOCallbackCancelSpanScenario()),
  ScenarioInfo('DIOCallbackEditScenario', () => DIOCallbackEditScenario()),
  ScenarioInfo('HttpGetMultipleSubscribersScenario',
      () => HttpGetMultipleSubscribersScenario()),
  ScenarioInfo('AutoInstrumentNavigationBasicScenario',
      () => AutoInstrumentNavigationBasicScenario()),
  ScenarioInfo('MaxBatchAgeScenario', () => MaxBatchAgeScenario()),
  ScenarioInfo('DartIoGetScenario', () => DartIoGetScenario()),
  ScenarioInfo(
      'CustomReleaseStageScenario', () => CustomReleaseStageScenario()),
  ScenarioInfo('CustomEnabledReleaseStageScenario',
      () => CustomEnabledReleaseStageScenario()),
  ScenarioInfo('DisableCustomReleaseStageScenario',
      () => DisableCustomReleaseStageScenario()),
  ScenarioInfo('CustomAppVersionScenario', () => CustomAppVersionScenario()),
  ScenarioInfo('ManualSpanIsFirstClassFalseScenario',
      () => ManualSpanIsFirstClassFalseScenario()),
  ScenarioInfo('GetCurrentContextScenario', () => GetCurrentContextScenario()),
  ScenarioInfo('AutoInstrumentNavigationBasicDeferScenario',
      () => AutoInstrumentNavigationBasicDeferScenario()),
  ScenarioInfo('AutoInstrumentNavigationComplexDeferScenario',
      () => AutoInstrumentNavigationComplexDeferScenario()),
  ScenarioInfo('AutoInstrumentNavigationNestedNavigationScenario',
      () => AutoInstrumentNavigationNestedNavigationScenario()),
  ScenarioInfo('AutoInstrumentNavigationPushAndPopScenario',
      () => AutoInstrumentNavigationPushAndPopScenario()),
  ScenarioInfo('CheckNetworkCallbackTypeScenario',
      () => CheckNetworkCallbackTypeScenario()),
  ScenarioInfo('CustomSpanTimeScenario', () => CustomSpanTimeScenario()),
  ScenarioInfo('SpanWithNoParentScenario', () => SpanWithNoParentScenario()),
  ScenarioInfo(
      'ManualNavigationSpanScenario', () => ManualNavigationSpanScenario()),
  ScenarioInfo('AutoInstrumentViewLoadBasicScenario',
      () => AutoInstrumentViewLoadBasicScenario()),
  ScenarioInfo('AutoInstrumentViewLoadBasicDeferScenario',
      () => AutoInstrumentViewLoadBasicDeferScenario()),
  ScenarioInfo('AutoInstrumentViewLoadNestedScenario',
      () => AutoInstrumentViewLoadNestedScenario()),
  ScenarioInfo('AutoInstrumentNavigationWithViewLoadScenario',
      () => AutoInstrumentNavigationWithViewLoadScenario()),
];
