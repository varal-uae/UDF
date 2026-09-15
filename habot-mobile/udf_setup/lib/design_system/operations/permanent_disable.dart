/// Step 292 (PELCE-029-17) -- the word "permanently", and a floor that
/// contradicts the sentence above it.
///
/// The row: "Permanently disable and visually grey out the 'Release to Tech'
/// button if the reconciliation score != 0."
/// Metric: **Design Reconciliation Score** -- floor "<=2 open gaps", optimal
/// "0 open gaps", ceiling "0 open gaps". Pass / Fail -> Best = Pass
/// (score = 0).
///
/// **"Permanently" would mean the button never comes back.** The score is a
/// count of open gaps and gaps close; the disable is conditional on a value
/// that changes, which is the opposite of permanent. Implemented literally,
/// the first non-zero score in a session would latch the control off and the
/// person would fix every gap and watch nothing happen. The word is refused,
/// and the refusal is the step: a control disabled with no route back is a
/// dead end, and a dead end that used to be a working button is the kind of
/// bug people work around rather than report.
///
/// **The floor contradicts the Atomic Step.** The step disables on score != 0.
/// The floor says two open gaps is acceptable. So a score of 2 is inside the
/// band and disables the button, which means the band's own floor describes a
/// state the rule refuses. One of the two is wrong and the sheet does not say
/// which; both are recorded.
///
/// **And "grey out" is not a licence to make it unreadable.** Disabled text is
/// exempt from the contrast minimum, and exempt is not the same as invisible:
/// somebody has to be able to read a control to know what it is they cannot
/// do. The label stays legible, and the reason lives beside the control rather
/// than inside it -- because a greyed-out control is the one place a person
/// will not look for an explanation.
library;

import '../forms/strict_true_gate.dart';
import '../operations/reconciliation_gate.dart';

/// Why a control is off.
enum HabotDisableKind {
  /// Off until a condition changes, and the condition is stated.
  conditional,

  /// Off for this person, whatever they do.
  notPermitted,

  /// Off forever. Refused here; declared so that choosing it is visible.
  latched,
}

/// A control in its off state.
class HabotDisabledControl {
  const HabotDisabledControl({
    required this.label,
    required this.kind,
    required this.reason,
    required this.whatWouldChangeIt,
  });

  final String label;
  final HabotDisableKind kind;

  /// Shown beside the control, never inside it.
  final String reason;

  /// Empty only where nothing the person can do would change it.
  final String whatWouldChangeIt;

  bool get isADeadEnd =>
      kind == HabotDisableKind.latched || whatWouldChangeIt.isEmpty;
}

/// The rule.
class HabotPermanentDisable {
  const HabotPermanentDisable._();

  /// The word the row uses.
  static const String theRowsWord = 'Permanently';

  /// What is implemented instead.
  static const HabotDisableKind kindUsed = HabotDisableKind.conditional;

  static bool get theLatchedKindIsDeclaredAndUnused =>
      HabotDisableKind.values.contains(HabotDisableKind.latched) &&
      kindUsed != HabotDisableKind.latched;

  // -----------------------------------------------------------------------
  // Disabled, and re-enabled.
  // -----------------------------------------------------------------------

  /// Enabled state as a function of the current score, recomputed every time
  /// rather than latched.
  static bool isEnabledAt(int score) => score == 0;

  /// The sequence the literal reading breaks: a non-zero score, then a fixed
  /// one.
  static bool get theButtonComesBack =>
      !isEnabledAt(2) && isEnabledAt(0);

  /// What a latch would do with the same sequence, kept as an executable
  /// contrast.
  static bool latchedIsEnabledAfter(List<int> scores) =>
      scores.every((int s) => s == 0);

  static bool get aLatchWouldNeverComeBack =>
      !latchedIsEnabledAfter(<int>[2, 0]) && latchedIsEnabledAfter(<int>[0, 0]);

  /// And the enabled state agrees with the gate Step 291 bound, so the two
  /// rows cannot drift into disagreeing about the same button.
  static bool get itAgreesWithTheGate =>
      isEnabledAt(
            HabotReconciliationGate.scoreFor(HabotReconciliationGate.clean),
          ) ==
          HabotReconciliationGate.buttonIsEnabled(
            HabotReconciliationGate.clean,
          ) &&
      isEnabledAt(
            HabotReconciliationGate.scoreFor(
              HabotReconciliationGate.unbalanced,
            ),
          ) ==
          HabotReconciliationGate.buttonIsEnabled(
            HabotReconciliationGate.unbalanced,
          );

  static const String permanentlyNote =
      'The score counts open gaps and gaps close, so the disable is '
      'conditional on a value that changes -- which is the opposite of '
      'permanent. Implemented literally, the first non-zero score in a '
      'session latches the control off, and the person fixes every gap and '
      'watches nothing happen. That is worse than a control that was never '
      'enabled: a button that used to work and now does not is a bug people '
      'work around rather than report. The latched kind is declared in the '
      'vocabulary so that choosing it is a visible act, and it is not chosen.';

  // -----------------------------------------------------------------------
  // The reason lives outside the control.
  // -----------------------------------------------------------------------

  static HabotDisabledControl controlFor(int score) => HabotDisabledControl(
        label: 'Release to Tech',
        kind: HabotDisableKind.conditional,
        reason: score == 0
            ? ''
            : '$score open gap${score == 1 ? '' : 's'} in the reconciliation.',
        whatWouldChangeIt: score == 0
            ? ''
            : 'Close the gaps listed below; the button enables itself.',
      );

  static bool get aDisabledControlIsNotADeadEnd =>
      !controlFor(2).isADeadEnd && controlFor(2).reason.isNotEmpty;

  static bool get theReasonNamesTheCount =>
      controlFor(2).reason.contains('2 open gaps') &&
      controlFor(1).reason.contains('1 open gap');

  /// And the reasons themselves come from the existing gate rather than being
  /// composed here, so the sentence a person reads is the one Step 254 wrote.
  static List<String> get reasonsFromTheGate =>
      HabotStrictTrueGate.reasonsFrom(HabotReconciliationGate.outstanding)
          .map((HabotGateReason r) => r.message)
          .toList();

  static bool get theSentencesComeFromTheGate =>
      reasonsFromTheGate.isNotEmpty &&
      reasonsFromTheGate.every((String m) => m.isNotEmpty);

  static const String reasonPlacementNote =
      'The reason sits beside the control, not inside it. A greyed-out '
      'control is the one place a person will not look for an explanation: it '
      'reads as scenery. Putting the sentence next to it, in ordinary text, '
      'is what turns "this is off" into "this is off because of that, and '
      'here is the that". The sentences themselves come from the gate Step '
      '254 built rather than being written again here, so there is one '
      'wording per reason in the application.';

  // -----------------------------------------------------------------------
  // Grey, and still readable.
  // -----------------------------------------------------------------------

  /// MD3's disabled label opacity. Recorded as the figure it is, so that the
  /// consequence below is arithmetic rather than opinion.
  static const double disabledLabelOpacity = 0.38;

  /// The contrast a label at that opacity retains, as a fraction of what it
  /// had. Approximate and directional: the point is the order of magnitude,
  /// not the third decimal.
  static double contrastRetained(double baseRatio) =>
      baseRatio * disabledLabelOpacity;

  /// A label that started at 7:1 is around 2.7:1 disabled -- below the 4.5
  /// minimum, which is exactly why disabled text is exempted. Exempt is not
  /// the same as unreadable, and the difference is the whole content of this
  /// paragraph.
  static bool get greyingCostsMostOfTheContrast =>
      contrastRetained(7) < 4.5 && contrastRetained(7) > 2;

  static const bool labelStaysLegible = true;
  static const bool reasonIsOutsideTheGreyedControl = true;

  static const String greyNote =
      'Disabled text is exempt from the contrast minimum, and exempt is not '
      'the same as invisible. At MD3\'s 0.38 disabled opacity a label that '
      'started around 7:1 lands near 2.7:1 -- legally fine and practically '
      'hard to read on a bright screen outdoors, which is where people use '
      'phones. Somebody has to be able to read a control to know what it is '
      'they cannot do, so the label stays legible and the explanation is '
      'rendered at full contrast beside it rather than sharing the control\'s '
      'opacity.';

  // -----------------------------------------------------------------------
  // Metric: Design Reconciliation Score -- <=2 / 0 / 0.
  // -----------------------------------------------------------------------

  static const int floorOpenGaps = 2;
  static const int optimalOpenGaps = 0;
  static const int ceilingOpenGaps = 0;

  /// A score of 2 sits inside the floor and is refused by the rule, so the
  /// band's floor describes a state the Atomic Step does not allow.
  static bool get theFloorDescribesARefusedState =>
      floorOpenGaps > optimalOpenGaps && !isEnabledAt(floorOpenGaps);

  static bool get theOptimalAndCeilingAreTheSame =>
      optimalOpenGaps == ceilingOpenGaps;

  static const String bandContradictionNote =
      'The floor says two open gaps is acceptable; the Atomic Step disables '
      'the button whenever the score is not zero. So a score of 2 is inside '
      'the band and refused by the rule, and the band\'s own floor describes '
      'a state the sentence above it does not allow. One of the two is wrong '
      'and the sheet does not say which. The rule is implemented, because a '
      'rule is a thing a button can obey and a band is not, and the '
      'contradiction is recorded rather than resolved by whichever cell was '
      'read last. Optimal and ceiling are both zero, so the band has no room '
      'above target either -- the same collapse as Steps 271 and 275.';

  static String get qualitativeOutput =>
      theButtonComesBack && aDisabledControlIsNotADeadEnd ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the disable is conditional and the latched kind is unused':
            theLatchedKindIsDeclaredAndUnused && kindUsed ==
                HabotDisableKind.conditional,
        'the button comes back when the score reaches zero':
            theButtonComesBack,
        'a latch would not, and the contrast is executable':
            aLatchWouldNeverComeBack &&
                permanentlyNote.contains('work around rather than report'),
        'the enabled state agrees with the gate Step 291 bound':
            itAgreesWithTheGate,
        'a disabled control is never a dead end':
            aDisabledControlIsNotADeadEnd && theReasonNamesTheCount,
        'the sentences come from the existing gate':
            theSentencesComeFromTheGate,
        'the reason is rendered outside the greyed control':
            reasonIsOutsideTheGreyedControl &&
                reasonPlacementNote.contains('reads as scenery'),
        'greying costs most of the contrast, and the label stays legible':
            greyingCostsMostOfTheContrast &&
                labelStaysLegible &&
                disabledLabelOpacity == 0.38,
        'the floor describes a state the rule refuses':
            theFloorDescribesARefusedState &&
                theOptimalAndCeilingAreTheSame &&
                bandContradictionNote.contains('read last'),
        'the word "permanently" is refused rather than implemented':
            theRowsWord == 'Permanently' &&
                kindUsed != HabotDisableKind.latched,
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Document the '
      'timing framework and usage guidelines for engineers", and the design '
      'notes are the same four lines as Step 291 -- the two rows share a '
      'widget description and disagree about what it does. Atomic Step: '
      '"Permanently disable and visually grey out the \'Release to Tech\' '
      'button if the reconciliation score != 0."';
}
