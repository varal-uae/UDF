/// AISS GATE -- Step 253 of 255
/// Global Reference ID:       GEN-02117
/// Atomic Steps Reference ID: GEN-02117
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Execute mathematical reconciliations (A-B=0) purely on
///               numeric fields."
/// Expected Output: "Impenetrable client-side submission logic."
/// Completion Measure: "It is mathematically impossible to trigger a submit
///                      request with unbalanced numerical inputs."
/// Metric: Mathematical Balance Validation Accuracy (%) -- Floor 99.5, Optimal
///         99.99, Ceiling 100. Complete/Partial/Not Complete. Standard cited:
///         ISO/IEC 27035 & OWASP.
///
/// THE ADJECTIVE IS REFUSED AND THE BEHAVIOUR IS DELIVERED. "Impenetrable
/// client-side" is a contradiction the row's own cited standard names.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/balance_gate.dart';
import 'package:udf_setup/design_system/forms/numeric_reconciliation.dart';
import 'package:udf_setup/design_system/i18n/fixed_precision.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double accuracy = 0;
  double inDoubles = 0;

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  group('GEN-02117 :: the word that is refused', () {
    gate(
      'GEN-02117-G1',
      'Expected Output: "IMPENETRABLE client-side submission logic."',
      'Refused, and the reason cites the row\'s own standard: OWASP\'s '
          'position is that every client-side check is repeated on the server, '
          'because the client is under the attacker\'s control by definition',
      () =>
          !HabotNumericReconciliation.clientSideCanBeImpenetrable &&
          HabotNumericReconciliation.impenetrableNote.contains('OWASP') &&
          HabotNumericReconciliation.expectedOutputWording
              .contains('Impenetrable'),
    );

    gate(
      'GEN-02117-G2',
      '"The danger is not that somebody believes the sentence."',
      'The obligation the adjective obscured is named: the same reconciliation '
          'runs server-side and its result, not the client\'s, decides whether '
          'the order is accepted -- the same shape as Step 235\'s API latency '
          'SLA',
      () =>
          HabotNumericReconciliation.serverObligation
              .contains('decides whether') &&
          HabotNumericReconciliation.impenetrableNote
              .contains('left out of a sprint'),
    );

    gate(
      'GEN-02117-G3',
      'Atomic Step: "purely on NUMERIC fields."',
      'Every amount on either side of the subtraction is HabotFixed and none '
          'is a double, and quantity -- a count, an input to a subtotal -- is '
          'on neither side, so "numeric" is not read as "every field with '
          'digits in it"',
      () =>
          HabotNumericReconciliation.everyReconciledAmountIsExact &&
          HabotNumericReconciliation.fields.length == 5 &&
          HabotNumericReconciliation.sideA.length == 1 &&
          HabotNumericReconciliation.sideB.length == 3 &&
          HabotNumericReconciliation.notOnEitherSide.single.heldAs == 'int' &&
          HabotNumericReconciliation.numericMeansExactNote
              .contains('is REFUSED'),
    );

    gate(
      'GEN-02117-G4',
      'Every amount in this application is AED, and the currency is in the '
          'CDE\'s name.',
      'The single-currency assumption the whole reconciliation rests on is '
          'written down now rather than discovered by the first multi-currency '
          'order -- two numerically equal amounts in different currencies '
          'balance and are wrong, and the subtraction cannot see it',
      () =>
          HabotNumericReconciliation.singleCurrencyAssumption
              .contains(HabotPrecision.cdeName) &&
          HabotNumericReconciliation.singleCurrencyAssumption
              .contains('cannot see it'),
    );
  });

  group('GEN-02117 :: the completion measure, which does hold', () {
    gate(
      'GEN-02117-G5',
      'Completion Measure: "mathematically impossible to trigger a submit '
          'request with unbalanced numerical inputs."',
      'Submit availability matches Step 252\'s declared corpus case by case, '
          'and an unbalanced order makes submit unavailable -- the control is '
          'derived from the predicate rather than guarded by a call to it, so '
          'there is no branch to forget at a new call site',
      () =>
          HabotNumericReconciliation.submitMatchesTheDeclaredCorpus &&
          !HabotNumericReconciliation.submitIsAvailable(
            total: '331.26',
            components: <String>['315.49', '15.78'],
          ) &&
          HabotNumericReconciliation.submitIsAvailable(
            total: '331.26',
            components: <String>['315.49', '15.77'],
          ) &&
          HabotNumericReconciliation.onePredicateNote
              .contains('no branch to forget'),
    );

    gate(
      'GEN-02117-G6',
      'A test cannot discover that there is only one predicate.',
      'The single-predicate claim is stated as structural and rests on Step '
          '242\'s manifest, where a rule class declared in two files is a '
          'failing check -- what is measured here is the behaviour, and the '
          'reconciliation delegates to Step 252 rather than repeating the '
          'arithmetic',
      () =>
          HabotNumericReconciliation.onePredicateIsStructuralNote
              .contains('cannot discover') &&
          HabotNumericReconciliation.reconciles(
            total: '0.70',
            components: <String>['0.10', '0.20', '0.40'],
          ) &&
          HabotBalanceGate.balances(
            source: '0.70',
            destinations: <String>['0.10', '0.20', '0.40'],
          ),
    );

    gate(
      'GEN-02117-G7',
      'Metric: Mathematical Balance Validation Accuracy (%) -- optimal 99.99.',
      'All twelve checks hold and the accuracy is 100 against the corpus the '
          'predicate actually runs on, while the same metric computed in '
          'doubles would be below the row\'s own floor -- so the step reports '
          'Complete on the behaviour with the adjective refused in writing',
      () {
        accuracy = HabotNumericReconciliation.balanceValidationAccuracy;
        inDoubles = HabotNumericReconciliation.accuracyIfDoneInDoubles;
        return HabotNumericReconciliation.checks.length == 12 &&
            HabotNumericReconciliation.checks.values.every((bool b) => b) &&
            accuracy == HabotNumericReconciliation.ceiling &&
            inDoubles < HabotNumericReconciliation.floor &&
            HabotNumericReconciliation.qualitativeOutput == 'Complete' &&
            HabotNumericReconciliation.columnNote
                .contains('Validation Module.');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02117',
        atomicStepReferenceId: 'GEN-02117',
        setupStepAction:
            'COLUMN NOTE: this row names its Common Library as "Validation '
            'Module." where its neighbours name "@habot/shared-library" -- '
            'two names for one place, reconciled at Step 242. Atomic Step: '
            '"Execute mathematical reconciliations (A-B=0) purely on numeric '
            'fields." Expected Output: "Impenetrable client-side submission '
            'logic."',
        implementationOrder: 253,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotNumericReconciliation / HabotReconciledField',
          'Component Properties':
              '${HabotNumericReconciliation.fields.length} fields, '
              '${HabotNumericReconciliation.sideA.length} on the A side and '
              '${HabotNumericReconciliation.sideB.length} on the B side, all '
              'held as HabotFixed; '
              '${HabotNumericReconciliation.notOnEitherSide.length} field with '
              'digits in it that is on neither side; the submit control '
              'derived from Step 252\'s gate',
          'Completion Status': 'Complete on the behaviour -- see note',
          'Data Quality Note':
              'REFUSED: ${HabotNumericReconciliation.impenetrableNote} '
              'OBLIGATION: ${HabotNumericReconciliation.serverObligation} '
              'SECOND TRAP: '
              '${HabotNumericReconciliation.numericMeansExactNote} '
              'COMPLETION MEASURE: '
              '${HabotNumericReconciliation.onePredicateNote} ASSUMPTION: '
              '${HabotNumericReconciliation.singleCurrencyAssumption}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mathematical Balance Validation Accuracy (%)',
            observed:
                '${accuracy.toStringAsFixed(2)} over the corpus this '
                'predicate actually runs on. The same measurement done '
                '"purely on numeric fields" in the double sense would be '
                '${inDoubles.toStringAsFixed(2)}, below the row\'s own floor '
                'of ${HabotNumericReconciliation.floor}.',
            floor: '99.5',
            optimal: '99.99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Client-side checks that make a server check '
                'unnecessary',
            observed:
                '0. Client-side validation is a usability aid; the request is '
                'an HTTP call and anyone can make it without this '
                'application. The client gate prevents mistakes, the server '
                'gate prevents attacks, and the row\'s own cited standard is '
                'the one that says so.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/numeric_reconciliation.dart',
        ],
      ),
    );
  });
}
