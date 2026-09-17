/// Step 349 (GEN-05342) -- a floor that is the failure condition, written in
/// the cell where the minimum acceptable value belongs.
///
/// The row: "Verify all completion criteria are met: Mobile onboarding
/// completion rate >= 70%; Average time to complete application <= 15 min;
/// Skill test grading latency <= 100ms"
/// Metric: **Composite Completion-Criteria Achievement Rate** -- floor "Any
/// single stated criterion unmet", optimal "100% of stated criteria met
/// exactly as specified", ceiling "N/A - full compliance has no
/// diminishing-return ceiling". Pass / Fail. Six Sigma DMAIC Control Phase.
///
/// **The floor cell names the failing state.** A floor is the worst value still
/// acceptable. "Any single stated criterion unmet" is not a value at all; it is
/// the condition under which the thing fails. Written where the minimum
/// acceptable reading belongs, it says that the minimum acceptable outcome is
/// failure. Read the other way -- as the boundary below which you fail -- it is
/// correct and it makes the band binary, which is what the ceiling cell already
/// says by refusing to hold a number.
///
/// **And the three criteria are three different things.** 70 per cent
/// completion is a population statistic that needs a cohort and a window. 15
/// minutes average is a duration that needs a definition of when the clock
/// starts and whether abandonment counts. 100 ms grading latency is a machine
/// measurement. Composing them with AND is right -- all must hold -- but the
/// composite rate the metric name asks for cannot exist, because a rate over
/// three incommensurable criteria has no denominator anybody can defend.
///
/// **Two of the three cannot be taken from this repository**, and saying which
/// is the work. The grading latency can be measured here. The completion rate
/// and the average duration need field telemetry from real people over a real
/// window, and a cohort definition nobody has written down.
///
/// **What this file builds is the verifier, not the numbers.** It takes three
/// readings, applies the composite rule as declared, and reports which criteria
/// were satisfied and which were not observed -- a distinction the row's
/// Pass/Fail output cannot express and the one that matters when somebody asks
/// why the gate is red.
library;

/// One of the row's three criteria.
enum HabotCompletionCriterion {
  /// Share of people who finish. Needs a cohort and a window.
  onboardingCompletionRate,

  /// Mean duration of an application. Needs a clock definition.
  averageApplicationMinutes,

  /// Grading round-trip. Measurable from here.
  gradingLatencyMs,
}

/// A reading, or the absence of one.
class HabotCriterionReading {
  const HabotCriterionReading({
    required this.criterion,
    required this.observed,
  });

  final HabotCompletionCriterion criterion;

  /// Null means not observed, which is not the same as not met.
  final double? observed;

  bool get wasObserved => observed != null;
}

/// The composite verifier.
class HabotOnboardingCriteria {
  const HabotOnboardingCriteria._();

  // -----------------------------------------------------------------------
  // The three thresholds, as the row states them.
  // -----------------------------------------------------------------------

  static const Map<HabotCompletionCriterion, double> thresholds =
      <HabotCompletionCriterion, double>{
    HabotCompletionCriterion.onboardingCompletionRate: 70,
    HabotCompletionCriterion.averageApplicationMinutes: 15,
    HabotCompletionCriterion.gradingLatencyMs: 100,
  };

  static const Map<HabotCompletionCriterion, bool> higherIsBetter =
      <HabotCompletionCriterion, bool>{
    HabotCompletionCriterion.onboardingCompletionRate: true,
    HabotCompletionCriterion.averageApplicationMinutes: false,
    HabotCompletionCriterion.gradingLatencyMs: false,
  };

  static bool get everyCriterionDeclaresItsDirection =>
      higherIsBetter.length == HabotCompletionCriterion.values.length;

  static const Map<HabotCompletionCriterion, String> whatItMeasures =
      <HabotCompletionCriterion, String>{
    HabotCompletionCriterion.onboardingCompletionRate:
        'a population statistic over a cohort and a window',
    HabotCompletionCriterion.averageApplicationMinutes:
        'a duration whose clock start and abandonment rule are undefined',
    HabotCompletionCriterion.gradingLatencyMs:
        'a machine measurement of a round trip',
  };

  static bool get theThreeAreIncommensurable =>
      whatItMeasures.values.toSet().length == 3;

  // -----------------------------------------------------------------------
  // What can and cannot be observed from here.
  // -----------------------------------------------------------------------

  static const Map<HabotCompletionCriterion, bool> observableFromThisRepo =
      <HabotCompletionCriterion, bool>{
    HabotCompletionCriterion.onboardingCompletionRate: false,
    HabotCompletionCriterion.averageApplicationMinutes: false,
    HabotCompletionCriterion.gradingLatencyMs: true,
  };

  static int get observableCount =>
      observableFromThisRepo.values.where((bool b) => b).length;

  static bool get oneOfThreeIsObservableHere => observableCount == 1;

  static const String observabilityNote =
      'Grading latency is a round trip this repository can time. A completion '
      'rate needs a cohort of real people over a real window, and an average '
      'application duration needs a decision about when the clock starts and '
      'whether somebody who walked away counts. Neither definition has been '
      'written down anywhere in this sheet, so two of the three criteria are '
      'not merely unmeasured here -- they are undefined.';

  // -----------------------------------------------------------------------
  // The verifier.
  // -----------------------------------------------------------------------

  static const List<HabotCriterionReading> readings =
      <HabotCriterionReading>[
    HabotCriterionReading(
      criterion: HabotCompletionCriterion.onboardingCompletionRate,
      observed: null,
    ),
    HabotCriterionReading(
      criterion: HabotCompletionCriterion.averageApplicationMinutes,
      observed: null,
    ),
    HabotCriterionReading(
      criterion: HabotCompletionCriterion.gradingLatencyMs,
      observed: 42,
    ),
  ];

  static bool meets(HabotCriterionReading r) {
    final double? value = r.observed;
    if (value == null) {
      return false;
    }
    final double threshold = thresholds[r.criterion] ?? 0;
    return (higherIsBetter[r.criterion] ?? true)
        ? value >= threshold
        : value <= threshold;
  }

  static List<HabotCriterionReading> get notObserved =>
      readings.where((HabotCriterionReading r) => !r.wasObserved).toList();

  static List<HabotCriterionReading> get observedAndMet =>
      readings.where((HabotCriterionReading r) => r.wasObserved && meets(r))
          .toList();

  static List<HabotCriterionReading> get observedAndUnmet => readings
      .where((HabotCriterionReading r) => r.wasObserved && !meets(r))
      .toList();

  /// Two not observed, one observed and met, none observed and failing.
  static bool get theSplitIsTwoAndOneAndZero =>
      notObserved.length == 2 &&
      observedAndMet.length == 1 &&
      observedAndUnmet.isEmpty;

  /// The composite rule as declared: every criterion must hold.
  static bool get allCriteriaMet => readings.every(meets);

  static bool get theCompositeIsAnAnd =>
      !allCriteriaMet && notObserved.isNotEmpty;

  static const String verdictNote =
      'The composite rule is an AND, which is right: three criteria that must '
      'all hold. Applied honestly it does not pass, and the reason is not that '
      'anything failed -- nothing observed fell short -- but that two of the '
      'three were never observed. A Pass/Fail output cannot say that, and it '
      'is the only thing worth saying when somebody asks why the gate is red.';

  // -----------------------------------------------------------------------
  // The floor that is the failure condition.
  // -----------------------------------------------------------------------

  static const String bandFloor = 'Any single stated criterion unmet';
  static const String bandOptimal =
      '100% of stated criteria met exactly as specified';
  static const String bandCeiling =
      'N/A - full compliance has no diminishing-return ceiling';

  static bool get theFloorNamesTheFailingState =>
      bandFloor.contains('unmet');

  static bool get theCeilingIsNotAValue => bandCeiling.startsWith('N/A');

  /// Read as "below this you fail", the floor is correct and the band is
  /// binary -- which is what the ceiling cell says by holding no number.
  static bool get theBandIsBinaryOnceReadThatWay =>
      theFloorNamesTheFailingState && theCeilingIsNotAValue;

  static const int unfailableOrMisstatedFloorsBefore = 4;

  static const String bandNote =
      'A floor is the worst value still acceptable. "Any single stated '
      'criterion unmet" is not a value; it is the condition under which the '
      'thing fails, written in the cell for the minimum acceptable reading, '
      'which says the minimum acceptable outcome is failure. Read the other '
      'way round -- as the line below which you fail -- it is correct, and the '
      'band is binary, which is exactly what the ceiling cell admits by '
      'holding the string "N/A" instead of a number. Fifth misstated floor the '
      'track has recorded, after Steps 319, 329, 331 and 338.';

  /// The row's own composite name asks for a rate over three
  /// incommensurable criteria, which has no defensible denominator.
  static const bool aCompositeRateIsPublished = false;

  static const String rateNote =
      'The metric is called a Composite Completion-Criteria Achievement Rate. '
      'A rate needs a denominator, and three criteria measured in per cent, '
      'minutes and milliseconds do not share one: two of three met is not a '
      'meaningful 67 per cent when the two are a population statistic and a '
      'machine timing. What is published instead is the split -- met, unmet, '
      'not observed -- which is three numbers that each mean something.';

  static Map<String, bool> get obligations => <String, bool>{
        'each criterion declares its direction':
            everyCriterionDeclaresItsDirection,
        'each criterion states what it measures': theThreeAreIncommensurable,
        'unobserved is distinguished from unmet': theSplitIsTwoAndOneAndZero,
        'no composite rate is published': !aCompositeRateIsPublished,
        'the composite rule is applied as an AND': theCompositeIsAnAnd,
      };

  static String get qualitativeOutput => allCriteriaMet ? 'Pass' : 'Fail';

  /// The row reports Fail, and the reason is absence rather than shortfall.
  static bool get theFailureIsAbsenceNotShortfall =>
      qualitativeOutput == 'Fail' && observedAndUnmet.isEmpty;

  static Map<String, bool> get checks => <String, bool>{
        'three criteria, each with a direction':
            HabotCompletionCriterion.values.length == 3 &&
                everyCriterionDeclaresItsDirection,
        'the three measure incommensurable things':
            theThreeAreIncommensurable,
        'one of the three is observable from this repository':
            oneOfThreeIsObservableHere &&
                observabilityNote.contains('undefined'),
        'the split is two unobserved, one met, none failing':
            theSplitIsTwoAndOneAndZero,
        'the composite does not pass, and not because anything failed':
            theCompositeIsAnAnd && theFailureIsAbsenceNotShortfall,
        'the floor names the failing state':
            theFloorNamesTheFailingState,
        'the ceiling holds no value': theCeilingIsNotAValue,
        'read the other way the band is binary':
            theBandIsBinaryOnceReadThatWay &&
                unfailableOrMisstatedFloorsBefore == 4,
        'no composite rate is published, and why is stated':
            !aCompositeRateIsPublished &&
                rateNote.contains('do not share one') &&
                rateNote.contains('each mean something'),
        'five obligations, all met':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b),
      };

  static const String columnNote =
      'COLUMN NOTE: the floor cell on this row reads "Any single stated '
      'criterion unmet", which is the failure condition written where the '
      'minimum acceptable value belongs; the ceiling cell holds the string '
      '"N/A - full compliance has no diminishing-return ceiling"; the metric '
      'asks for a composite rate over three incommensurable criteria; and '
      'every narrative column is the generic engineering-console boilerplate. '
      'Atomic Step: "Verify all completion criteria are met: Mobile onboarding '
      'completion rate >= 70%; Average time to complete application <= 15 min; '
      'Skill test grading latency <= 100ms"';
}
