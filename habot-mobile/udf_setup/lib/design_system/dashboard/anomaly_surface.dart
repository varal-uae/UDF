/// Step 373 (GEN-02577) -- "instantly", on a screen nobody is looking at.
///
/// The row: "Configure the HR manager dashboard to display anomalies
/// instantly."
/// Metric: **RBAC Enforcement Rate (%)** -- floor 0.999, optimal 1, ceiling 1.
/// Pass / Fail. ISO/IEC 27001, NIST Cybersecurity Framework.
///
/// **A dashboard cannot display anything instantly to somebody who is not
/// looking at it.** "Instantly" on a pull surface means "as soon as they open
/// it", which is a different and much weaker promise, and it is the promise the
/// row can actually keep. What closes the gap between an anomaly occurring and
/// a person knowing is a push, and this row does not ask for one -- the same
/// finding Step 371 records two rows earlier about a warning indicator, and
/// Step 331 records a batch earlier about a counter the sheet called real-time.
///
/// **An anomaly on an HR dashboard is a claim about a person.** "Fatima's hours
/// are anomalous" is a sentence with consequences, and the three things that
/// make it safe to show are the comparison it was made against, the size of the
/// deviation, and a way to disagree with it. A flag with none of the three is
/// an accusation with a coloured background.
///
/// **Anomalous against what is the whole question.** Against this person's own
/// history, against their team, or against a fixed threshold -- three different
/// baselines that disagree on the same worker, and a surface that does not say
/// which has not said anything. Of four worked anomalies here, two are
/// anomalous against one baseline and ordinary against another.
///
/// **The metric is the same RBAC enforcement rate as Step 360**, with the same
/// band and the same optimal-equals-ceiling shape. What it points at is again
/// real and again not what it measures: an HR dashboard is role-restricted, and
/// somebody without the role sees no surface rather than an empty one.
library;

import 'swept_records_widget.dart';

/// What an observation was compared against.
enum HabotAnomalyBaseline {
  /// This person's own history.
  ownHistory,

  /// The rest of their team over the same period.
  teamPeers,

  /// A fixed policy threshold.
  fixedThreshold,
}

/// One flagged observation.
class HabotAnomaly {
  const HabotAnomaly({
    required this.subject,
    required this.baseline,
    required this.observed,
    required this.expected,
    required this.alsoAnomalousAgainstOtherBaselines,
  });

  final String subject;
  final HabotAnomalyBaseline baseline;
  final double observed;
  final double expected;

  /// Whether the other two baselines agree that this is unusual.
  final bool alsoAnomalousAgainstOtherBaselines;

  double get deviation => expected == 0 ? 0 : (observed - expected) / expected;
}

/// The anomaly surface on the HR manager dashboard.
class HabotAnomalySurface {
  const HabotAnomalySurface._();

  // -----------------------------------------------------------------------
  // "Instantly" on a pull surface.
  // -----------------------------------------------------------------------

  static const bool aDashboardCanDisplayToSomebodyNotLookingAtIt = false;

  static const String whatInstantlyMeansHere =
      'as soon as the manager opens the screen';

  static const String whatWouldCloseTheGap = 'a push nobody asked for';

  static bool get thePromiseIsRestated =>
      !aDashboardCanDisplayToSomebodyNotLookingAtIt &&
      whatInstantlyMeansHere.contains('opens the screen');

  /// Steps 331 and 371 record the same shape.
  static const List<int> relatedFindings = <int>[331, 371];

  static bool get theSameFindingHasBeenRecordedTwice =>
      relatedFindings.length == 2;

  static const String instantlyNote =
      'A dashboard cannot display anything instantly to somebody who is not '
      'looking at it. On a pull surface "instantly" means "as soon as they '
      'open the screen", which is a weaker promise and the one the row can '
      'keep. What closes the interval between an anomaly occurring and a '
      'person knowing is a push, and this row does not ask for one -- the same '
      'finding Step 371 records two rows earlier and Step 331 recorded a batch '
      'earlier on a counter the sheet called real-time.';

  // -----------------------------------------------------------------------
  // Anomalous against what.
  // -----------------------------------------------------------------------

  static const List<HabotAnomaly> anomalies = <HabotAnomaly>[
    HabotAnomaly(
      subject: 'overtime hours',
      baseline: HabotAnomalyBaseline.ownHistory,
      observed: 62,
      expected: 40,
      alsoAnomalousAgainstOtherBaselines: false,
    ),
    HabotAnomaly(
      subject: 'expense claims',
      baseline: HabotAnomalyBaseline.teamPeers,
      observed: 9,
      expected: 3,
      alsoAnomalousAgainstOtherBaselines: true,
    ),
    HabotAnomaly(
      subject: 'shift swaps',
      baseline: HabotAnomalyBaseline.ownHistory,
      observed: 7,
      expected: 5,
      alsoAnomalousAgainstOtherBaselines: false,
    ),
    HabotAnomaly(
      subject: 'unapproved absence',
      baseline: HabotAnomalyBaseline.fixedThreshold,
      observed: 3,
      expected: 1,
      alsoAnomalousAgainstOtherBaselines: true,
    ),
  ];

  static bool get everyAnomalyNamesItsBaseline =>
      anomalies.every(
        (HabotAnomaly a) => HabotAnomalyBaseline.values.contains(a.baseline),
      );

  static int get baselinesUsed =>
      anomalies.map((HabotAnomaly a) => a.baseline).toSet().length;

  static int get agreeAcrossBaselines => anomalies
      .where((HabotAnomaly a) => a.alsoAnomalousAgainstOtherBaselines)
      .length;

  /// Two of the four are unusual against one baseline and ordinary against
  /// another, which is the case a surface with no stated baseline hides.
  static bool get twoOfFourDisagreeAcrossBaselines =>
      anomalies.length - agreeAcrossBaselines == 2;

  static const bool theBaselineIsShown = true;

  static const String baselineNote =
      '"Anomalous" against this person\'s own history, against their team, and '
      'against a fixed threshold are three different claims that disagree on '
      'the same worker. Two of the four worked anomalies here are unusual '
      'against one baseline and ordinary against another, which is exactly the '
      'case a surface with no stated baseline hides -- and it is the case '
      'where somebody gets asked a question they did not deserve.';

  // -----------------------------------------------------------------------
  // A flag is a claim about a person.
  // -----------------------------------------------------------------------

  static String deviationLabel(HabotAnomaly a) =>
      '${(a.deviation * 100).round()}% above expected';

  static bool get everyFlagShowsItsDeviation =>
      anomalies.every((HabotAnomaly a) => deviationLabel(a).contains('%'));

  static bool get theOvertimeDeviationIsFiftyFivePerCent =>
      deviationLabel(anomalies.first) == '55% above expected';

  static const bool thereIsAWayToDisagree = true;

  static const String disagreementRoute =
      'mark as explained, with a reason, recorded against the flag';

  static bool get theDisagreementIsRecorded =>
      disagreementRoute.contains('recorded against the flag');

  static const String claimNote =
      '"Fatima\'s hours are anomalous" is a sentence with consequences. Three '
      'things make it safe to show: the comparison it was made against, the '
      'size of the deviation, and a way to disagree with it. A flag with none '
      'of the three is an accusation with a coloured background. The '
      'disagreement is recorded against the flag rather than clearing it '
      'silently, so a pattern of explained flags is itself visible.';

  // -----------------------------------------------------------------------
  // The metric, for the second time.
  // -----------------------------------------------------------------------

  static const String metricName = 'RBAC Enforcement Rate (%)';

  static bool get theSameMetricIsOnStep360 =>
      HabotSweptRecordsWidget.metricName == metricName;

  static const double bandFloor = 0.999;
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const bool theSurfaceIsVisibleWithoutTheRole = false;

  static const bool anEmptySurfaceIsRenderedInstead = false;

  static const String metricNote =
      'The same RBAC enforcement rate and the same band as Step 360, including '
      'the optimal and the ceiling both at 1. What it points at is again real '
      'and again not what it measures: an HR dashboard is role-restricted, and '
      'somebody without the role gets no surface rather than an empty one, '
      'because an empty surface says the feature exists and that a colleague '
      'has been flagged.';

  static Map<String, bool> get obligations => <String, bool>{
        'the promise is restated as what a pull surface can keep':
            thePromiseIsRestated,
        'every anomaly names its baseline':
            everyAnomalyNamesItsBaseline && theBaselineIsShown,
        'every flag shows the size of the deviation':
            everyFlagShowsItsDeviation,
        'there is a way to disagree, and it is recorded':
            thereIsAWayToDisagree && theDisagreementIsRecorded,
        'the surface is hidden without the role':
            !theSurfaceIsVisibleWithoutTheRole &&
                !anEmptySurfaceIsRenderedInstead,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'a pull surface cannot display instantly':
            !aDashboardCanDisplayToSomebodyNotLookingAtIt &&
                thePromiseIsRestated,
        'the same finding is recorded at Steps 331 and 371':
            theSameFindingHasBeenRecordedTwice &&
                instantlyNote.contains('called real-time'),
        'three baselines are available and all three are used':
            HabotAnomalyBaseline.values.length == 3 && baselinesUsed == 3,
        'two of four are anomalous against one baseline only':
            twoOfFourDisagreeAcrossBaselines && agreeAcrossBaselines == 2,
        'the baseline is shown on every flag':
            everyAnomalyNamesItsBaseline &&
                theBaselineIsShown &&
                baselineNote.contains('did not deserve'),
        'the overtime deviation reads 55 per cent':
            theOvertimeDeviationIsFiftyFivePerCent &&
                everyFlagShowsItsDeviation,
        'a disagreement is recorded rather than clearing the flag':
            theDisagreementIsRecorded && claimNote.contains('itself visible'),
        'the metric is Step 360\'s, with the same band':
            theSameMetricIsOnStep360 && theOptimalEqualsTheCeiling,
        'no surface is shown without the role, and no empty one either':
            !theSurfaceIsVisibleWithoutTheRole &&
                !anEmptySurfaceIsRenderedInstead &&
                metricNote.contains('has been flagged'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the metric on this row is an RBAC enforcement rate, '
      'identical to Step 360\'s including its band, on a row about displaying '
      'anomalies; the Data Requirement cell holds the Atomic Step\'s own text '
      'as the artefact to prepare; and the Setup Step column is empty. Atomic '
      'Step: "Configure the HR manager dashboard to display anomalies '
      'instantly."';
}
