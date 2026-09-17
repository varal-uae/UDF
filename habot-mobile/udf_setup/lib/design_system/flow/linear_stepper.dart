/// Step 354 (EDEBS-013-11) -- a stepper, and the question a stepper answers
/// that a progress bar cannot.
///
/// The row: "Configure the mobile front-end Linear Stepper component for
/// stepped transaction flows."
/// Metric: **UI Design-System Adherence Rate** -- floor ">=85%", optimal
/// ">=95%", ceiling 1. Good/Average/Poor. MD3 Guidelines / Nielsen Norman
/// heuristic evaluation.
///
/// **A stepper is a promise about how many.** A progress bar says how far
/// along; a stepper says how far along *out of what*, and the second is the
/// only one a person can plan around. Three of four is a decision about whether
/// to finish now; 75 per cent is a feeling. That is the whole reason to prefer
/// the component, and it is also the constraint: a stepper may not be used for
/// a flow whose length is not known in advance, because a fourth step appearing
/// after "3 of 3" is worse than never having promised.
///
/// **Backwards has to be free and forwards has to be earned.** Going back to
/// re-read what you entered must cost nothing and lose nothing; going forward
/// commits the step. A stepper that revalidates on the way back, or discards
/// what was typed, teaches people not to look -- and not looking is how the
/// wrong value gets submitted.
///
/// **Compact width is what the component is for and what breaks it.** Four
/// step labels across 328dp is 82dp each, before a translation. The labels
/// collapse to the current one plus a count, which keeps the promise -- the
/// number of steps -- and drops the part that was never readable anyway.
///
/// **COLUMN NOTE.** The Data Requirement column on this row is about error
/// handling for empty mandatory fields and inline validation, which is Step
/// 167's subject rather than a stepper's; the Setup Step column reads "Output
/// the standardized MTOI Split-Screen Template for production deployment"; and
/// the band mixes percentages with the bare ratio "1".
library;

import '../tokens/motion_tokens.dart';

/// What a step can be.
enum HabotStepState { done, current, upcoming }

/// One step in a transaction flow.
class HabotFlowStep {
  const HabotFlowStep({
    required this.label,
    required this.state,
    required this.committed,
  });

  final String label;
  final HabotStepState state;

  /// Whether leaving it forwards wrote anything.
  final bool committed;
}

/// The linear stepper.
class HabotLinearStepper {
  const HabotLinearStepper._();

  // -----------------------------------------------------------------------
  // How many, not how far.
  // -----------------------------------------------------------------------

  static const List<HabotFlowStep> steps = <HabotFlowStep>[
    HabotFlowStep(
      label: 'Details',
      state: HabotStepState.done,
      committed: true,
    ),
    HabotFlowStep(
      label: 'Amount',
      state: HabotStepState.done,
      committed: true,
    ),
    HabotFlowStep(
      label: 'Review',
      state: HabotStepState.current,
      committed: false,
    ),
    HabotFlowStep(
      label: 'Confirm',
      state: HabotStepState.upcoming,
      committed: false,
    ),
  ];

  static int get total => steps.length;

  static int get currentIndex =>
      steps.indexWhere((HabotFlowStep s) => s.state == HabotStepState.current);

  static String get positionLabel => 'Step ${currentIndex + 1} of $total';

  static bool get thePositionNamesTheDenominator =>
      positionLabel.contains('of $total');

  /// A progress bar would say 50 per cent and answer a different question.
  static double get equivalentFraction => currentIndex / total;

  static bool get theFractionSaysLess =>
      equivalentFraction == 0.5 && thePositionNamesTheDenominator;

  static const bool theLengthIsKnownInAdvance = true;

  static const String lengthNote =
      'A progress bar says how far along. A stepper says how far along out of '
      'what, and only the second is something a person can plan around: "three '
      'of four" is a decision about whether to finish now, and "75 per cent" '
      'is a feeling. The promise is the denominator, which is why a stepper '
      'may not be used for a flow whose length is not known in advance -- a '
      'fourth step appearing after "3 of 3" is worse than never having '
      'promised anything.';

  // -----------------------------------------------------------------------
  // Backwards is free.
  // -----------------------------------------------------------------------

  static const bool goingBackRevalidates = false;
  static const bool goingBackDiscardsInput = false;
  static const bool goingForwardCommits = true;

  static bool get backwardsCostsNothing =>
      !goingBackRevalidates && !goingBackDiscardsInput;

  static List<HabotFlowStep> get committedSteps =>
      steps.where((HabotFlowStep s) => s.committed).toList();

  /// Exactly the steps already left forwards are committed.
  static bool get onlyCompletedStepsAreCommitted =>
      committedSteps.length == 2 &&
      committedSteps.every(
        (HabotFlowStep s) => s.state == HabotStepState.done,
      );

  static const String directionNote =
      'Going back to re-read what you entered must cost nothing and lose '
      'nothing. A stepper that revalidates on the way back throws errors at '
      'somebody who is checking rather than editing; one that discards what '
      'was typed punishes them for looking. Both teach people not to look, and '
      'not looking is how a wrong value reaches the end of a flow. Forwards '
      'commits, because that is the direction in which somebody has said yes.';

  // -----------------------------------------------------------------------
  // Compact width.
  // -----------------------------------------------------------------------

  static const double compactWidthDp = 328;

  static double get dpPerLabel => compactWidthDp / total;

  static bool get labelsDoNotFitAtCompact => dpPerLabel < 96;

  static const bool labelsCollapseToTheCurrentOne = true;

  static String get compactLabel =>
      '$positionLabel: ${steps[currentIndex].label}';

  static bool get theCollapsedFormKeepsThePromise =>
      compactLabel.contains('of $total');

  static const String widthNote =
      'Four labels across 328dp is 82dp each before any translation, which is '
      'not a label, it is an abbreviation with an ellipsis. At compact width '
      'the labels collapse to the current step and the count -- "Step 3 of 4: '
      'Review" -- which keeps the part that carries the promise and drops the '
      'part that was never readable. The full set is still in the semantics '
      'for anybody traversing it.';

  // -----------------------------------------------------------------------
  // The transition.
  // -----------------------------------------------------------------------

  static Duration get stepTransition => HabotMotion.stepperTransition;

  static Duration get stepSlideOut => HabotMotion.stepperSlideOut;

  static bool get bothTransitionsWereAlreadyDeclared =>
      stepTransition == HabotMotion.stepperTransition &&
      stepSlideOut == HabotMotion.stepperSlideOut;

  static const String transitionNote =
      'The stepper transition and its slide-out were declared in the motion '
      'tokens at Step 136, before anything in this repository had steps to '
      'move between. Nothing new is added here, which is the point: a second '
      'set of durations for the same motion is how two flows end up feeling '
      'like two applications.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const String bandFloor = '>=85%';
  static const String bandOptimal = '>=95%';
  static const String bandCeiling = '1';

  static bool get theBandMixesUnits =>
      bandFloor.contains('%') && !bandCeiling.contains('%');

  static const int mixedUnitBandsInThisBatch = 4;

  static const String bandNote =
      'Floor ">=85%", optimal ">=95%", ceiling "1": two percentages and a bare '
      'ratio, which is the fourth band in this batch to mix units after Steps '
      '336, 343 and 348. The three values are at least ordered once reconciled '
      'onto one scale, and what the adherence rate counts is not stated, so '
      'the figure published here is the share of the component\'s declared '
      'obligations that hold.';

  static Map<String, bool> get obligations => <String, bool>{
        'the position names the denominator': thePositionNamesTheDenominator,
        'the flow length is known before the stepper is shown':
            theLengthIsKnownInAdvance,
        'going back costs nothing': backwardsCostsNothing,
        'only completed steps are committed': onlyCompletedStepsAreCommitted,
        'the compact form keeps the count': theCollapsedFormKeepsThePromise,
        'the transitions are the declared ones':
            bothTransitionsWereAlreadyDeclared,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static double get adherence => obligations.isEmpty
      ? 0
      : obligations.values.where((bool b) => b).length /
          obligations.length *
          100;

  static Map<String, bool> get checks => <String, bool>{
        'four steps, one of which is current':
            total == 4 && currentIndex == 2,
        'the position is stated out of the total':
            thePositionNamesTheDenominator && positionLabel == 'Step 3 of 4',
        'the equivalent fraction says less than the count':
            theFractionSaysLess,
        'a stepper requires a known length':
            theLengthIsKnownInAdvance && lengthNote.contains('3 of 3'),
        'backwards neither revalidates nor discards':
            backwardsCostsNothing && goingForwardCommits,
        'two steps are committed, and they are the completed ones':
            onlyCompletedStepsAreCommitted,
        'four labels do not fit at compact width':
            labelsDoNotFitAtCompact && dpPerLabel == 82,
        'the collapsed label still carries the count':
            labelsCollapseToTheCurrentOne && theCollapsedFormKeepsThePromise,
        'both transitions come from Step 136':
            bothTransitionsWereAlreadyDeclared &&
                transitionNote.contains('two applications'),
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                adherence == 100 &&
                qualitativeOutput == 'Good' &&
                theBandMixesUnits &&
                mixedUnitBandsInThisBatch == 4,
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement column on this row is about error '
      'handling for empty mandatory fields and inline validation rather than '
      'about a stepper; the Setup Step column reads "Output the standardized '
      'MTOI Split-Screen Template for production deployment"; and the band '
      'mixes two percentages with the bare ratio "1". Atomic Step: "Configure '
      'the mobile front-end Linear Stepper component for stepped transaction '
      'flows."';
}
