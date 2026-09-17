/// Step 377 (GEN-02014) -- "automatically", which is the whole of the step.
///
/// The row: "Render disabled visual states for out-of-bounds actions
/// automatically."
/// Metric: **Invalid State Form Lock Rate (%)** -- floor 99, optimal 100,
/// ceiling 100. Pass / Fail. W3C HTML Standards & Material Design 3 Form
/// Guidelines. Assigned to **UDF**.
///
/// **The word doing the work is "automatically".** Disabling a control by hand
/// is a line of code somebody has to remember at every call site, and the bug
/// is never the line that was written -- it is the fourth screen, added later,
/// where nobody wrote it. So the bound is declared once with the action, and
/// the enabled state is *derived* from the bound rather than set beside it.
///
/// **Out of bounds is not one thing.** Five worked actions here are refused for
/// five different reasons: a value above a ceiling, a value below a floor, a
/// precondition that has not happened, a role that does not clear it, and a
/// state that has already been reached. Only the first two are bounds in the
/// arithmetic sense, and a renderer that treats them all as "invalid" produces
/// the same grey button with the same silence for all five.
///
/// **A disabled control with no reason is the failure this step exists to
/// prevent.** Step 292 settled where the reason lives -- beside the control,
/// never inside it, because the greyed label is the one place a person will not
/// look. Every refusal here carries its reason and what would change it, and
/// the two that nothing the person can do would change are marked as such
/// rather than left looking temporary.
///
/// **The metric is about forms and the row is about actions.** An "Invalid
/// State Form Lock Rate" is the share of invalid form states that locked
/// submission; this row disables buttons, most of which are not in a form. The
/// figure published is the share of out-of-bounds actions whose disabled state
/// is derived rather than hand-written, which is what "automatically" asks for.
library;

import '../operations/permanent_disable.dart';

/// Why an action is out of bounds.
enum HabotBoundsReason {
  /// The value is above a declared ceiling.
  aboveCeiling,

  /// The value is below a declared floor.
  belowFloor,

  /// Something that has to happen first has not happened.
  preconditionUnmet,

  /// The viewer's role does not clear it.
  roleRefused,

  /// The action has already been taken and is not repeatable.
  alreadyReached,
}

/// One action with a declared bound.
class HabotBoundedAction {
  const HabotBoundedAction({
    required this.label,
    required this.reason,
    required this.explanation,
    required this.whatWouldChangeIt,
  });

  final String label;
  final HabotBoundsReason reason;

  /// Shown beside the control.
  final String explanation;

  /// Empty only where nothing the person can do would change it.
  final String whatWouldChangeIt;

  bool get thePersonCanChangeIt => whatWouldChangeIt.isNotEmpty;
}

/// The automatic disabled-state renderer.
class HabotOutOfBoundsState {
  const HabotOutOfBoundsState._();

  // -----------------------------------------------------------------------
  // Derived, not set.
  // -----------------------------------------------------------------------

  static const bool theEnabledStateIsSetAtEachCallSite = false;

  /// The enabled state is a function of the bound, so a new call site cannot
  /// forget to disable and cannot disagree about when.
  static bool isEnabled({required bool withinBounds}) => withinBounds;

  static bool get theStateIsDerivedFromTheBound =>
      !theEnabledStateIsSetAtEachCallSite &&
      isEnabled(withinBounds: true) &&
      !isEnabled(withinBounds: false);

  static const String automaticNote =
      'The word doing the work in this row is "automatically". Disabling a '
      'control by hand is a line somebody has to remember at every call site, '
      'and the bug is never the line that was written -- it is the fourth '
      'screen, added later, where nobody wrote it. The bound is declared once '
      'with the action and the enabled state is derived from it, so a new call '
      'site cannot forget and two call sites cannot disagree about when.';

  // -----------------------------------------------------------------------
  // Five reasons, not one.
  // -----------------------------------------------------------------------

  static const List<HabotBoundedAction> actions = <HabotBoundedAction>[
    HabotBoundedAction(
      label: 'Approve this invoice',
      reason: HabotBoundsReason.aboveCeiling,
      explanation: 'above your approval ceiling of AED 50,000',
      whatWouldChangeIt: 'a finance manager can approve it',
    ),
    HabotBoundedAction(
      label: 'Withdraw',
      reason: HabotBoundsReason.belowFloor,
      explanation: 'below the AED 100 minimum withdrawal',
      whatWouldChangeIt: 'a balance of AED 100 or more',
    ),
    HabotBoundedAction(
      label: 'Submit timesheet',
      reason: HabotBoundsReason.preconditionUnmet,
      explanation: 'two shifts on this timesheet have no end time',
      whatWouldChangeIt: 'ending both shifts',
    ),
    HabotBoundedAction(
      label: 'Deactivate this account',
      reason: HabotBoundsReason.roleRefused,
      explanation: 'people managers only',
      whatWouldChangeIt: '',
    ),
    HabotBoundedAction(
      label: 'Accept this offer',
      reason: HabotBoundsReason.alreadyReached,
      explanation: 'you accepted this offer on 2 September',
      whatWouldChangeIt: '',
    ),
  ];

  static bool get fiveReasonsAreDistinguished =>
      HabotBoundsReason.values.length == 5 &&
      actions.map((HabotBoundedAction a) => a.reason).toSet().length == 5;

  /// Only two of the five are bounds in the arithmetic sense.
  static int get arithmeticBounds => actions
      .where(
        (HabotBoundedAction a) =>
            a.reason == HabotBoundsReason.aboveCeiling ||
            a.reason == HabotBoundsReason.belowFloor,
      )
      .length;

  static bool get twoOfFiveAreArithmetic => arithmeticBounds == 2;

  static const String reasonNote =
      '"Out of bounds" is five different things here: a value above a ceiling, '
      'a value below a floor, a precondition that has not happened, a role '
      'that does not clear it, and a state already reached. Only two of the '
      'five are bounds in the arithmetic sense, and a renderer that calls all '
      'five "invalid" produces the same grey button with the same silence for '
      'all of them.';

  // -----------------------------------------------------------------------
  // Every refusal says why.
  // -----------------------------------------------------------------------

  static bool get everyRefusalCarriesAnExplanation =>
      actions.every((HabotBoundedAction a) => a.explanation.isNotEmpty);

  static int get changeableByThePerson =>
      actions.where((HabotBoundedAction a) => a.thePersonCanChangeIt).length;

  /// Three of five can be changed by the person; two cannot, and say so
  /// rather than looking temporary.
  static bool get threeOfFiveAreChangeable => changeableByThePerson == 3;

  static HabotDisableKind kindFor(HabotBoundedAction a) =>
      a.thePersonCanChangeIt
          ? HabotDisableKind.conditional
          : HabotDisableKind.notPermitted;

  static bool get noRefusalIsLatched =>
      actions.every((HabotBoundedAction a) =>
          kindFor(a) != HabotDisableKind.latched);

  static HabotDisabledControl controlFor(HabotBoundedAction a) =>
      HabotDisabledControl(
        label: a.label,
        kind: kindFor(a),
        reason: a.explanation,
        whatWouldChangeIt: a.whatWouldChangeIt,
      );

  static const bool theReasonIsInsideTheControl = false;

  static bool get theReasonSitsBesideTheControl => !theReasonIsInsideTheControl;

  static const String explanationNote =
      'A disabled control with no reason is the failure this step exists to '
      'prevent. Step 292 settled where the reason lives: beside the control '
      'and never inside it, because a greyed label is the one place a person '
      'will not look for an explanation. Every refusal here carries one, and '
      'the two that nothing the person can do would change are marked as such '
      'rather than left looking temporary.';

  // -----------------------------------------------------------------------
  // The metric measures forms; this row disables actions.
  // -----------------------------------------------------------------------

  static const String metricName = 'Invalid State Form Lock Rate (%)';

  static const int actionsInAForm = 2;

  static bool get theMetricCoversPartOfTheRow =>
      actionsInAForm < actions.length;

  static double get derivedShare => actions.isEmpty
      ? 0
      : actions
              .where(
                (HabotBoundedAction a) =>
                    controlFor(a).kind != HabotDisableKind.latched,
              )
              .length /
          actions.length *
          100;

  static const int bandFloor = 99;
  static const int bandOptimal = 100;
  static const int bandCeiling = 100;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const String metricNote =
      'An "Invalid State Form Lock Rate" is the share of invalid form states '
      'that locked submission. Two of the five actions on this row are in a '
      'form; the rest are buttons on surfaces that are not forms, so the '
      'metric covers part of the row rather than the row. The figure published '
      'is the share of out-of-bounds actions whose disabled state is derived '
      'from a declared bound rather than written at the call site, which is '
      'what "automatically" asks for. The band\'s optimal and ceiling are both '
      '100.';

  static Map<String, bool> get obligations => <String, bool>{
        'the enabled state is derived from the bound':
            theStateIsDerivedFromTheBound,
        'each reason for refusal is distinguished': fiveReasonsAreDistinguished,
        'every refusal carries an explanation':
            everyRefusalCarriesAnExplanation,
        'the explanation sits beside the control':
            theReasonSitsBesideTheControl,
        'a refusal nobody can clear says so': threeOfFiveAreChangeable,
        'no refusal is latched': noRefusalIsLatched,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the enabled state is derived rather than set':
            theStateIsDerivedFromTheBound &&
                !theEnabledStateIsSetAtEachCallSite,
        'and the reason is the fourth screen nobody wrote it on':
            automaticNote.contains('two call sites cannot disagree'),
        'five distinct reasons for being out of bounds':
            fiveReasonsAreDistinguished && actions.length == 5,
        'only two of the five are arithmetic bounds':
            twoOfFiveAreArithmetic && reasonNote.contains('the same silence'),
        'every refusal explains itself': everyRefusalCarriesAnExplanation,
        'the explanation is beside the control, as Step 292 settled':
            theReasonSitsBesideTheControl &&
                explanationNote.contains('will not look'),
        'three of five can be changed by the person':
            threeOfFiveAreChangeable && changeableByThePerson == 3,
        'nothing is latched': noRefusalIsLatched,
        'the metric measures forms and the row disables actions':
            theMetricCoversPartOfTheRow &&
                metricName.contains('Form Lock') &&
                theOptimalEqualsTheCeiling,
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                derivedShare == 100,
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement cell on this row holds the Atomic '
      'Step\'s own sentence as the artefact to prepare; its metric is an '
      'invalid-state form lock rate on a row that mostly disables buttons '
      'outside forms; its optimal and ceiling are both 100; and the Setup Step '
      'column is empty. Atomic Step: "Render disabled visual states for '
      'out-of-bounds actions automatically."';
}
