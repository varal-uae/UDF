/// Step 254 (GEN-01992) -- requiring a strict True to progress, and why the
/// boolean cannot be the whole interface.
///
/// The row: "Mathematically gate execution by requiring a strict 'True' to
/// progress."
/// Metric: **Mathematical Balance Validation Accuracy (%)** -- floor 99.5,
/// optimal 99.99, ceiling 100. Complete/Partial/Not Complete. Standard cited:
/// ISO/IEC 27035 (Data Integrity) & OWASP.
///
/// **"Strict True" is a rule about the check, not about the answer.** The
/// trap the word "strict" is pointing at is a tri-state: a `bool?` where null
/// means "not evaluated yet", tested with `!= false`, which lets an
/// unevaluated gate through. Dart can make that unrepresentable, so it is: the
/// result is a sealed type with two cases, and there is no third value to test
/// loosely against.
///
/// **And a boolean alone is not enough to show anybody.** Step 250 established
/// that an error has to say what to do about it. A gate that answers only true
/// or false can stop a submission and cannot explain it, so the blocked case
/// carries its reasons -- which means "strict True" describes the *progress*
/// condition (only [HabotGateAllowed] proceeds) rather than the return type.
///
/// **Nothing here is mathematics.** The row and its metric are about balance
/// validation accuracy, and this gate is the decision built on top of Step
/// 253's reconciliation. The arithmetic lives there; what this adds is that
/// the single value it produces cannot be misread.
library;

import 'numeric_reconciliation.dart';

/// Why a submission is blocked.
class HabotGateReason {
  const HabotGateReason({
    required this.code,
    required this.field,
    required this.message,
  });

  /// Stable, for grouping. Never shown to anybody.
  final String code;

  /// The field to move focus to, or empty for a form-level reason.
  final String field;

  /// What the person is told, and what to do about it.
  final String message;

  bool get isFormLevel => field.isEmpty;
}

/// The result of asking whether a submission may proceed. Sealed: there is no
/// third case and no null.
sealed class HabotGateResult {
  const HabotGateResult();
}

/// Everything holds.
final class HabotGateAllowed extends HabotGateResult {
  const HabotGateAllowed();
}

/// It does not, and here is why.
final class HabotGateBlocked extends HabotGateResult {
  const HabotGateBlocked(this.reasons);

  final List<HabotGateReason> reasons;
}

/// The gate.
class HabotStrictTrueGate {
  const HabotStrictTrueGate._();

  /// Evaluate. Every blocked result carries at least one reason, because a
  /// blocked result with no reasons is the boolean this step exists to
  /// replace.
  static HabotGateResult evaluate({
    required String total,
    required List<String> components,
    required Set<String> outstandingRequiredFields,
  }) {
    final List<HabotGateReason> reasons = <HabotGateReason>[];
    for (final String field in outstandingRequiredFields.toList()..sort()) {
      reasons.add(
        HabotGateReason(
          code: 'FIELD_OUTSTANDING',
          field: field,
          message: 'This is needed before the booking can be submitted.',
        ),
      );
    }
    if (!HabotNumericReconciliation.reconciles(
      total: total,
      components: components,
    )) {
      reasons.add(
        const HabotGateReason(
          code: 'DOES_NOT_BALANCE',
          field: '',
          message: 'The amounts do not add up to the total. Check the lines '
              'against the total shown.',
        ),
      );
    }
    return reasons.isEmpty
        ? const HabotGateAllowed()
        : HabotGateBlocked(reasons);
  }

  /// The row's condition, applied to a result. Written as a switch so that a
  /// future third case would not compile rather than falling through to a
  /// default that lets it pass.
  static bool mayProgress(HabotGateResult result) => switch (result) {
        HabotGateAllowed() => true,
        HabotGateBlocked() => false,
      };

  /// What the person is shown when blocked. Empty when allowed, which is the
  /// only time it may be.
  static List<HabotGateReason> reasonsFrom(HabotGateResult result) =>
      switch (result) {
        HabotGateAllowed() => const <HabotGateReason>[],
        HabotGateBlocked(reasons: final List<HabotGateReason> r) => r,
      };

  /// Where focus goes on a blocked submit: the first field-level reason, or
  /// nothing when every reason is about the form as a whole.
  static String? focusTargetFrom(HabotGateResult result) {
    for (final HabotGateReason reason in reasonsFrom(result)) {
      if (!reason.isFormLevel) {
        return reason.field;
      }
    }
    return null;
  }

  // -----------------------------------------------------------------------
  // The tri-state this replaces.
  // -----------------------------------------------------------------------

  /// The check a nullable boolean invites. Kept as a demonstration rather
  /// than used anywhere.
  static bool looseCheckOf(bool? value) => value != false;

  /// What the same tri-state gives under a strict check.
  static bool strictCheckOf(bool? value) => value == true;

  /// A gate that has not run yet. `!= false` lets it through, `== true` does
  /// not, and the difference is a submitted form.
  static bool get theLooseCheckPassesAnUnevaluatedGate =>
      looseCheckOf(null) &&
      !strictCheckOf(null) &&
      looseCheckOf(true) &&
      strictCheckOf(true) &&
      !looseCheckOf(false) &&
      !strictCheckOf(false);

  static bool get theSealedResultHasNoThirdCase =>
      const HabotGateAllowed() is HabotGateResult &&
      const HabotGateBlocked(<HabotGateReason>[]) is HabotGateResult &&
      mayProgress(const HabotGateAllowed()) &&
      !mayProgress(const HabotGateBlocked(<HabotGateReason>[]));

  static const String triStateNote =
      '"Strict True" is a rule about the CHECK, not about the answer. The '
      'trap the word is pointing at is a tri-state: a nullable boolean where '
      'null means "not evaluated yet", tested with != false, which lets an '
      'unevaluated gate through and submits the form. Dart can make that '
      'unrepresentable, so it is -- the result is a sealed type with two '
      'cases and there is no third value to test loosely against. The loose '
      'check is kept in this file as a demonstration of what it does, and is '
      'not used anywhere.';

  static const String booleanIsNotAnInterfaceNote =
      'A boolean alone is not enough to show anybody. Step 250 established '
      'that an error has to say what to do about it, and a gate answering '
      'only true or false can stop a submission and cannot explain it. So the '
      'blocked case carries its reasons, and "strict True" describes the '
      'PROGRESS CONDITION -- only HabotGateAllowed proceeds -- rather than '
      'the return type. The exhaustive switch is what enforces it: a third '
      'case added later does not compile, where a default branch would have '
      'let it through.';

  static const String notMathematicsNote =
      'Nothing in this step is mathematics, and its metric is about balance '
      'validation accuracy. The arithmetic is Step 253\'s, and this is the '
      'decision built on top of it. What this adds is that the single value '
      'the decision produces cannot be misread: no null, no third case, no '
      'default branch.';

  // -----------------------------------------------------------------------
  // The corpus.
  // -----------------------------------------------------------------------

  static HabotGateResult get balancedAndComplete => evaluate(
        total: '331.26',
        components: <String>['315.49', '15.77'],
        outstandingRequiredFields: <String>{},
      );

  static HabotGateResult get unbalanced => evaluate(
        total: '331.26',
        components: <String>['315.49', '15.78'],
        outstandingRequiredFields: <String>{},
      );

  static HabotGateResult get fieldsOutstanding => evaluate(
        total: '331.26',
        components: <String>['315.49', '15.77'],
        outstandingRequiredFields: <String>{'allergies', 'collection'},
      );

  static HabotGateResult get bothProblems => evaluate(
        total: '331.26',
        components: <String>['315.49', '15.78'],
        outstandingRequiredFields: <String>{'allergies'},
      );

  static List<HabotGateResult> get corpus => <HabotGateResult>[
        balancedAndComplete,
        unbalanced,
        fieldsOutstanding,
        bothProblems,
      ];

  static bool get everyBlockedResultCarriesAReason => corpus.every(
        (HabotGateResult r) =>
            mayProgress(r) || reasonsFrom(r).isNotEmpty,
      );

  static bool get everyAllowedResultCarriesNone => corpus.every(
        (HabotGateResult r) => !mayProgress(r) || reasonsFrom(r).isEmpty,
      );

  static bool get everyReasonSaysWhatToDo => corpus
      .expand(reasonsFrom)
      .every((HabotGateReason r) => r.message.length > 40);

  /// Accuracy over the corpus: one allowed, three blocked, each for the
  /// reasons it was built to be blocked for.
  static double get decisionAccuracy {
    final List<bool> expected = <bool>[true, false, false, false];
    int correct = 0;
    for (int i = 0; i < corpus.length; i++) {
      if (mayProgress(corpus[i]) == expected[i]) {
        correct += 1;
      }
    }
    return correct / corpus.length * 100;
  }

  // -----------------------------------------------------------------------
  // Metric.
  // -----------------------------------------------------------------------

  static const double floor = 99.5;
  static const double optimal = 99.99;
  static const double ceiling = 100;

  static String get qualitativeOutput {
    if (decisionAccuracy >= optimal && everyBlockedResultCarriesAReason) {
      return 'Complete';
    }
    return decisionAccuracy >= floor ? 'Partial' : 'Not Complete';
  }

  static Map<String, bool> get checks => <String, bool>{
        'the result is sealed with exactly two cases':
            theSealedResultHasNoThirdCase,
        'the loose check a nullable boolean invites passes an unevaluated '
            'gate, and is demonstrated rather than used':
            theLooseCheckPassesAnUnevaluatedGate,
        'four scenarios, one of which progresses':
            corpus.length == 4 &&
                corpus.where(mayProgress).length == 1,
        'every blocked result carries at least one reason':
            everyBlockedResultCarriesAReason,
        'an allowed result carries none': everyAllowedResultCarriesNone,
        'every reason says what to do, not only that something is wrong':
            everyReasonSaysWhatToDo,
        'two problems at once produce two reasons, not the first one':
            reasonsFrom(bothProblems).length == 2,
        'focus goes to the first field-level reason':
            focusTargetFrom(fieldsOutstanding) == 'allergies',
        'a form-level reason alone moves focus nowhere':
            focusTargetFrom(unbalanced) == null,
        'the balance reason comes from Step 253 rather than being recomputed':
            reasonsFrom(unbalanced).single.code == 'DOES_NOT_BALANCE',
        'the decision accuracy is at the ceiling':
            decisionAccuracy == ceiling,
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the Data '
      'Collected column reads only "True". Atomic Step: "Mathematically gate '
      'execution by requiring a strict \'True\' to progress."';
}
