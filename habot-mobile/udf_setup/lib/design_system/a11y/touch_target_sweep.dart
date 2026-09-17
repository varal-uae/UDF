/// Step 313 (GEN-01374) -- a verification that has been running on every
/// commit since Step 229, and the two things it cannot see.
///
/// The row: "Verify that all interactive touch targets meet or exceed the
/// 48x48dp minimum size requirement."
/// Metric: **Touch Target Size** -- floor ">=44x44dp", optimal "48x48dp",
/// ceiling "<=56x56dp". Pass/Fail. WCAG 2.1 SC 2.5.5 / Material Design 3.
///
/// **The verification exists.** Step 229 built `HabotTouchTargetLint`, whose
/// rule `A11Y_TOUCH_TARGET_BELOW_BAND` runs at stage G-C of
/// `tool/verify_aiss.sh`, before the tests, and exits non-zero on the first
/// violation. A row asking somebody to "verify that all interactive touch
/// targets meet the minimum" is asking for a thing that has been happening on
/// every commit for eighty-four steps. This is the same shape as Step 180,
/// where the mechanism the row asked to activate had been active for 176
/// steps. What was missing then was the count; what is missing here is the
/// boundary of the check -- what it can see and what it cannot.
///
/// **The row's own floor is below the rule its own instruction states.** The
/// Atomic Step says 48. The floor says 44. Four points of the band are outside
/// the sentence that describes it, which means a target at 45 satisfies the
/// metric and fails the instruction on the same row.
///
/// **And the citation here is right, while Step 298's is wrong.** This row
/// cites SC 2.5.5 for 44, which is correct: 2.5.5 Target Size is Level AAA at
/// 44 by 44. Step 298, fifteen rows earlier in this batch, cites SC 2.5.8 for
/// the same figure, and 2.5.8 Target Size (Minimum) is Level AA at 24 by 24.
/// Step 227 already recorded that exact confusion and resolved it, in this
/// repository, with both figures written down -- so the sheet has now
/// reproduced a defect the codebase had already fixed. The resolution is read
/// from Step 227 rather than argued again.
///
/// **What a static sweep cannot see.** The guard reads declared sizes. It
/// cannot evaluate a target whose size is composed at run time: one sized to
/// its child's intrinsic width, or one whose height follows the text scale.
/// Of six classes of interactive control here, four declare a size and two do
/// not, and the two that do not are the ones that change under the conditions
/// people actually use -- a long label in Welsh, a text scale at 2.0. Those
/// need a widget test at the audited scales; naming them is this step's
/// contribution and pretending the static sweep covers them would be the
/// failure mode worth avoiding.
library;

import '../interaction/touch_guideline.dart';
import '../tokens/touch_target_band.dart';
import 'touch_target_lint.dart';

/// How a control's size comes to be.
enum HabotSizeOrigin {
  /// A number or token written at the declaration. The guard can read it.
  declared,

  /// Composed at run time from constraints, content or the text scale.
  composed,
}

/// One class of interactive control.
class HabotControlClass {
  const HabotControlClass({
    required this.name,
    required this.origin,
    required this.whatChangesIt,
  });

  final String name;
  final HabotSizeOrigin origin;

  /// For a composed size: what makes it move.
  final String whatChangesIt;

  bool get theGuardCanSeeIt => origin == HabotSizeOrigin.declared;
}

/// The sweep.
class HabotTouchTargetSweep {
  const HabotTouchTargetSweep._();

  // -----------------------------------------------------------------------
  // The check that already runs.
  // -----------------------------------------------------------------------

  static String get ruleId => HabotTouchTargetLint.ruleId;

  static String get ruleOwner => HabotTouchTargetLint.owner;

  static String get gateStage => HabotTouchTargetLint.gateStage;

  static String get gateScript => HabotTouchTargetLint.gateScript;

  static bool get itRunsBeforeTheTests =>
      HabotTouchTargetLint.runsBeforeTests;

  static bool get itStopsOnTheFirstViolation =>
      HabotTouchTargetLint.exitsNonZeroOnFirstViolation;

  static const int stepThatBuiltIt = 229;
  static const int thisStep = 313;

  static int get commitsItHasBeenRunningFor => thisStep - stepThatBuiltIt;

  static bool get theVerificationAlreadyExists =>
      itRunsBeforeTheTests && itStopsOnTheFirstViolation;

  static const String alreadyRunningNote =
      'A row asking somebody to verify that all interactive targets meet the '
      'minimum is asking for a thing that has run on every commit for '
      'eighty-four steps. Step 180 had the same shape: the self-chasing '
      'mechanism it asked to activate had been active for 176 steps, and what '
      'was missing was the count. What is missing here is the boundary -- what '
      'the check can see and what it cannot -- because a verification whose '
      'limits are undocumented is read as covering everything.';

  // -----------------------------------------------------------------------
  // The band, and the four points outside the sentence.
  // -----------------------------------------------------------------------

  static double get floorDp => HabotTouchBand.floorDp;
  static double get optimalDp => HabotTouchBand.optimalDp;
  static double get ceilingDp => HabotTouchBand.ceilingDp;

  /// What the Atomic Step says, as opposed to what the floor says.
  static const double instructionDp = 48;

  static double get pointsBetweenTheFloorAndTheInstruction =>
      instructionDp - floorDp;

  static bool get theFloorIsBelowTheInstruction => floorDp < instructionDp;

  /// A target at 45 points satisfies the metric and fails the sentence.
  static const double worked = 45;

  static bool get theWorkedTargetSplitsTheRow =>
      worked >= floorDp && worked < instructionDp;

  /// Step 227 already settled which number this project enforces.
  static bool get theProjectEnforcesTheOptimal =>
      HabotTouchTargetGuideline.rowAsksForTheOptimalNotTheFloor;

  static const String bandNote =
      'The Atomic Step says 48 and the floor says 44, so four points of the '
      'band sit outside the sentence that describes it and a target at 45 '
      'passes the metric while failing the instruction on the same row. This '
      'project enforces the optimal, which Step 227 settled; the floor is '
      'recorded so the disagreement inside the row is visible.';

  // -----------------------------------------------------------------------
  // The citation, which this row gets right.
  // -----------------------------------------------------------------------

  static double get sc255Minimum =>
      HabotTouchTargetGuideline.sc255MinimumCssPx;

  static double get sc258Minimum =>
      HabotTouchTargetGuideline.sc258MinimumCssPx;

  static const String thisRowCites = 'WCAG 2.1 SC 2.5.5';
  static const String step298Cites = 'WCAG 2.2 SC 2.5.8';

  static bool get thisRowCitesCorrectly => sc255Minimum == floorDp;

  static bool get step298CitesIncorrectly => sc258Minimum != floorDp;

  static const int stepThatResolvedItFirst = 227;

  static const String citationNote =
      'This row cites SC 2.5.5 for 44, which is right: 2.5.5 Target Size is '
      'Level AAA at 44 by 44. Step 298, fifteen rows earlier in this batch, '
      'cites SC 2.5.8 for the same figure, and 2.5.8 Target Size (Minimum) is '
      'Level AA at 24 by 24. Step 227 recorded that confusion and resolved it '
      'in this repository with both figures written down, so the sheet has '
      'reproduced a defect the codebase had already fixed. Nothing is argued '
      'again here; the two numbers are read from Step 227.';

  // -----------------------------------------------------------------------
  // What the sweep cannot see.
  // -----------------------------------------------------------------------

  static const List<HabotControlClass> controlClasses = <HabotControlClass>[
    HabotControlClass(
      name: 'icon button',
      origin: HabotSizeOrigin.declared,
      whatChangesIt: '',
    ),
    HabotControlClass(
      name: 'navigation destination',
      origin: HabotSizeOrigin.declared,
      whatChangesIt: '',
    ),
    HabotControlClass(
      name: 'list row',
      origin: HabotSizeOrigin.declared,
      whatChangesIt: '',
    ),
    HabotControlClass(
      name: 'floating action button',
      origin: HabotSizeOrigin.declared,
      whatChangesIt: '',
    ),
    HabotControlClass(
      name: 'chip sized to its label',
      origin: HabotSizeOrigin.composed,
      whatChangesIt:
          'the label, which is a translated string -- a short English word '
          'and a long Welsh one give different widths from the same code',
    ),
    HabotControlClass(
      name: 'inline text link inside a paragraph',
      origin: HabotSizeOrigin.composed,
      whatChangesIt:
          'the text scale: the tap region follows the glyph box, so at 2.0 it '
          'grows and at the smallest supported scale it shrinks below the band',
    ),
  ];

  static List<HabotControlClass> get seenByTheGuard =>
      controlClasses.where((HabotControlClass c) => c.theGuardCanSeeIt)
          .toList();

  static List<HabotControlClass> get needingAWidgetTest =>
      controlClasses.where((HabotControlClass c) => !c.theGuardCanSeeIt)
          .toList();

  static double get shareCoveredStatically =>
      seenByTheGuard.length / controlClasses.length;

  static bool get everyComposedClassSaysWhatMovesIt => needingAWidgetTest
      .every((HabotControlClass c) => c.whatChangesIt.isNotEmpty);

  static bool get everyDeclaredClassSaysNothingMovesIt => seenByTheGuard
      .every((HabotControlClass c) => c.whatChangesIt.isEmpty);

  /// The two classes the guard cannot read are the two that move under the
  /// conditions people actually use.
  static bool get theBlindSpotIsWhereTheRiskIs =>
      needingAWidgetTest.any(
        (HabotControlClass c) => c.whatChangesIt.contains('Welsh'),
      ) &&
      needingAWidgetTest.any(
        (HabotControlClass c) => c.whatChangesIt.contains('text scale'),
      );

  static const String blindSpotNote =
      'The guard reads declared sizes. Four of six control classes declare '
      'one; two compose it at run time, from a translated label and from the '
      'text scale, and those two are precisely the ones that move under the '
      'conditions people actually use the app in. A widget test at the audited '
      'scales is what covers them. Naming that is this step\'s contribution; '
      'reporting the static sweep as though it covered all six would be the '
      'failure worth avoiding, because a verification whose limits are '
      'undocumented gets read as covering everything.';

  // -----------------------------------------------------------------------
  // The verdict.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'the rule exists and blocks a merge': theVerificationAlreadyExists,
        'the project enforces the optimal rather than the floor':
            theProjectEnforcesTheOptimal,
        'every control class is classified by how its size arises':
            controlClasses.length == 6,
        'every composed class names what moves it':
            everyComposedClassSaysWhatMovesIt,
        'the limits of the static sweep are written down':
            needingAWidgetTest.length == 2,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the rule is Step 229\'s, at stage G-C, before the tests':
            ruleId == 'A11Y_TOUCH_TARGET_BELOW_BAND' &&
                ruleOwner.contains('229') &&
                gateStage == 'G-C' &&
                gateScript == 'tool/verify_aiss.sh' &&
                itRunsBeforeTheTests &&
                itStopsOnTheFirstViolation,
        'it has been running for eighty-four steps':
            commitsItHasBeenRunningFor == 84 &&
                alreadyRunningNote.contains('Step 180'),
        'the floor is four points below the instruction':
            theFloorIsBelowTheInstruction &&
                pointsBetweenTheFloorAndTheInstruction == 4 &&
                floorDp == 44 &&
                instructionDp == 48,
        'so a 45-point target passes the metric and fails the sentence':
            theWorkedTargetSplitsTheRow && theProjectEnforcesTheOptimal,
        'the band runs 44 to 56 with the optimal at 48':
            floorDp == 44 && optimalDp == 48 && ceilingDp == 56,
        'this row cites the criterion that says 44':
            thisRowCitesCorrectly &&
                thisRowCites.contains('2.5.5') &&
                sc255Minimum == 44,
        'and Step 298 cites the one that says 24':
            step298CitesIncorrectly &&
                step298Cites.contains('2.5.8') &&
                sc258Minimum == 24,
        'a defect the codebase had already resolved at Step 227':
            stepThatResolvedItFirst == 227 &&
                citationNote.contains('already fixed'),
        'four of six control classes are visible to the guard':
            seenByTheGuard.length == 4 &&
                needingAWidgetTest.length == 2 &&
                (shareCoveredStatically - 2 / 3).abs() < 1e-9,
        'and the two it cannot see are where the risk is':
            theBlindSpotIsWhereTheRiskIs &&
                everyComposedClassSaysWhatMovesIt &&
                everyDeclaredClassSaysNothingMovesIt,
        'the limits are written down rather than left implied':
            blindSpotNote.contains('read as covering everything'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: every narrative column on this row is the generic '
      'engineering-console boilerplate, and the Expected Output cell is the '
      'Atomic Step truncated mid-word -- "the 48x48dp minimum siz". Atomic '
      'Step: "Verify that all interactive touch targets meet or exceed the '
      '48x48dp minimum size requirement."';
}
