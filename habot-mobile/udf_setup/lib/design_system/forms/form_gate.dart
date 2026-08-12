/// AISS: IS12-CSIVW-011-AS01 substep 4 -- "Unlock or freeze form confirmation
///       keys based on field validation status."
/// AISS: IS02-CSIVW-005-AS01 substep 3 -- "Program form frameworks to freeze
///       submission actions if active errors are present."
///       Poka-Yoke: "Form submission actions remain physically locked until all
///       active field errors are resolved."
/// AISS: BPTR-0160 Self-Chasing -- "User cannot tap the submit button while the
///       field is invalid."
/// AISS: FIEVR-033 -- "Validate all inputs inside the current card before
///       letting users slide to subsequent steps."
///
/// One object owns "is this form submittable". Four separate steps in the sheet
/// all describe the same rule; implementing it once means they cannot drift
/// apart.
library;

import 'package:flutter/foundation.dart';

import 'field_validation.dart';

/// Tracks the validation state of a set of named fields and exposes a single
/// authoritative answer to "may this form be submitted?".
class HabotFormGate extends ChangeNotifier {
  HabotFormGate({Set<String>? requiredFields})
    : _requiredFields = requiredFields ?? <String>{};

  final Set<String> _requiredFields;
  final Map<String, FieldValidationResult> _results =
      <String, FieldValidationResult>{};

  /// IS12-CSIVW-011 Self-Chasing: "Fields recheck validation criteria the
  /// second an error is edited, clearing warnings quickly once values pass."
  /// A field only shows its error once it has been touched (blurred or
  /// submitted), so a pristine form is not a wall of red.
  final Set<String> _touched = <String>{};

  Set<String> get requiredFields => Set<String>.unmodifiable(_requiredFields);

  Map<String, FieldValidationResult> get results =>
      Map<String, FieldValidationResult>.unmodifiable(_results);

  Iterable<String> get invalidFields => _results.entries
      .where((MapEntry<String, FieldValidationResult> e) => !e.value.isValid)
      .map((MapEntry<String, FieldValidationResult> e) => e.key);

  /// True when a field has been touched and is failing -- i.e. its error is
  /// visible to the user.
  bool showsErrorFor(String field) =>
      _touched.contains(field) && !(_results[field]?.isValid ?? true);

  String? visibleMessageFor(String field) =>
      showsErrorFor(field) ? _results[field]?.message : null;

  /// Registers a field so an untouched required field still blocks submission.
  void register(String field, {bool required = true}) {
    if (required) {
      _requiredFields.add(field);
    }
    _results.putIfAbsent(
      field,
      () => required
          ? const FieldValidationResult.emptyRequired('This field is required.')
          : const FieldValidationResult.valid(),
    );
  }

  /// IS02-CSIVW-005 substep 1: called from the field's blur event.
  void touch(String field) {
    if (_touched.add(field)) {
      notifyListeners();
    }
  }

  /// Records a new result. Notifies only when something the user can see
  /// actually changed.
  void update(String field, FieldValidationResult result) {
    final FieldValidationResult? previous = _results[field];
    _results[field] = result;
    final bool visibilityChanged =
        previous == null ||
        previous.isValid != result.isValid ||
        previous.message != result.message;
    if (visibilityChanged) {
      notifyListeners();
    }
  }

  /// Mark every field touched -- used when the user presses a disabled-looking
  /// submit, so all outstanding errors surface at once instead of one per tap.
  void revealAllErrors() {
    _touched.addAll(_results.keys);
    notifyListeners();
  }

  /// THE gate. Every submit control and every step transition asks this.
  bool get canSubmit {
    for (final String field in _requiredFields) {
      final FieldValidationResult? result = _results[field];
      if (result == null || !result.isValid) {
        return false;
      }
    }
    return _results.values.every((FieldValidationResult r) => r.isValid);
  }

  /// Same question, scoped to one step of a wizard (FIEVR-033).
  bool canAdvance(Iterable<String> fieldsInStep) {
    for (final String field in fieldsInStep) {
      final FieldValidationResult? result = _results[field];
      if (result == null || !result.isValid) {
        return false;
      }
    }
    return true;
  }

  @visibleForTesting
  void reset() {
    _results.clear();
    _touched.clear();
    _requiredFields.clear();
    notifyListeners();
  }
}
