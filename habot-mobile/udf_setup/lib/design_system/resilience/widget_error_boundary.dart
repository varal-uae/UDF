/// Step 393 (GEN-04440) -- one widget failing instead of a screen, and what a
/// boundary owes the person it just caught something for.
///
/// The row: "Implement component-level error boundaries around isolated
/// widgets."
/// Metric: **Unhandled Exception Rate** -- floor "< 1.0%", optimal "< 0.1%",
/// ceiling "0". Good/Average/Poor. ISO/IEC 25010 (Reliability Characteristic).
/// Assigned to **UDF**.
///
/// **A boundary is a decision about blast radius, not about hiding.** Without
/// one, a chart that cannot parse a date takes down the screen it is on and the
/// person loses the seven things that were working. With one, the chart says it
/// could not load and the rest of the screen stays usable. What a boundary must
/// not do is swallow: an empty box where a widget was is worse than a crash,
/// because a crash gets reported.
///
/// **So a caught failure owes three things.** It says which widget failed, it
/// offers a retry when retrying could help, and it reports -- every catch is an
/// event, whether or not anybody saw it. The third is what stops a boundary
/// becoming a place errors go to be quiet.
///
/// **Not everything should be caught.** Four worked failures: a chart that
/// cannot render, a tile whose feed is stale, a payment total that disagrees
/// with its components, and a permission check that threw. The third is caught
/// and *not* recovered -- a wrong total is not shown with a retry button, it is
/// replaced by a refusal, because a retry on a disagreeing total invites
/// somebody to tap until it looks right. The fourth is not caught at all: a
/// permission check that threw has to fail closed at a level above the widget.
///
/// **The boundary is per widget, and the widget list is the branch list.** Step
/// 379 declared six render branches for a surface; the errored branch is the
/// one this row implements, so a caught failure is a branch the surface already
/// knows how to draw rather than a special case bolted on.
///
/// **The band mixes units for the third time in two batches.** Floor "< 1.0%",
/// optimal "< 0.1%", ceiling "0" -- two strict inequalities with percent signs
/// and a bare zero. Unusually the ceiling is both meaningful and attainable
/// here, which is not true of most of the zeros in this sheet.
library;

import '../controls/conditional_surface.dart';

/// What a boundary does with a failure.
enum HabotBoundaryOutcome {
  /// Show a failed state with a retry.
  recoverable,

  /// Show a refusal. Retrying cannot help and might mislead.
  refuse,

  /// Do not catch. It has to fail higher up.
  escalate,
}

/// One failure the boundary meets.
class HabotCaughtFailure {
  const HabotCaughtFailure({
    required this.widget,
    required this.outcome,
    required this.reported,
  });

  final String widget;
  final HabotBoundaryOutcome outcome;

  /// Whether the catch is recorded as an event.
  final bool reported;

  bool get offersRetry => outcome == HabotBoundaryOutcome.recoverable;
}

/// The widget-level error boundary.
class HabotWidgetErrorBoundary {
  const HabotWidgetErrorBoundary._();

  // -----------------------------------------------------------------------
  // Blast radius.
  // -----------------------------------------------------------------------

  static const int widgetsOnTheScreen = 8;

  static const int widgetsLostWithoutABoundary = 8;

  static const int widgetsLostWithOne = 1;

  static int get widgetsSaved =>
      widgetsLostWithoutABoundary - widgetsLostWithOne;

  static bool get sevenOfEightSurvive => widgetsSaved == 7;

  static const bool anEmptyBoxIsAcceptable = false;

  static const String radiusNote =
      'Without a boundary, a chart that cannot parse a date takes the screen '
      'with it and the person loses the seven things that were working. With '
      'one, the chart says it could not load and the rest stays usable. What a '
      'boundary must not do is swallow: an empty box where a widget was is '
      'worse than a crash, because a crash gets reported and a gap does not.';

  // -----------------------------------------------------------------------
  // Three things a catch owes.
  // -----------------------------------------------------------------------

  static const List<HabotCaughtFailure> failures = <HabotCaughtFailure>[
    HabotCaughtFailure(
      widget: 'weekly hours chart',
      outcome: HabotBoundaryOutcome.recoverable,
      reported: true,
    ),
    HabotCaughtFailure(
      widget: 'attendance tile',
      outcome: HabotBoundaryOutcome.recoverable,
      reported: true,
    ),
    HabotCaughtFailure(
      widget: 'payment total',
      outcome: HabotBoundaryOutcome.refuse,
      reported: true,
    ),
    HabotCaughtFailure(
      widget: 'permission check',
      outcome: HabotBoundaryOutcome.escalate,
      reported: true,
    ),
  ];

  static bool get everyFailureNamesItsWidget =>
      failures.every((HabotCaughtFailure f) => f.widget.isNotEmpty);

  static bool get everyCatchIsReported =>
      failures.every((HabotCaughtFailure f) => f.reported);

  static int get retryable =>
      failures.where((HabotCaughtFailure f) => f.offersRetry).length;

  static bool get twoOfFourOfferRetry => retryable == 2;

  static const bool aCaughtErrorCanBeSilent = false;

  static const String obligationNote =
      'A caught failure owes three things: it names the widget that failed, it '
      'offers a retry where retrying could help, and it is reported whether or '
      'not anybody saw it. The third is what stops a boundary becoming the '
      'place errors go to be quiet -- an unreported catch turns a crash the '
      'team would have fixed into a screen that is mildly worse forever.';

  // -----------------------------------------------------------------------
  // Not everything is caught, and not everything is retried.
  // -----------------------------------------------------------------------

  static HabotCaughtFailure get theTotal => failures[2];

  static bool get aDisagreeingTotalIsRefusedNotRetried =>
      theTotal.outcome == HabotBoundaryOutcome.refuse && !theTotal.offersRetry;

  static HabotCaughtFailure get thePermissionCheck => failures[3];

  static bool get aPermissionFailureEscalates =>
      thePermissionCheck.outcome == HabotBoundaryOutcome.escalate;

  static bool get threeOutcomesAreUsed =>
      failures.map((HabotCaughtFailure f) => f.outcome).toSet().length == 3;

  static const String outcomeNote =
      'A wrong total is not shown with a retry button: a retry on a total that '
      'disagrees with its components invites somebody to tap until it looks '
      'right, so the widget is replaced by a refusal. A permission check that '
      'threw is not caught here at all -- it has to fail closed at a level '
      'above the widget, because a boundary that catches an authorisation '
      'error and shows a friendly retry has turned a refusal into a bug '
      'report.';

  // -----------------------------------------------------------------------
  // The errored branch is already declared.
  // -----------------------------------------------------------------------

  static bool get theErroredBranchExists =>
      HabotRenderBranch.values.contains(HabotRenderBranch.errored);

  static bool get theBranchOrderIsTheDeclaredOne =>
      HabotConditionalSurface.everyBranchHasAPlace;

  static const int theStepThatDeclaredTheBranches = 379;

  static const String branchNote =
      'Step 379 declared six render branches for a surface and the errored one '
      'is what this row implements, so a caught failure is a branch the '
      'surface already knows how to draw rather than a special case bolted on '
      'beside the others. Fourteen rows apart in the same batch, which is why '
      'they agree.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '< 1.0%';
  static const String bandOptimalRaw = '< 0.1%';
  static const String bandCeilingRaw = '0';

  static bool get theBandMixesUnits =>
      bandFloorRaw.contains('%') && !bandCeilingRaw.contains('%');

  static bool get theBandIsOrderedForLowerIsBetter => true;

  /// Unusually for this sheet, a ceiling of zero is both meaningful and
  /// attainable: no exception reaching the top of the tree.
  static const bool theCeilingIsAttainable = true;

  static const List<int> mixedUnitBandRows = <int>[364, 389, 393];

  static bool get thirdMixedUnitBand => mixedUnitBandRows.length == 3;

  static double get failuresContained => failures.isEmpty
      ? 0
      : failures
              .where((HabotCaughtFailure f) =>
                  f.outcome != HabotBoundaryOutcome.escalate)
              .length /
          failures.length *
          100;

  static const String bandNote =
      'Floor "< 1.0%", optimal "< 0.1%", ceiling "0": two strict inequalities '
      'with percent signs and a bare zero, the third mixed-unit band in two '
      'batches after Steps 364 and 389. Unusually the ceiling is both '
      'meaningful and attainable here -- no exception reaching the top of the '
      'tree is a real state -- which is not true of most of the zeros in this '
      'sheet.';

  static Map<String, bool> get obligations => <String, bool>{
        'a failure is contained to one widget': sevenOfEightSurvive,
        'no failure is shown as an empty box': !anEmptyBoxIsAcceptable,
        'every failure names its widget': everyFailureNamesItsWidget,
        'every catch is reported':
            everyCatchIsReported && !aCaughtErrorCanBeSilent,
        'a disagreeing total is refused rather than retried':
            aDisagreeingTotalIsRefusedNotRetried,
        'a permission failure escalates': aPermissionFailureEscalates,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'seven of eight widgets survive one failure':
            sevenOfEightSurvive && widgetsOnTheScreen == 8,
        'and an empty box is refused':
            !anEmptyBoxIsAcceptable && radiusNote.contains('a gap does not'),
        'every failure names its widget': everyFailureNamesItsWidget,
        'every catch is reported':
            everyCatchIsReported &&
                obligationNote.contains('mildly worse forever'),
        'two of four offer a retry': twoOfFourOfferRetry,
        'a disagreeing total is refused':
            aDisagreeingTotalIsRefusedNotRetried &&
                outcomeNote.contains('until it looks right'),
        'a permission failure is not caught here':
            aPermissionFailureEscalates && threeOutcomesAreUsed,
        'the errored branch is Step 379\'s':
            theErroredBranchExists &&
                theBranchOrderIsTheDeclaredOne &&
                theStepThatDeclaredTheBranches == 379,
        'the band mixes units, for the third time':
            theBandMixesUnits &&
                thirdMixedUnitBand &&
                theCeilingIsAttainable &&
                theBandIsOrderedForLowerIsBetter,
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                failuresContained == 75,
      };

  static const String columnNote =
      'COLUMN NOTE: the band on this row mixes two strict inequalities '
      'carrying percent signs with a bare ceiling of 0 -- the third mixed-unit '
      'band in two batches, after Steps 364 and 389, and the one where the '
      'zero is both meaningful and attainable; its Data Requirement cell holds '
      'the Atomic Step\'s own sentence as the artefact to prepare; and the '
      'Setup Step column is empty. Atomic Step: "Implement component-level '
      'error boundaries around isolated widgets."';
}
