/// AISS Step 99 -- GEN-04572
/// "Add accessibility hints detailing results of performing actions on complex
///  interactive components."
/// Metric: Accessibility Conformance Score -- floor 90% (partial AA),
///         optimal 100% (full AA).
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// THE DISTINCTION THIS STEP RESTS ON. A semantic LABEL says what a control
/// *is* -- "Accept". A semantic HINT says what happens if you activate it --
/// "assigns this job to you and removes it from the open queue". Every
/// interactive component in Steps 1-95 carries a label. None of them carries a
/// hint. A sighted user reads the consequence off the surrounding screen; a
/// screen-reader user is told the verb and nothing else.
///
/// WHY A CATALOGUE RATHER THAN A PARAMETER. A `hint:` parameter on every
/// widget would be a parameter everyone forgets, and a forgotten hint is
/// invisible -- nothing renders wrong, nothing throws. So hints are declared
/// once, per ACTION KIND, in a catalogue that is checked for completeness:
/// [HabotHints.isComplete] is false the moment an action kind is added without
/// one, and GEN-04572-G1 fails the build on it. That is the same shape as the
/// Step 19 error templates and the Step 16 field rules, for the same reason.
///
/// MUFCE-028 COMPATIBILITY: a hint is semantic, not visual. Nothing here
/// renders on hover, and nothing here renders at all. This must stay true --
/// the moment a hint becomes a tooltip it is unreachable on a touch device.
library;

import 'package:flutter/widgets.dart';

/// The interactive actions this app performs that have a consequence worth
/// announcing. Deliberately not "every button" -- a hint on a control whose
/// consequence is obvious is noise, and noise is what makes people switch a
/// screen reader off.
enum HabotActionKind {
  /// Takes an open job and assigns it to the current worker.
  acceptTask,

  /// Returns a held job to the open queue.
  releaseTask,

  /// Marks a job finished and sends it for review.
  submitTask,

  /// Approves a submitted batch, which is not reversible from here.
  approveBatch,

  /// Rejects a submitted batch and returns it to its author.
  rejectBatch,

  /// Discards unsaved edits on the current form.
  discardChanges,

  /// Retries the operation that just failed.
  retryFailed,

  /// Opens the row's full metadata in a drawer.
  discloseMetadata,

  /// Changes which records the dashboard is showing.
  applyFilter,

  /// Removes every filter currently applied.
  clearFilters,

  /// Turns a notification category on or off for this account.
  togglePreference,

  /// Dismisses a system alert without acting on it.
  acknowledgeAlert,

  /// Moves the wizard to the next step, committing what is on this one.
  advanceStep,

  /// Moves the wizard back, keeping what is on this step.
  retreatStep,
}

/// One hint: what activating this kind of control does.
@immutable
class HabotHint {
  const HabotHint({
    required this.kind,
    required this.hint,
    required this.reversible,
  });

  final HabotActionKind kind;

  /// Announced after the label. Phrased as a consequence, present tense, no
  /// leading verb duplication ("Accept, assigns this job to you").
  final String hint;

  /// Whether the consequence can be undone from the app. Irreversible actions
  /// say so in the hint, because "are you sure?" is a dialog a screen-reader
  /// user meets AFTER they have already decided.
  final bool reversible;

  @override
  String toString() => '${kind.name}: $hint';
}

/// The catalogue.
class HabotHints {
  const HabotHints._();

  static const Map<HabotActionKind, HabotHint> _hints =
      <HabotActionKind, HabotHint>{
        HabotActionKind.acceptTask: HabotHint(
          kind: HabotActionKind.acceptTask,
          hint:
              'assigns this job to you and removes it from the open queue. '
              'You can release it again.',
          reversible: true,
        ),
        HabotActionKind.releaseTask: HabotHint(
          kind: HabotActionKind.releaseTask,
          hint:
              'returns this job to the open queue. Anyone on your team can '
              'take it after that.',
          reversible: true,
        ),
        HabotActionKind.submitTask: HabotHint(
          kind: HabotActionKind.submitTask,
          hint:
              'sends your work for review and locks the form. This cannot be '
              'undone from here.',
          reversible: false,
        ),
        HabotActionKind.approveBatch: HabotHint(
          kind: HabotActionKind.approveBatch,
          hint:
              'approves every record in this batch. This cannot be undone '
              'from here.',
          reversible: false,
        ),
        HabotActionKind.rejectBatch: HabotHint(
          kind: HabotActionKind.rejectBatch,
          hint:
              'returns this batch to whoever submitted it, with your note '
              'attached.',
          reversible: true,
        ),
        HabotActionKind.discardChanges: HabotHint(
          kind: HabotActionKind.discardChanges,
          hint: 'throws away what you have typed on this form since it opened.',
          reversible: false,
        ),
        HabotActionKind.retryFailed: HabotHint(
          kind: HabotActionKind.retryFailed,
          hint: 'tries the last action again. Nothing is sent twice.',
          reversible: true,
        ),
        HabotActionKind.discloseMetadata: HabotHint(
          kind: HabotActionKind.discloseMetadata,
          hint:
              'opens a drawer describing where this figure comes from and how '
              'it is worked out.',
          reversible: true,
        ),
        HabotActionKind.applyFilter: HabotHint(
          kind: HabotActionKind.applyFilter,
          hint:
              'narrows the list to matching records. The totals above change '
              'with it.',
          reversible: true,
        ),
        HabotActionKind.clearFilters: HabotHint(
          kind: HabotActionKind.clearFilters,
          hint: 'removes every filter and shows the full list again.',
          reversible: true,
        ),
        HabotActionKind.togglePreference: HabotHint(
          kind: HabotActionKind.togglePreference,
          hint:
              'changes what this account is notified about. The change is '
              'saved as you make it.',
          reversible: true,
        ),
        HabotActionKind.acknowledgeAlert: HabotHint(
          kind: HabotActionKind.acknowledgeAlert,
          hint:
              'closes this alert without changing anything. It will not be '
              'shown again.',
          reversible: false,
        ),
        HabotActionKind.advanceStep: HabotHint(
          kind: HabotActionKind.advanceStep,
          hint:
              'moves to the next step, keeping what you have entered on this '
              'one.',
          reversible: true,
        ),
        HabotActionKind.retreatStep: HabotHint(
          kind: HabotActionKind.retreatStep,
          hint:
              'moves back a step. What you entered on this step is kept.',
          reversible: true,
        ),
      };

  static HabotHint of(HabotActionKind kind) => _hints[kind]!;

  static Iterable<HabotHint> get all => _hints.values;

  /// Every action kind has a hint. False the moment one is added without.
  static bool get isComplete => _hints.length == HabotActionKind.values.length;

  static List<HabotActionKind> get missing => HabotActionKind.values
      .where((HabotActionKind k) => !_hints.containsKey(k))
      .toList();

  /// An irreversible action must say so. This is the rule that stops the
  /// catalogue drifting into a list of pleasant-sounding sentences.
  static List<HabotHint> get irreversibleWithoutWarning => _hints.values
      .where(
        (HabotHint h) =>
            !h.reversible &&
            !h.hint.toLowerCase().contains('cannot be undone') &&
            !h.hint.toLowerCase().contains('throws away') &&
            !h.hint.toLowerCase().contains('will not be shown again'),
      )
      .toList();
}

/// Wraps an interactive child so a screen reader announces the label, then the
/// consequence.
///
/// The hint is not a parameter -- it comes from the catalogue via [kind], so a
/// caller cannot supply a worse one, and improving a hint improves it
/// everywhere at once.
class HabotHintedAction extends StatelessWidget {
  const HabotHintedAction({
    required this.kind,
    required this.label,
    required this.child,
    this.enabled = true,
    super.key,
  });

  final HabotActionKind kind;

  /// What the control IS. The hint says what it DOES.
  final String label;

  final Widget child;
  final bool enabled;

  HabotHint get resolvedHint => HabotHints.of(kind);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: label,
      hint: resolvedHint.hint,
      child: ExcludeSemantics(child: child),
    );
  }
}
