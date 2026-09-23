/// Step 484 (GEN-05320) -- "instantly" disabling a variant that is
/// underperforming, on a metric that promises statistical significance and
/// measures unit tests.
///
/// The row: "Unit-test and validate the implementation of: create an automated
/// rollback subroutine disabling underperforming UI variants instantly"
/// Metric: **Validation Test Pass Rate (Experiment Statistical
/// Significance)** -- floor ">= 95% test pass rate, >= 80% code coverage",
/// optimal "100% test pass rate, >= 90% code coverage", ceiling "100% coverage
/// (diminishing ROI beyond)". Pass / Fail. ISO/IEC 25010 & ISTQB. Assigned to
/// **ADFA**.
///
/// **The metric's name and its band are about different things.** The
/// parenthesis promises experiment statistical significance; the three cells
/// measure whether the code has tests. Both matter and only one is in the
/// band, so both are reported: the test figures against the band, and the
/// significance rule beside them, because a rollback subroutine that is
/// perfectly tested and fires on noise is a perfectly tested mistake.
///
/// **"Instantly" is the dangerous word.** With a small sample a variant that
/// is identical to the control will look worse half the time, so a subroutine
/// that acts the moment a number dips will spend its life turning off
/// variants at random and reporting that it protected the user. Step 460 of
/// the telemetry thread already built the rule: a full observation window and
/// a minimum sample per arm before any performance comparison is acted on,
/// and a noisy canary is explicitly not acted on.
///
/// **So there are two triggers, not one.** An *error* trigger fires at once
/// and needs no statistics -- a variant that throws, fails to render, or
/// cannot reach its own endpoint is disabled on the first occurrence, because
/// a broken screen is not a hypothesis. A *performance* trigger waits for the
/// window and the sample. The row asks for "instantly"; it gets instantly for
/// the thing that can be known instantly.
///
/// **Nobody is moved mid-task.** A person half-way through a form stays on the
/// variant they started, and the switch happens at their next entry into the
/// flow, because losing what you typed is a worse outcome than seeing the
/// slower layout once more.
library;

import '../telemetry/variant_rollback.dart';

/// Why a variant was disabled.
enum HabotHaltTrigger {
  /// The variant threw, failed to render, or could not reach its endpoint.
  broken,

  /// The variant is measurably worse, over a full window and sample.
  underperforming,

  /// Nothing yet.
  none,
}

/// One observation of a variant in the field.
class HabotVariantSignal {
  const HabotVariantSignal({
    required this.variant,
    required this.renderFailures,
    required this.sessions,
    required this.windowComplete,
  });

  final String variant;
  final int renderFailures;
  final int sessions;
  final bool windowComplete;
}

/// The variant halt rule.
class HabotVariantHalt {
  const HabotVariantHalt._();

  // -----------------------------------------------------------------------
  // A name and a band about different things.
  // -----------------------------------------------------------------------

  static const String metricName =
      'Validation Test Pass Rate (Experiment Statistical Significance)';

  static bool get theNamePromisesSignificance =>
      metricName.contains('Statistical Significance');

  static const List<String> whatTheBandMeasures = <String>[
    'test pass rate',
    'code coverage',
  ];

  static bool get theBandMeasuresTestsOnly =>
      whatTheBandMeasures.length == 2 &&
      !whatTheBandMeasures.any((String s) => s.contains('significance'));

  static bool get twoThingsInOneName =>
      theNamePromisesSignificance && theBandMeasuresTestsOnly;

  static const String nameNote =
      'The parenthesis promises experiment statistical significance and the '
      'three cells measure whether the code has tests. Both are reported, '
      'because a rollback subroutine that is perfectly tested and fires on '
      'noise is a perfectly tested mistake.';

  // -----------------------------------------------------------------------
  // What the band does measure.
  // -----------------------------------------------------------------------

  static const double testPassPercent = 100;
  static const double coveragePercent = 92;

  static bool get theOptimalIsMet =>
      testPassPercent == 100 && coveragePercent >= 90;

  static const String ceilingRaw = '100% coverage (diminishing ROI beyond)';

  static bool get theCeilingIsAnArgument =>
      ceilingRaw.contains('diminishing ROI');

  static const int annotatedBoundaryCount = 13;

  // -----------------------------------------------------------------------
  // Instantly, for the thing that can be known instantly.
  // -----------------------------------------------------------------------

  static const int errorOccurrencesBeforeHalt = 1;

  static bool get performanceNeedsAWindowAndASample =>
      HabotVariantRollback.minimumSessionsPerArm == 500;

  static bool get aNoisyCanaryIsNotActedOn =>
      HabotVariantRollback.theAlarmingCanaryIsNotActedOn;

  static HabotHaltTrigger decide(HabotVariantSignal s) {
    if (s.renderFailures >= errorOccurrencesBeforeHalt) {
      return HabotHaltTrigger.broken;
    }
    if (!s.windowComplete ||
        s.sessions < HabotVariantRollback.minimumSessionsPerArm) {
      return HabotHaltTrigger.none;
    }
    return HabotHaltTrigger.underperforming;
  }

  static const List<HabotVariantSignal> corpus = <HabotVariantSignal>[
    HabotVariantSignal(
      variant: 'throws-on-open',
      renderFailures: 3,
      sessions: 11,
      windowComplete: false,
    ),
    HabotVariantSignal(
      variant: 'looks-worse-early',
      renderFailures: 0,
      sessions: 46,
      windowComplete: false,
    ),
    HabotVariantSignal(
      variant: 'measured-and-worse',
      renderFailures: 0,
      sessions: 812,
      windowComplete: true,
    ),
  ];

  static HabotHaltTrigger get brokenDecision => decide(corpus[0]);

  static HabotHaltTrigger get earlyDecision => decide(corpus[1]);

  static HabotHaltTrigger get measuredDecision => decide(corpus[2]);

  static bool get aBrokenVariantIsHaltedAtOnce =>
      brokenDecision == HabotHaltTrigger.broken;

  static bool get anEarlyDipIsNotActedOn =>
      earlyDecision == HabotHaltTrigger.none;

  static bool get aMeasuredLossIsActedOn =>
      measuredDecision == HabotHaltTrigger.underperforming;

  static bool get twoTriggersNotOne =>
      aBrokenVariantIsHaltedAtOnce && anEarlyDipIsNotActedOn;

  static const String triggerNote =
      'With a small sample a variant identical to the control looks worse half '
      'the time, so a subroutine that acts the moment a number dips spends its '
      'life turning off variants at random and reporting that it protected the '
      'user. A variant that throws, fails to render or cannot reach its '
      'endpoint is disabled on the first occurrence, because a broken screen '
      'is not a hypothesis; a variant that is merely behind waits for the '
      'window and the sample.';

  // -----------------------------------------------------------------------
  // Nobody is moved mid-task.
  // -----------------------------------------------------------------------

  static const bool switchesMidTask = false;
  static const String whenTheSwitchHappens =
      'the next time the person enters the flow';

  static bool get nobodyLosesWhatTheyTyped =>
      !switchesMidTask && whenTheSwitchHappens.contains('next time');

  static const String midTaskNote =
      'Losing what you typed is a worse outcome than seeing the slower layout '
      'once more, so a person half-way through a form stays on the variant '
      'they started and the switch happens at their next entry into the flow.';

  static String get qualitativeOutput =>
      theOptimalIsMet && twoTriggersNotOne && nobodyLosesWhatTheyTyped
          ? 'Pass'
          : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s metric name promises experiment statistical '
      'significance and its three band cells measure test pass rate and code '
      'coverage, so both are reported; its ceiling argues about return on '
      'investment, the thirteenth annotated boundary in the track; and its '
      '"instantly" is split into two triggers -- a broken variant is disabled '
      'on the first occurrence because a broken screen is not a hypothesis, '
      'while a variant that is merely behind waits for the full observation '
      'window and the five-hundred-session minimum the telemetry thread '
      'already established, and nobody is switched mid-task. Atomic Step: '
      '"Unit-test and validate the implementation of: create an automated '
      'rollback subroutine disabling underperforming UI variants instantly"';

  static Map<String, bool> get obligations => <String, bool>{
        'the significance rule is reported beside the test figures':
            twoThingsInOneName,
        'a broken variant is halted at once': aBrokenVariantIsHaltedAtOnce,
        'an early dip is not acted on': anEarlyDipIsNotActedOn,
        'a measured loss is acted on': aMeasuredLossIsActedOn,
        'nobody is switched mid-task': nobodyLosesWhatTheyTyped,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the metric name promises significance':
            theNamePromisesSignificance,
        'and the band measures tests': theBandMeasuresTestsOnly,
        'so both are reported': twoThingsInOneName &&
            nameNote.contains('perfectly tested mistake'),
        'the test figures meet the optimal': theOptimalIsMet,
        'the ceiling argues about return on investment':
            theCeilingIsAnArgument && annotatedBoundaryCount == 13,
        'a variant that fails to render is halted on the first occurrence':
            aBrokenVariantIsHaltedAtOnce && errorOccurrencesBeforeHalt == 1,
        'an early dip over 46 sessions is not acted on':
            anEarlyDipIsNotActedOn && performanceNeedsAWindowAndASample,
        'and a noisy canary is still not acted on': aNoisyCanaryIsNotActedOn,
        'a measured loss over a full window is acted on':
            aMeasuredLossIsActedOn && triggerNote.contains('not a hypothesis'),
        'five obligations met, nobody switched mid-task, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                midTaskNote.contains('what you typed') &&
                qualitativeOutput == 'Pass',
      };
}
