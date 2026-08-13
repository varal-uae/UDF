/// AISS: FIEVR-033-A01 substep 1 -- "Define step configuration paths inside
/// localized form state machines."
/// Poka-Yoke: "Saves entered inputs locally if an accidental view closure
/// occurs, allowing users to resume entries instantly."
/// Self-Chasing: "Testing routines check that validation errors block forward
/// progress tracking loops across all form steps."
///
/// The state machine is deliberately separate from the widget: advancing,
/// retreating and gating are pure operations on data, so the rules can be
/// tested exhaustively without a single pump.
library;

import 'package:flutter/foundation.dart';

import '../forms/form_gate.dart';

/// One step of a wizard.
@immutable
class WizardStep {
  const WizardStep({
    required this.id,
    required this.title,
    required this.fieldNames,
  });

  final String id;
  final String title;

  /// The fields that must validate before this step may be left.
  final List<String> fieldNames;
}

/// Why a transition was refused.
enum StepBlockReason { none, atFirstStep, atLastStep, validationFailed }

/// Drives a multi-step form. Owns the current index, the local draft, and the
/// rule that you cannot go forward with errors behind you.
class WizardStepMachine extends ChangeNotifier {
  WizardStepMachine({required this.steps, required this.gate})
    : assert(steps.isNotEmpty, 'A wizard needs at least one step.');

  final List<WizardStep> steps;
  final HabotFormGate gate;

  int _index = 0;
  StepBlockReason _lastBlock = StepBlockReason.none;

  /// Poka-Yoke: the local draft. Survives an accidental view closure because it
  /// lives on the machine, not in the widget's State.
  final Map<String, String> _draft = <String, String>{};

  int get index => _index;
  WizardStep get current => steps[_index];
  int get stepCount => steps.length;
  bool get isFirst => _index == 0;
  bool get isLast => _index == steps.length - 1;
  StepBlockReason get lastBlock => _lastBlock;

  Map<String, String> get draft => Map<String, String>.unmodifiable(_draft);

  /// 0.0 .. 1.0 across the wizard. Used by the progress dot row.
  double get progress => steps.length == 1 ? 1.0 : _index / (steps.length - 1);

  void saveDraftValue(String field, String value) {
    _draft[field] = value;
  }

  void restoreDraft(Map<String, String> saved) {
    _draft
      ..clear()
      ..addAll(saved);
    notifyListeners();
  }

  /// UX implementation row: "Validate all inputs inside the current card before
  /// letting users slide to subsequent steps."
  bool get canAdvance => gate.canAdvance(current.fieldNames);

  /// Attempts to move forward. Returns true only if it actually moved.
  bool next() {
    if (isLast) {
      _lastBlock = StepBlockReason.atLastStep;
      notifyListeners();
      return false;
    }
    if (!canAdvance) {
      _lastBlock = StepBlockReason.validationFailed;
      // Surface every outstanding error at once rather than one per attempt.
      gate.revealAllErrors();
      notifyListeners();
      return false;
    }
    _index++;
    _lastBlock = StepBlockReason.none;
    notifyListeners();
    return true;
  }

  /// Going back is always allowed -- a user must never be trapped in a step by
  /// their own typo.
  bool previous() {
    if (isFirst) {
      _lastBlock = StepBlockReason.atFirstStep;
      notifyListeners();
      return false;
    }
    _index--;
    _lastBlock = StepBlockReason.none;
    notifyListeners();
    return true;
  }

  /// Jumping is only permitted backwards, or forwards into a step whose
  /// predecessors all validate.
  bool jumpTo(int target) {
    if (target < 0 || target >= steps.length) {
      return false;
    }
    if (target <= _index) {
      _index = target;
      _lastBlock = StepBlockReason.none;
      notifyListeners();
      return true;
    }
    for (int i = _index; i < target; i++) {
      if (!gate.canAdvance(steps[i].fieldNames)) {
        _lastBlock = StepBlockReason.validationFailed;
        notifyListeners();
        return false;
      }
    }
    _index = target;
    _lastBlock = StepBlockReason.none;
    notifyListeners();
    return true;
  }

  /// Every field across every step, in order. Used to register the gate.
  List<String> get allFields =>
      steps.expand((WizardStep s) => s.fieldNames).toList(growable: false);
}
