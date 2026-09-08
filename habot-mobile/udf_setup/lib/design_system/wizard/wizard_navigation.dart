/// AISS Step 149 -- GEN-01087
/// Setup Step (Action) / Atomic Step: "Design a wizard layout interface
///   featuring clear back and next navigation affordances."
/// Metric: Entity Decomposition Structural Integrity -- Floor 0.95,
///         Optimal 1.0, Ceiling 1.0. Pass / Fail.
///
/// **"CLEAR" IS THE REQUIREMENT, AND A DISABLED BUTTON IS NOT CLEAR.**
/// The usual implementation greys out Next until the step validates. That is
/// unambiguous to the person who wrote it and silent to everyone else: the
/// user sees a dead control and no statement of what is wrong. Worse, a
/// disabled button is skipped by some screen readers entirely, so a blind user
/// gets no forward affordance at all and no explanation.
///
/// So Next stays ENABLED and, when the step is not satisfiable, refuses with a
/// reason. [HabotWizardNavigation.forward] returns a
/// [HabotNavigationOutcome] that carries the refusal and what to say about it;
/// the caller shows it where the button is, which is where the user is
/// already looking.
///
/// **BACK IS NEVER REFUSED** (Step 146, decision D-1). Validation blocks
/// progress, not retreat. A wizard that traps someone on a step they cannot
/// satisfy has no exit but force-quitting, which loses the form.
///
/// **DIRECTION IS RESOLVED, NOT ASSUMED** (Step 146, F-1; Step 138, F-1).
/// "Back" and "Next" are semantic; leading and trailing are visual. In Urdu
/// the forward control sits on the LEFT. This file maps the two, so no screen
/// has to remember to.
///
/// **IT DECORATES THE STEP 20 MACHINE RATHER THAN REPLACING IT.**
/// `WizardStepMachine` already owns the index, the gating and the block
/// reason. A second navigation model would be two answers to "which step am I
/// on".
library;

import '../i18n/language_preference.dart';
import '../i18n/localization_objective.dart';
import 'step_machine.dart';

/// Where a control sits, once direction is known.
enum HabotControlSide { leading, trailing }

/// What one navigation attempt did.
class HabotNavigationOutcome {
  const HabotNavigationOutcome({
    required this.moved,
    required this.index,
    required this.blockedBy,
    this.refusalMessageKey,
  });

  final bool moved;
  final int index;
  final StepBlockReason blockedBy;

  /// The message key to show where the control is. Null when nothing was
  /// refused. A key rather than a string, so the refusal is translated like
  /// everything else -- a wizard that explains itself only in English fails
  /// exactly the users Step 138 is about.
  final String? refusalMessageKey;

  bool get wasRefused => !moved && blockedBy != StepBlockReason.none;
}

/// Back and next, made clear.
class HabotWizardNavigation {
  const HabotWizardNavigation({
    required this.machine,
    required this.direction,
  });

  factory HabotWizardNavigation.forPreference({
    required WizardStepMachine machine,
    required HabotLanguagePreference preference,
  }) =>
      HabotWizardNavigation(
        machine: machine,
        direction: preference.direction,
      );

  final WizardStepMachine machine;
  final HabotTextDirectionality direction;

  bool get isRightToLeft =>
      direction == HabotTextDirectionality.rightToLeft;

  /// Where the FORWARD control sits. The whole of finding F-1, in one place.
  HabotControlSide get forwardSide =>
      isRightToLeft ? HabotControlSide.leading : HabotControlSide.trailing;

  HabotControlSide get backwardSide =>
      isRightToLeft ? HabotControlSide.trailing : HabotControlSide.leading;

  /// The label key for the forward control. "Done" on the last step, because
  /// a Next that submits is a Next that surprises.
  String get forwardLabelKey =>
      machine.isLast ? 'action.done' : 'action.next';

  String get backwardLabelKey => 'action.back';

  /// Whether the forward control is shown as ENABLED. Always true -- see the
  /// header. Present as a named property so that a future change to it is a
  /// visible change to this rule rather than an edit inside a build method.
  bool get forwardIsEnabled => true;

  /// Whether the back control is shown at all. Hidden on the first step,
  /// because a control that does nothing is not clear either.
  bool get backwardIsVisible => !machine.isFirst;

  /// Attempt to advance.
  HabotNavigationOutcome forward() {
    final bool moved = machine.next();
    if (moved) {
      return HabotNavigationOutcome(
        moved: true,
        index: machine.index,
        blockedBy: StepBlockReason.none,
      );
    }
    return HabotNavigationOutcome(
      moved: false,
      index: machine.index,
      blockedBy: machine.lastBlock,
      refusalMessageKey: refusalKeyFor(machine.lastBlock),
    );
  }

  /// Attempt to go back. Never refused for validation.
  HabotNavigationOutcome backward() {
    final bool moved = machine.previous();
    return HabotNavigationOutcome(
      moved: moved,
      index: machine.index,
      blockedBy: moved ? StepBlockReason.none : machine.lastBlock,
      refusalMessageKey: moved ? null : refusalKeyFor(machine.lastBlock),
    );
  }

  /// The message key for each refusal. Declared as a total mapping so a new
  /// block reason cannot be added without someone deciding what to say about
  /// it.
  static String? refusalKeyFor(StepBlockReason reason) {
    switch (reason) {
      case StepBlockReason.none:
        return null;
      case StepBlockReason.validationFailed:
        return 'wizard.blocked.validation';
      case StepBlockReason.atFirstStep:
        return 'wizard.blocked.atFirst';
      case StepBlockReason.atLastStep:
        return 'wizard.blocked.atLast';
    }
  }

  // ---- the row's metric ---------------------------------------------------

  /// Structural integrity of the decomposition: the properties that have to
  /// hold for a set of steps to be a wizard rather than a list of screens.
  ///
  /// Checked against the machine's actual behaviour, not against its
  /// declaration -- a step list can look contiguous and still have a
  /// transition that skips one.
  static Map<String, bool> integrityChecks(WizardStepMachine machine) {
    final int count = machine.stepCount;
    final Set<String> ids =
        machine.steps.map((WizardStep s) => s.id).toSet();
    final List<String> allFields = <String>[
      for (final WizardStep s in machine.steps) ...s.fieldNames,
    ];
    return <String, bool>{
      'at least one step': count > 0,
      'step ids are unique': ids.length == count,
      'every step owns at least one field':
          machine.steps.every((WizardStep s) => s.fieldNames.isNotEmpty),
      'no field appears on two steps':
          allFields.toSet().length == allFields.length,
      'first and last are consistent with the index':
          machine.isFirst == (machine.index == 0) &&
              machine.isLast == (machine.index == count - 1),
      'progress is bounded': machine.progress >= 0 && machine.progress <= 1,
    };
  }

  static double structuralIntegrity(WizardStepMachine machine) {
    final Iterable<bool> r = integrityChecks(machine).values;
    return r.where((bool b) => b).length / r.length;
  }

  static List<String> integrityFailures(WizardStepMachine machine) =>
      integrityChecks(machine)
          .entries
          .where((MapEntry<String, bool> e) => !e.value)
          .map((MapEntry<String, bool> e) => e.key)
          .toList();

  static const double floor = 0.95;
  static const double optimal = 1.0;

  static const String enabledNextNote =
      'Next stays enabled and refuses with a reason, rather than being greyed '
      'out. A disabled button is unambiguous to the person who wrote it and '
      'silent to everyone else: the user sees a dead control and no statement '
      'of what is wrong. It is also skipped by some screen readers entirely, '
      'so a blind user gets no forward affordance and no explanation. "Clear '
      'affordances" is the row\'s own word, and a control that will not say '
      'why it did nothing is not clear.';

  static const String backAlwaysNote =
      'Back is never refused for validation. Validation blocks progress, not '
      'retreat; a wizard that traps someone on a step they cannot satisfy has '
      'no exit but force-quitting, which loses the form. Recorded as decision '
      'D-1 at Step 146.';

  static const String directionNote =
      'Back and Next are semantic; leading and trailing are visual. In Urdu '
      'the forward control sits on the left. The mapping lives here so no '
      'screen has to remember it, which is the difference between a rule and '
      'a convention.';
}
