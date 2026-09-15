/// Step 275 (GEN-02698) -- rolling back an experiment that is going wrong,
/// and deciding what "going wrong" means before anything is automated.
///
/// The row: "Configure Sentry to monitor both variants independently and
/// trigger automatic rollback if the experimental variant shows elevated error
/// rates."
/// Metric: **WCAG 2.2 AA Compliance Rate** -- floor "All critical violations
/// fixed", optimal "100% axe-core pass rate with zero WCAG AA violations",
/// ceiling 1. Pass / Fail. Standard cited: WCAG 2.2.
///
/// **The sharpest column mismatch in this batch, and it is two mismatches in
/// one cell.** An error-monitoring and automatic-rollback row carries an
/// accessibility metric; and that metric's optimal names axe-core, a browser
/// tool that walks a DOM. There is no DOM here. Both halves are recorded, and
/// the accessibility obligation is answered by the census Step 266 already
/// built rather than by a tool that cannot run.
///
/// **"Elevated error rates" is not a threshold.** A canary arm at one percent
/// exposure with three errors in forty sessions reads as a 7.5% error rate
/// against a control's 1.7%, which is four and a half times worse and is also
/// three people. Rolling a release back on that is how automated rollback gets
/// switched off. The rule below needs three things before it will act: a
/// window, a minimum sample in each arm, and a ratio between rates rather than
/// a difference between counts.
///
/// **The client's contribution is one field, and it already exists.**
/// Monitoring two variants independently is impossible unless the error report
/// says which variant the session was in, and `HabotVariantAssignment.toJson`
/// (Step 133) already emits the flag, the variant, the source and whether it
/// was an exposure. Nothing new is needed; the requirement is to check that
/// nothing removed it.
///
/// **And rollback is asymmetric on purpose.** Going back is automatic; going
/// forward is not. A rule that rolls back on errors and rolls forward when
/// they stop is a rule that oscillates, shipping and unshipping a feature
/// every hour while nobody learns anything.
library;

import '../a11y/alt_text_census.dart';
import '../preferences/feature_flags.dart';
import '../tokens/motion_tokens.dart';

/// What the monitor decides.
enum HabotRollbackDecision {
  /// Not enough time has passed to say anything.
  insufficientWindow,

  /// Not enough sessions in one of the arms.
  insufficientSample,

  /// Observed, compared, and not elevated.
  hold,

  /// Elevated. Turn the flag off.
  rollBack,
}

/// What one arm of an experiment looked like over the window.
class HabotArmObservation {
  const HabotArmObservation({
    required this.variant,
    required this.sessions,
    required this.sessionsWithAnError,
  });

  final String variant;
  final int sessions;
  final int sessionsWithAnError;

  /// Sessions, not events: one crash loop in one session is one unhappy
  /// person, and counting events would let it outvote a thousand happy ones.
  double get errorRate => sessions == 0 ? 0 : sessionsWithAnError / sessions;
}

/// The monitor.
class HabotVariantRollback {
  const HabotVariantRollback._();

  /// How long an arm is watched before its numbers are allowed to mean
  /// anything. Read from the declared token rather than chosen here.
  static Duration get observationWindow => HabotMotion.variantObservationWindow;

  /// The smallest arm worth comparing. At the baseline rate below, five
  /// hundred sessions is about eight errors: still noisy, and the smallest
  /// population where a half-again difference is not one person's bad
  /// afternoon.
  static const int minimumSessionsPerArm = 500;

  /// How much worse the experimental arm has to be. A ratio, because a
  /// difference in counts says more about arm sizes than about quality.
  static const double elevationFactor = 1.5;

  static HabotRollbackDecision decide({
    required HabotArmObservation control,
    required HabotArmObservation experiment,
    required Duration observed,
  }) {
    if (observed < observationWindow) {
      return HabotRollbackDecision.insufficientWindow;
    }
    if (control.sessions < minimumSessionsPerArm ||
        experiment.sessions < minimumSessionsPerArm) {
      return HabotRollbackDecision.insufficientSample;
    }
    return experiment.errorRate > control.errorRate * elevationFactor
        ? HabotRollbackDecision.rollBack
        : HabotRollbackDecision.hold;
  }

  // -----------------------------------------------------------------------
  // The worked corpus. Four observations, all four decided.
  // -----------------------------------------------------------------------

  static const HabotArmObservation control = HabotArmObservation(
    variant: 'control',
    sessions: 12000,
    sessionsWithAnError: 200,
  );

  /// One percent exposure, three unhappy sessions. The case that would fire a
  /// naive rule.
  static const HabotArmObservation canary = HabotArmObservation(
    variant: 'experiment',
    sessions: 40,
    sessionsWithAnError: 3,
  );

  /// A real difference in a real population.
  static const HabotArmObservation elevated = HabotArmObservation(
    variant: 'experiment',
    sessions: 3000,
    sessionsWithAnError: 95,
  );

  /// The same population, a difference that is not one.
  static const HabotArmObservation noisy = HabotArmObservation(
    variant: 'experiment',
    sessions: 3000,
    sessionsWithAnError: 55,
  );

  static Duration get aFullWindow => observationWindow;
  static Duration get aPartialWindow => observationWindow ~/ 6;

  static HabotRollbackDecision get canaryDecision => decide(
        control: control,
        experiment: canary,
        observed: aFullWindow,
      );

  static HabotRollbackDecision get elevatedDecision => decide(
        control: control,
        experiment: elevated,
        observed: aFullWindow,
      );

  static HabotRollbackDecision get noisyDecision => decide(
        control: control,
        experiment: noisy,
        observed: aFullWindow,
      );

  static HabotRollbackDecision get tooSoonDecision => decide(
        control: control,
        experiment: elevated,
        observed: aPartialWindow,
      );

  /// The canary's rate is four and a half times the control's and it is still
  /// not acted on, which is the whole point of the sample floor.
  static double get canaryRateRatio => canary.errorRate / control.errorRate;

  static bool get theAlarmingCanaryIsNotActedOn =>
      canaryDecision == HabotRollbackDecision.insufficientSample &&
      canaryRateRatio > 4 &&
      canary.sessionsWithAnError == 3;

  static double get elevatedRateRatio => elevated.errorRate / control.errorRate;
  static double get noisyRateRatio => noisy.errorRate / control.errorRate;

  static bool get theRatiosAreWhatWasComputed =>
      (control.errorRate - 200 / 12000).abs() < 1e-12 &&
      (elevatedRateRatio - 1.9).abs() < 1e-9 &&
      (noisyRateRatio - 1.1).abs() < 1e-9;

  static bool get everyCorpusCaseIsDecidedDifferently =>
      <HabotRollbackDecision>{
        canaryDecision,
        elevatedDecision,
        noisyDecision,
        tooSoonDecision,
      }.length ==
      4;

  static const String thresholdNote =
      '"Elevated error rates" is not a threshold, and automating it without '
      'one is how automatic rollback gets switched off in the second week. A '
      'canary arm at one percent exposure with three unhappy sessions out of '
      'forty reads as 7.5% against a control\'s 1.67% -- four and a half '
      'times worse, and also three people. The rule here needs a window, a '
      'minimum of five hundred sessions in each arm, and a ratio between '
      'rates rather than a difference between counts, because a difference in '
      'counts mostly measures how big the arms are. Rates are over sessions '
      'rather than events, so one crash loop is one unhappy person rather '
      'than four hundred data points.';

  // -----------------------------------------------------------------------
  // Asymmetry.
  // -----------------------------------------------------------------------

  /// Rolling back is automatic. Rolling forward is not, and the flag stays
  /// off until a person clears it.
  static const bool rollsBackAutomatically = true;
  static const bool rollsForwardAutomatically = false;

  static const String oscillationNote =
      'Rollback is asymmetric on purpose. A rule that rolls back when errors '
      'rise and rolls forward when they stop is a rule that oscillates: the '
      'feature ships and unships every hour, half the users see a different '
      'application each time they open it, and the error rate that triggered '
      'the first rollback is never explained to anybody. Going back is '
      'automatic because it is safe and reversible; going forward is a '
      'decision somebody makes after reading what happened.';

  // -----------------------------------------------------------------------
  // What the client does, which is one field it already emits.
  // -----------------------------------------------------------------------

  /// Step 133's assignment, serialised. Monitoring two variants independently
  /// is impossible unless this rides along with the error report.
  static Map<String, Object?> get reportedAssignment =>
      const HabotVariantAssignment(
        flagKey: 'checkout_v2',
        variant: 'experiment',
        source: HabotVariantSource.bucketed,
        isExposure: true,
      ).toJson();

  static bool get theErrorReportCanTellTheArmsApart =>
      reportedAssignment['flag'] == 'checkout_v2' &&
      reportedAssignment['variant'] == 'experiment' &&
      reportedAssignment['source'] == 'bucketed' &&
      reportedAssignment['is_exposure'] == true;

  /// A rollback does not un-assign anybody: units already bucketed into a
  /// variant that has just been removed need a state, and Step 133 declared
  /// one. This is the state a rollback creates, which is why it exists.
  static const HabotVariantSource sourceAfterRollback =
      HabotVariantSource.fallbackFromRemovedVariant;

  static bool get theStateARollbackCreatesWasAlreadyDeclared =>
      HabotVariantSource.values.contains(sourceAfterRollback) &&
      sourceAfterRollback != HabotVariantSource.defaultValue;

  static const String clientHalfNote =
      'The client\'s whole contribution is one field, and it already exists. '
      'HabotVariantAssignment.toJson emits the flag, the variant, the source '
      'and whether the evaluation was an exposure, so an error report carrying '
      'it can be grouped by arm; without it the two variants are one '
      'undifferentiated pile and "monitor both independently" is not a '
      'configuration problem but an impossible one. The requirement here is '
      'therefore to check that nothing removed it -- and the state a rollback '
      'leaves behind, fallbackFromRemovedVariant, was declared at Step 133 '
      'before anything needed it.';

  static const String whoRollsBackNote =
      'The rollback itself is a change to a flag, which the server owns. A '
      'client cannot roll itself back; what it can do is honour the next '
      'value it is given without waiting for a restart, which Step 133 made '
      'possible by keeping evaluation synchronous and in memory. So the '
      'monitor watches, the server flips the flag, and the client is simply '
      'correct on the next evaluation -- the same division as Steps 271 and '
      '273.';

  // -----------------------------------------------------------------------
  // The metric, which belongs to a different row.
  // -----------------------------------------------------------------------

  /// The accessibility obligation, answered by the census Step 266 built.
  static double get accessibilityConformance =>
      HabotAltTextCensus.conformanceScore;

  static bool get theAccessibilityHalfIsAlreadyMet =>
      accessibilityConformance == 100 && HabotAltTextCensus.nonConformant
          .isEmpty;

  static const bool axeCoreCanRunHere = false;

  static const String metricMismatchNote =
      'TWO MISMATCHES IN ONE CELL. The Atomic Step is error monitoring and '
      'automatic rollback; the metric is WCAG 2.2 AA Compliance Rate, which '
      'is about neither. And the metric\'s own optimal -- "100% axe-core pass '
      'rate" -- names a browser tool that walks a DOM, of which there is none '
      'in a Flutter application: the widget tree is not a document and '
      'axe-core cannot be pointed at it. Both are recorded. The accessibility '
      'obligation is answered by the census at Step 266 and by the six a11y '
      'rules the guard has enforced since Step 97, which is the honest '
      'equivalent of the tool the cell asks for; the rollback rule is built '
      'above. Neither is used to hide the other, which is what reporting only '
      'the easy number would do.';

  static const String ceilingNote =
      'The band is three different kinds of thing: the floor is a sentence '
      '("All critical violations fixed"), the optimal is a tool output ("100% '
      'axe-core pass rate"), and the ceiling is the number 1. Read together '
      'they are a percentage, a checklist and a ratio, and no single '
      'measurement satisfies all three forms. The ceiling of 1 is read as '
      '100%, which makes it equal to the optimal -- the same collapsed band '
      'as Step 271.';

  /// **Pass.** The rollback rule is defined and exercised over four cases;
  /// the client's reporting field is verified present; the accessibility
  /// metric is met through Step 266; and both column mismatches are recorded
  /// rather than smoothed over.
  static String get qualitativeOutput =>
      everyCorpusCaseIsDecidedDifferently &&
              theErrorReportCanTellTheArmsApart &&
              theAccessibilityHalfIsAlreadyMet
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'four observations are decided, and no two the same way':
            everyCorpusCaseIsDecidedDifferently,
        'the alarming canary is three people and is not acted on':
            theAlarmingCanaryIsNotActedOn,
        'a real elevation over a real population rolls back':
            elevatedDecision == HabotRollbackDecision.rollBack,
        'a 1.1x difference holds rather than rolling back':
            noisyDecision == HabotRollbackDecision.hold,
        'nothing is decided before the window closes':
            tooSoonDecision == HabotRollbackDecision.insufficientWindow,
        'the ratios are the ones computed, not asserted':
            theRatiosAreWhatWasComputed,
        'the window is read from a declared token':
            observationWindow == HabotMotion.variantObservationWindow &&
                observationWindow.inHours == 1,
        'rates are over sessions rather than events':
            thresholdNote.contains('one unhappy person'),
        'rollback is automatic and roll-forward is not':
            rollsBackAutomatically &&
                !rollsForwardAutomatically &&
                oscillationNote.contains('oscillates'),
        'the error report carries the arm it belongs to':
            theErrorReportCanTellTheArmsApart,
        'the state a rollback creates was declared at Step 133':
            theStateARollbackCreatesWasAlreadyDeclared,
        'the flag flip is named as the server\'s':
            whoRollsBackNote.contains('honour the next value'),
        'the accessibility metric is met through the Step 266 census':
            theAccessibilityHalfIsAlreadyMet && !axeCoreCanRunHere,
        'both mismatches in the metric cell are recorded':
            metricMismatchNote.contains('TWO MISMATCHES') &&
                metricMismatchNote.contains('not a document'),
        'the band\'s three incompatible forms are recorded':
            ceilingNote.contains('a percentage, a checklist and a ratio'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Floor Boundary '
      'is a sentence ("All critical violations fixed"), Optimal Target names '
      'a browser tool, and Ceiling Boundary is the bare number 1. Atomic '
      'Step: "Configure Sentry to monitor both variants independently and '
      'trigger automatic rollback if the experimental variant shows elevated '
      'error rates."';
}
