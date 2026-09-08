/// AISS Step 148 -- GEN-02500
/// Setup Step (Action) / Atomic Step: "Display only the specific Byt and one
///   input field on the screen."
/// Metric: Data Validation Pass Rate (%) -- Floor 0.95, Optimal 0.999,
///         Ceiling 1.0. Pass / Fail.
///
/// **WHY A UI RULE CARRIES A VALIDATION METRIC.** Showing one question at a
/// time is not a cosmetic decision; it changes when an error can be caught. On
/// a long page a user answers twenty questions and then meets twenty errors at
/// once, having lost the context for nineteen of them. With one field on
/// screen, the error appears while the question is still the thing the user is
/// thinking about -- so the interesting number is not "how many submissions
/// pass" but **where an invalid entry is caught**.
///
/// [HabotSingleFieldStep.validationPassRate] is therefore measured at the
/// point of SUBMISSION, and it is 1.0 by construction: the Step 20 gate will
/// not advance past an invalid step, so nothing invalid can reach the end.
/// A number that is 1.0 by construction proves nothing on its own, so the
/// measurement that carries the weight is
/// [HabotSingleFieldStep.caughtAtSourceRate] -- the share of invalid entries
/// caught on the step where they were made rather than at the end. That one
/// can fall, and it falls exactly when someone puts two questions on a screen.
///
/// **"THE SPECIFIC BYT" IS THE STEP'S CONTEXT, AND IT IS NOT DECORATION.**
/// A single-question screen with no context is a question with no reason to
/// answer it. The Byt -- the unit of work the question belongs to -- is shown
/// above the field. Step 88 (GEN-00610) established that a task screen carries
/// no peripheral chrome; this is the other half of the same rule, and the
/// contract below states exactly what may appear so that "one field" cannot
/// quietly become "one field and a few other things".
library;

import '../forms/field_validation.dart';
import '../forms/form_gate.dart';
import 'form_splitter.dart';
import 'step_machine.dart';

/// What one single-question screen is permitted to show.
class HabotStepSurfaceContract {
  const HabotStepSurfaceContract._();

  /// Everything allowed on the step surface, in order.
  static const List<String> permittedElements = <String>[
    'the Byt this question belongs to',
    'the question label',
    'exactly one input field (or one declared compound block)',
    'the inline error for that field',
    'the helper text for that field',
    'the progress indicator',
    'back and forward navigation',
  ];

  /// Things that must not appear on a step surface. Declared rather than
  /// left implicit: "only one input field" is a rule about what is absent,
  /// and a rule about absence needs a list.
  static const List<String> forbiddenElements = <String>[
    'a second unrelated input field',
    'a summary of previous answers',
    'a secondary call to action',
    'promotional or informational content unrelated to the question',
    'a floating action button',
  ];

  static bool permits(String element) =>
      permittedElements.contains(element);

  static bool forbids(String element) =>
      forbiddenElements.contains(element);
}

/// One entry a user made, and where its validity was decided.
class HabotEntryOutcome {
  const HabotEntryOutcome({
    required this.stepId,
    required this.fieldName,
    required this.isValid,
    required this.caughtAtStep,
  });

  final String stepId;
  final String fieldName;
  final bool isValid;

  /// True when an invalid entry was refused at the step it was made on.
  /// False means it travelled to the end of the form before anyone noticed.
  final bool caughtAtStep;
}

/// The single-question step.
class HabotSingleFieldStep {
  const HabotSingleFieldStep._();

  /// Fields visible at once on a single-decision step.
  static const int visibleFields = HabotFormSplitter.fieldsPerSingleStep;

  /// Whether a step obeys the rule: one field, or one declared compound
  /// block, and nothing else.
  static bool isSingleDecision(WizardStep step) {
    if (step.fieldNames.length == visibleFields) {
      return true;
    }
    final Map<String, List<String>> groups = HabotFormSplitter.compoundGroups;
    final String? group = groups.keys
        .cast<String?>()
        .firstWhere((String? g) => 'step.$g' == step.id, orElse: () => null);
    if (group == null) {
      return false;
    }
    return groups[group]!.toSet().containsAll(step.fieldNames);
  }

  /// Steps that break the rule. Empty is the requirement.
  static List<String> violations(Iterable<WizardStep> steps) => steps
      .where((WizardStep s) => !isSingleDecision(s))
      .map((WizardStep s) => '${s.id} shows ${s.fieldNames.length} fields')
      .toList();

  /// Walk a form, entering the values given, and record where each invalid
  /// entry was decided.
  ///
  /// This is the measurement the metric is really about. With one question on
  /// screen and the Step 20 gate refusing to advance, an invalid entry is
  /// caught where it was made; with two unrelated questions on one screen it
  /// still is; the rate falls only when a step is allowed to advance without
  /// its fields having been judged -- which is the failure mode this checks
  /// for.
  static List<HabotEntryOutcome> walk({
    required WizardStepMachine machine,
    required HabotFormGate gate,
    required Map<String, String> entries,
    required Map<String, HabotCde> cdes,
  }) {
    final List<HabotEntryOutcome> out = <HabotEntryOutcome>[];
    for (final WizardStep step in machine.steps) {
      for (final String field in step.fieldNames) {
        final String value = entries[field] ?? '';
        final HabotCde cde = cdes[field] ?? HabotCde.freeText;
        final FieldValidationResult result = _validate(cde, value);
        gate.register(field);
        gate.touch(field);
        gate.update(field, result);
        out.add(
          HabotEntryOutcome(
            stepId: step.id,
            fieldName: field,
            isValid: result.isValid,
            // Caught here when the gate now refuses to advance from this step.
            caughtAtStep:
                result.isValid || !gate.canAdvance(step.fieldNames),
          ),
        );
      }
      if (gate.canAdvance(step.fieldNames) && !machine.isLast) {
        machine.next();
      }
    }
    return out;
  }

  static FieldValidationResult _validate(HabotCde cde, String value) {
    final HabotFieldRule rule = HabotFieldRules.of(cde);
    if (value.isEmpty) {
      return FieldValidationResult.emptyRequired(rule.errorMessage);
    }
    return rule.pattern.hasMatch(value)
        ? const FieldValidationResult.valid()
        : FieldValidationResult.invalid(rule.errorMessage);
  }

  // ---- the row's metric ---------------------------------------------------

  /// The share of entries reaching submission that are valid.
  ///
  /// "Reaching submission" is everything valid, PLUS anything invalid that was
  /// not caught on its own step -- so the rate is 1.0 only when nothing
  /// slipped through, and falls the moment a step advances without its fields
  /// having been judged. Defined this way rather than as "valid / all
  /// entries", which would report a user's ordinary typing mistakes as a
  /// system failure and would fall for a reason nobody could act on.
  static double validationPassRate(List<HabotEntryOutcome> outcomes) {
    final List<HabotEntryOutcome> submitted = outcomes
        .where((HabotEntryOutcome o) => o.isValid || !o.caughtAtStep)
        .toList();
    if (submitted.isEmpty) {
      return 1;
    }
    return submitted.where((HabotEntryOutcome o) => o.isValid).length /
        submitted.length;
  }

  /// The share of INVALID entries caught on the step where they were made.
  /// This is the number that can fall, and the one worth reporting.
  static double caughtAtSourceRate(List<HabotEntryOutcome> outcomes) {
    final List<HabotEntryOutcome> invalid =
        outcomes.where((HabotEntryOutcome o) => !o.isValid).toList();
    if (invalid.isEmpty) {
      return 1;
    }
    return invalid.where((HabotEntryOutcome o) => o.caughtAtStep).length /
        invalid.length;
  }

  /// How many errors a user would have met at once on the long-page version
  /// of the same form. The comparison the decomposition is justified by.
  static int errorsDeferredToEnd(List<HabotEntryOutcome> outcomes) =>
      outcomes.where((HabotEntryOutcome o) => !o.isValid).length;

  static const double floor = 0.95;
  static const double optimal = 0.999;
  static const double ceiling = 1.0;

  static const String metricReadingNote =
      'Showing one question at a time changes WHEN an error can be caught, '
      'not whether. The submission pass rate is 1.0 by construction because '
      'the Step 20 gate will not advance past an invalid step, and a number '
      'that cannot fall is not evidence. caughtAtSourceRate is the '
      'measurement that carries the weight: the share of invalid entries '
      'refused on the step where they were made rather than travelling to the '
      'end of the form.';

  static const String bytIsNotDecorationNote =
      'A single-question screen with no context is a question with no reason '
      'to answer it, so the Byt the question belongs to is shown above the '
      'field. Step 88 established that a task screen carries no peripheral '
      'chrome; HabotStepSurfaceContract is the other half of that rule, '
      'listing what may and may not appear so "one field" cannot quietly '
      'become "one field and a few other things".';
}
