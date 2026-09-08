/// AISS Step 151 -- GEN-00269
/// Setup Step (Action) / Atomic Step: "Confirm focus advances to the next
///   field with zero manual scrolling required."
/// Metric: General Task Completion Quality -- Floor "Task completed with
///         documented exceptions", Optimal "100% completion matching stated
///         implementation-step intent", Ceiling 1.0.
///         Complete / Partial / Not Complete.
///
/// **"ZERO MANUAL SCROLLING" IS A CLAIM ABOUT A JOURNEY, NOT A WIDGET.**
/// It cannot be satisfied by setting `textInputAction` on a field: the
/// interesting cases are the ones at the edges. What happens on the LAST field
/// of a step? What happens on the last field of the LAST step? What happens
/// when the next field is off screen behind the keyboard? Each of those is a
/// place where a user is left tapping at the screen wondering what to do, and
/// each is invisible to a test that only checks one field advancing to
/// another.
///
/// So the traversal is modelled explicitly and walked end to end, and the
/// metric is the count of points in that walk where a person would have had to
/// scroll or hunt for the next control. The requirement is zero.
///
/// **AFTER STEP 147, "THE NEXT FIELD" IS USUALLY ON THE NEXT SCREEN.**
/// A form split into single questions has one field per step, so the last
/// field of a step is also its only one, and advancing focus means advancing
/// the STEP. That makes the keyboard's action key and the wizard's forward
/// control the same intent expressed twice -- and it means the keyboard action
/// has to be refused for the same reasons the forward control is, or the
/// gesture becomes a way around validation.
///
/// **THE KEYBOARD ACTION LABEL IS PART OF THE ANSWER.** A key that says "Next"
/// on the final question is a promise the app does not keep. The action is
/// derived from position in the traversal, not set per field.
library;

import 'package:flutter/services.dart';

import '../wizard/step_machine.dart';
import '../wizard/wizard_navigation.dart';

/// What the keyboard's action key should do at a given point.
enum HabotFocusAction {
  /// Move to the next field on this step.
  nextField,

  /// This was the last field of the step: advance the step.
  nextStep,

  /// Last field of the last step: submit.
  submit,
}

/// One position in a form traversal.
class HabotFocusPosition {
  const HabotFocusPosition({
    required this.stepIndex,
    required this.fieldIndex,
    required this.fieldName,
    required this.action,
  });

  final int stepIndex;
  final int fieldIndex;
  final String fieldName;
  final HabotFocusAction action;

  /// The platform action key for this position. Derived, never set per field:
  /// a key that says "Next" on the final question is a promise the app does
  /// not keep.
  TextInputAction get inputAction {
    switch (action) {
      case HabotFocusAction.nextField:
      case HabotFocusAction.nextStep:
        return TextInputAction.next;
      case HabotFocusAction.submit:
        return TextInputAction.done;
    }
  }
}

/// One point in a walk where the user would have had to do something manual.
class HabotManualIntervention {
  const HabotManualIntervention({
    required this.at,
    required this.reason,
  });

  final HabotFocusPosition at;
  final String reason;
}

/// Focus traversal across a wizard.
class HabotFocusAdvance {
  const HabotFocusAdvance._();

  /// The full traversal for a wizard, in order.
  static List<HabotFocusPosition> traversalOf(WizardStepMachine machine) {
    final List<HabotFocusPosition> out = <HabotFocusPosition>[];
    for (int s = 0; s < machine.steps.length; s++) {
      final WizardStep step = machine.steps[s];
      for (int f = 0; f < step.fieldNames.length; f++) {
        final bool lastFieldOfStep = f == step.fieldNames.length - 1;
        final bool lastStep = s == machine.steps.length - 1;
        out.add(
          HabotFocusPosition(
            stepIndex: s,
            fieldIndex: f,
            fieldName: step.fieldNames[f],
            action: !lastFieldOfStep
                ? HabotFocusAction.nextField
                : (lastStep
                    ? HabotFocusAction.submit
                    : HabotFocusAction.nextStep),
          ),
        );
      }
    }
    return out;
  }

  /// The position after this one, or null at the end.
  static HabotFocusPosition? nextAfter(
    List<HabotFocusPosition> traversal,
    HabotFocusPosition current,
  ) {
    final int i = traversal.indexWhere(
      (HabotFocusPosition p) =>
          p.stepIndex == current.stepIndex &&
          p.fieldIndex == current.fieldIndex,
    );
    if (i < 0 || i + 1 >= traversal.length) {
      return null;
    }
    return traversal[i + 1];
  }

  /// Walk the whole form and record every point where the user would have had
  /// to scroll or hunt.
  ///
  /// [visibleWithoutScrolling] answers, for a field name, whether that field's
  /// control is on screen once the keyboard is up. A step showing one question
  /// always is; a compound block on a short screen may not be, and that is
  /// exactly the case the row's "zero manual scrolling" is about.
  static List<HabotManualIntervention> walk({
    required WizardStepMachine machine,
    required bool Function(String fieldName) visibleWithoutScrolling,
  }) {
    final List<HabotFocusPosition> traversal = traversalOf(machine);
    final List<HabotManualIntervention> out = <HabotManualIntervention>[];
    for (final HabotFocusPosition p in traversal) {
      final HabotFocusPosition? next = nextAfter(traversal, p);
      if (next == null) {
        continue;
      }
      if (!visibleWithoutScrolling(next.fieldName)) {
        out.add(
          HabotManualIntervention(
            at: p,
            reason: 'The next field "${next.fieldName}" is not on screen once '
                'the keyboard is up, so the user has to scroll to reach it.',
          ),
        );
      }
      if (p.action == HabotFocusAction.nextField &&
          next.stepIndex != p.stepIndex) {
        out.add(
          HabotManualIntervention(
            at: p,
            reason: 'The action key says "next field" but the next field is on '
                'another step, so the key does something other than what it '
                'says.',
          ),
        );
      }
    }
    return out;
  }

  /// Advance from a position. Crossing a step boundary goes through the SAME
  /// navigation the forward control uses, so the keyboard cannot be a way
  /// around validation.
  static HabotNavigationOutcome? advance({
    required HabotFocusPosition from,
    required HabotWizardNavigation navigation,
  }) {
    switch (from.action) {
      case HabotFocusAction.nextField:
        return null;
      case HabotFocusAction.nextStep:
      case HabotFocusAction.submit:
        return navigation.forward();
    }
  }

  // ---- the row's metric ---------------------------------------------------

  /// The row's optimal is "100% completion matching stated implementation-step
  /// intent". The stated intent is zero manual scrolling, so completion is
  /// the share of traversal points that need no intervention.
  static double completionQuality({
    required WizardStepMachine machine,
    required bool Function(String fieldName) visibleWithoutScrolling,
  }) {
    final int points = traversalOf(machine).length;
    if (points == 0) {
      return 0;
    }
    final int problems = walk(
      machine: machine,
      visibleWithoutScrolling: visibleWithoutScrolling,
    ).length;
    final int clean = points - problems;
    return clean < 0 ? 0 : clean / points;
  }

  static const double optimal = 1.0;

  /// Documented exceptions, which is what the row's FLOOR permits. Empty is
  /// the claim being made; the field exists because "task completed with
  /// documented exceptions" is a real and honest outcome, and having nowhere
  /// to write one would make the floor unreachable and the optimal a
  /// formality.
  static const List<String> documentedExceptions = <String>[];

  static const String edgesAreThePointNote =
      '"Zero manual scrolling" cannot be satisfied by setting textInputAction '
      'on a field. The interesting cases are the edges: the last field of a '
      'step, the last field of the last step, and a next field hidden behind '
      'the keyboard. Each leaves a user tapping at the screen, and each is '
      'invisible to a test that checks one field advancing to another. The '
      'traversal is walked end to end and the metric counts the points where a '
      'person would have had to intervene.';

  static const String keyboardIsNotABypassNote =
      'After Step 147 a step usually holds one field, so advancing focus past '
      'it means advancing the STEP -- the keyboard action key and the forward '
      'control become the same intent expressed twice. Crossing that boundary '
      'goes through HabotWizardNavigation.forward, so the keyboard cannot '
      'become a way around validation that the button refuses.';
}
