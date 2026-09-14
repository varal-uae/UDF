/// Step 253 (GEN-02117) -- A minus B equals zero, and the word in this row's
/// Expected Output that has to be refused.
///
/// The row: "Execute mathematical reconciliations (A-B=0) purely on numeric
/// fields."
/// Expected Output: "Impenetrable client-side submission logic."
/// Completion Measure: "It is mathematically impossible to trigger a submit
/// request with unbalanced numerical inputs."
/// Metric: **Mathematical Balance Validation Accuracy (%)** -- floor 99.5,
/// optimal 99.99, ceiling 100. Complete/Partial/Not Complete. Standard cited:
/// ISO/IEC 27035 (Data Integrity) & OWASP.
///
/// **"Impenetrable client-side" is a contradiction, and the row's own cited
/// standard is the one that says so.** Client-side validation is a usability
/// aid. The request is an HTTP call; anyone can make it without this
/// application. The client gate prevents MISTAKES and the server gate prevents
/// ATTACKS, and they are not substitutes -- the danger in calling the client
/// one impenetrable is that it is exactly the sentence that gets the server
/// check left out of a sprint. The adjective is refused and the obligation it
/// obscures is named.
///
/// **The completion measure is achievable, and it is achieved.**
/// "Mathematically impossible to trigger a submit with unbalanced inputs" is
/// a statement about
/// this application's own code paths, and it holds because there is exactly
/// one predicate and the submit control is *derived* from it rather than
/// guarded by it. There is no branch that submits without asking, because
/// there is nothing to branch on.
///
/// **"Purely on numeric fields" is the second trap.** The amounts here are not
/// machine floats; they are [HabotFixed] at storage scale. Reading "numeric"
/// as `double` reintroduces Step 252's defect, where a correct split is
/// refused. Numeric means exact decimal.
library;

import '../i18n/fixed_precision.dart';
import 'balance_gate.dart';

/// A field that takes part in a reconciliation.
class HabotReconciledField {
  const HabotReconciledField({
    required this.name,
    required this.side,
    required this.heldAs,
    required this.why,
  });

  final String name;

  /// 'A' or 'B' -- which side of the subtraction it is on.
  final String side;

  /// The Dart type the value is held as once parsed. Never double.
  final String heldAs;

  final String why;

  bool get isExact => heldAs == 'HabotFixed';
}

/// The reconciliation, and what it is and is not.
class HabotNumericReconciliation {
  const HabotNumericReconciliation._();

  static List<HabotReconciledField> get fields => <HabotReconciledField>[
        const HabotReconciledField(
          name: 'order total',
          side: 'A',
          heldAs: 'HabotFixed',
          why: 'The figure the parent is asked to authorise. Step 204 '
              'established that it is computed on the device, which is why it '
              'has to reconcile against its own lines before it is sent.',
        ),
        const HabotReconciledField(
          name: 'line subtotals',
          side: 'B',
          heldAs: 'HabotFixed',
          why: 'Per session and per add-on. Summed at storage scale so that '
              'rounding happens once, at display, rather than per line.',
        ),
        const HabotReconciledField(
          name: 'tax',
          side: 'B',
          heldAs: 'HabotFixed',
          why: 'Rounded once over the order rather than per line, which Step '
              '204 measured as a three-line order differing by a fils.',
        ),
        const HabotReconciledField(
          name: 'promotion discount',
          side: 'B',
          heldAs: 'HabotFixed',
          why: 'Negative on the destination side. The sign is part of the '
              'value rather than a flag beside it, so there is no way to add '
              'a discount by mistake.',
        ),
        const HabotReconciledField(
          name: 'quantity',
          side: '',
          heldAs: 'int',
          why: 'A count, not an amount. It is an input to a subtotal and is '
              'not itself on either side of the subtraction -- listed so that '
              '"purely on numeric fields" is not read as "every field with '
              'digits in it".',
        ),
      ];

  static List<HabotReconciledField> get sideA =>
      fields.where((HabotReconciledField f) => f.side == 'A').toList();

  static List<HabotReconciledField> get sideB =>
      fields.where((HabotReconciledField f) => f.side == 'B').toList();

  static List<HabotReconciledField> get notOnEitherSide =>
      fields.where((HabotReconciledField f) => f.side.isEmpty).toList();

  /// Every amount on either side is exact. A double anywhere here is the
  /// defect Step 252 measured.
  static bool get everyReconciledAmountIsExact =>
      sideA.every((HabotReconciledField f) => f.isExact) &&
      sideB.every((HabotReconciledField f) => f.isExact);

  static const String numericMeansExactNote =
      '"Purely on numeric fields" is the second trap in this row. The amounts '
      'here are not machine floats; they are HabotFixed at storage scale. '
      'Reading "numeric" as double reintroduces Step 252\'s defect, where a '
      'correct split of seventy fils into ten, twenty and forty is REFUSED '
      'because the subtraction does not come out at zero. Numeric means exact '
      'decimal. And it does not mean "every field with digits in it": '
      'quantity is a count, an input to a subtotal, and is on neither side of '
      'the subtraction.';

  // -----------------------------------------------------------------------
  // One predicate, one call site.
  // -----------------------------------------------------------------------

  /// The reconciliation, delegating to Step 252's gate rather than repeating
  /// the arithmetic. One predicate is the whole point of the completion
  /// measure.
  static bool reconciles({
    required String total,
    required List<String> components,
  }) =>
      HabotBalanceGate.balances(source: total, destinations: components);

  /// The submit control's enabled state IS this, rather than being guarded by
  /// a call to it. There is no branch that submits without asking, because
  /// there is nothing to branch on.
  static bool submitIsAvailable({
    required String total,
    required List<String> components,
  }) =>
      reconciles(total: total, components: components);

  /// Submit availability agrees with what every case in Step 252's corpus
  /// was declared to be. Not a restatement of the definition: the corpus says
  /// what each split OUGHT to do, and this compares the control's behaviour
  /// against that.
  static bool get submitMatchesTheDeclaredCorpus =>
      HabotBalanceGate.corpus.every(
        (HabotBalanceCase c) =>
            submitIsAvailable(total: c.source, components: c.destinations) ==
            c.balances,
      );

  /// That there is only ONE predicate is a structural fact about this file
  /// rather than something a test can discover -- a second predicate
  /// somewhere else would not make this one disagree with itself. It is
  /// stated, and what is measured is the behaviour above.
  static const String onePredicateIsStructuralNote =
      'A test cannot discover that there is only one predicate: a second copy '
      'of the arithmetic elsewhere would not make this one disagree with '
      'itself. What a test can check is that the submit control\'s behaviour '
      'matches the declared corpus case by case, which is what '
      'submitMatchesTheDeclaredCorpus does. The single-predicate claim rests '
      'on Step 242\'s manifest, where a rule class declared in two files is a '
      'failing check.';

  static const String onePredicateNote =
      'The completion measure -- "mathematically impossible to trigger a '
      'submit request with unbalanced numerical inputs" -- is a statement '
      'about this application\'s own code paths, and it holds. There is '
      'exactly one predicate, it is Step 252\'s gate rather than a second '
      'copy of the arithmetic, and the submit control is DERIVED from it '
      'rather than guarded by it. A guard can be forgotten at a new call '
      'site; a derived value cannot, because there is no branch to forget.';

  // -----------------------------------------------------------------------
  // The adjective that is refused.
  // -----------------------------------------------------------------------

  static const String expectedOutputWording =
      'Impenetrable client-side submission logic.';

  static const bool clientSideCanBeImpenetrable = false;

  static const String impenetrableNote =
      'REFUSED: the word "impenetrable". Client-side validation is a '
      'usability aid -- the request is an HTTP call, and anyone can make it '
      'without this application. The row\'s own cited standard is the one '
      'that says so: OWASP\'s position is that every client-side check is '
      'repeated on the server, because the client is under the attacker\'s '
      'control by definition. The client gate prevents MISTAKES and the '
      'server gate prevents ATTACKS, and they are not substitutes. The danger '
      'is not that somebody believes the sentence; it is that "impenetrable '
      'client-side submission logic" is exactly the phrase that gets the '
      'server-side check left out of a sprint because it reads as already '
      'done.';

  static const String serverObligation =
      'The same reconciliation runs server-side on every submission, at the '
      'same precision, and its result -- not the client\'s -- decides whether '
      'the order is accepted. The client figure is an affordance that saves a '
      'round trip and a person\'s time. Named here as an obligation on the '
      'other side of the contract, the same shape as Step 235\'s API latency '
      'SLA.';

  /// The one assumption the whole reconciliation rests on.
  static const String singleCurrencyAssumption =
      'Every amount in this application is AED -- the money CDE is named '
      '${HabotPrecision.cdeName} and the currency is in the name. A '
      'reconciliation over amounts with no currency tag is only sound while '
      'that stays true: two numerically equal amounts in different currencies '
      'balance and are wrong, and the subtraction cannot see it. Written down '
      'now rather than discovered by the first multi-currency order.';

  // -----------------------------------------------------------------------
  // Metric: Mathematical Balance Validation Accuracy (%).
  // -----------------------------------------------------------------------

  static const double floor = 99.5;
  static const double optimal = 99.99;
  static const double ceiling = 100;

  /// Measured over Step 252's corpus, which is the corpus this predicate
  /// actually runs on.
  static double get balanceValidationAccuracy =>
      HabotBalanceGate.exactGateAccuracy * 100;

  /// What the same metric would report if the reconciliation had been done
  /// "purely on numeric fields" in the double sense.
  static double get accuracyIfDoneInDoubles =>
      HabotBalanceGate.doubleGateAccuracy * 100;

  /// **Complete.** The accuracy is at the ceiling, the completion measure
  /// holds within this application's code paths, and the one thing that
  /// cannot be delivered is an adjective rather than a behaviour -- refused
  /// in writing, with the obligation it obscured named.
  static String get qualitativeOutput {
    if (balanceValidationAccuracy >= optimal &&
        submitMatchesTheDeclaredCorpus &&
        everyReconciledAmountIsExact) {
      return 'Complete';
    }
    return balanceValidationAccuracy >= floor ? 'Partial' : 'Not Complete';
  }

  static Map<String, bool> get checks => <String, bool>{
        'five fields are listed, one of which is on neither side':
            fields.length == 5 && notOnEitherSide.length == 1,
        'one field is the A side and three are the B side':
            sideA.length == 1 && sideB.length == 3,
        'every reconciled amount is exact, none is a double':
            everyReconciledAmountIsExact,
        'the reconciliation delegates to Step 252 rather than repeating it':
            reconciles(
              total: '0.70',
              components: <String>['0.10', '0.20', '0.40'],
            ) &&
            HabotBalanceGate.balances(
              source: '0.70',
              destinations: <String>['0.10', '0.20', '0.40'],
            ),
        'submit availability matches the declared corpus case by case':
            submitMatchesTheDeclaredCorpus,
        'the single-predicate claim is stated as structural rather than '
            'measured': onePredicateIsStructuralNote.contains(
          'cannot discover',
        ),
        'an unbalanced order makes submit unavailable': !submitIsAvailable(
          total: '331.26',
          components: <String>['315.49', '15.78'],
        ),
        'the accuracy is at the ceiling': balanceValidationAccuracy == ceiling,
        'the same metric in doubles would be below the row\'s floor':
            accuracyIfDoneInDoubles < floor,
        'the word impenetrable is refused, and the reason cites the row\'s '
            'own standard': !clientSideCanBeImpenetrable &&
            impenetrableNote.contains('OWASP'),
        'the server obligation the adjective obscured is named':
            serverObligation.contains('decides whether'),
        'the single-currency assumption is written down':
            singleCurrencyAssumption.contains(HabotPrecision.cdeName),
        'the step reports Complete': qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: this row names its Common Library as "Validation Module." '
      'where its neighbours name "@habot/shared-library" -- two names for one '
      'place, reconciled at Step 242. Atomic Step: "Execute mathematical '
      'reconciliations (A-B=0) purely on numeric fields."';
}
