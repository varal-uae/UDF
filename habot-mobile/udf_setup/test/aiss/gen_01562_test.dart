/// AISS GATE -- Step 213 of 215
/// Global Reference ID:       GEN-01562
/// Atomic Steps Reference ID: GEN-01562
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Program a mandatory reason-code drop-down gate that requires
///               input before an order rejection can be submitted."
/// Metric: Fraud Detection False-Positive Rate -- Floor <5%, Optimal <1%,
///         Ceiling <10%. Good/Average/Poor.
///
/// A DROP-DOWN WITH A SELECTED FIRST ITEM IS NOT MANDATORY. The control shows
/// a value, the validation sees a value, and the reviewer never touched it --
/// after which whichever code sorts first is most of the rejection data.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/reason_code_gate.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adherence = 0;

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

  HabotReasonSelection pick(String code, {String detail = ''}) =>
      HabotReasonSelection(
        code: HabotReasonCodeGate.resolve(code),
        detail: detail,
      );

  group('GEN-01562 :: mandatory means nothing is chosen for you', () {
    gate(
      'GEN-01562-G1',
      'Atomic Step: "a MANDATORY reason-code drop-down gate that REQUIRES '
          'input before an order rejection can be submitted."',
      'The selection starts as null, null is not a code, and submission is '
          'blocked with a reason a reviewer can act on rather than a silent '
          'refusal',
      () =>
          HabotReasonCodeGate.initialSelectionIsEmpty &&
          !HabotReasonCodeGate.maySubmit(
            HabotReasonCodeGate.initialSelection,
          ) &&
          HabotReasonCodeGate.blockReason(
            HabotReasonCodeGate.initialSelection,
          ).contains('Choose a reason') &&
          HabotReasonCodeGate.blocksSubmission &&
          HabotReasonCodeGate.preselectedIsNotMandatoryNote
              .contains('never touched it'),
    );

    gate(
      'GEN-01562-G2',
      '"Whichever code sorts first becomes the majority of the rejection '
          'data."',
      'The code a pre-selected drop-down would submit is named, so the defect '
          'is a specific value that would have polluted a specific series '
          'rather than a general worry',
      () =>
          HabotReasonCodeGate.codeANaiveDropDownWouldSubmit.code ==
              'PAY_AVS_MISMATCH' &&
          HabotReasonCodeGate.offered().first.code == 'PAY_AVS_MISMATCH' &&
          !HabotReasonCodeGate.initialSelection.hasCode,
    );

    gate(
      'GEN-01562-G3',
      '"A catch-all that is the fast path out of the gate is the gate not '
          'existing."',
      'Selecting Other demands typed detail: twelve characters or more, so a '
          'single character does not pass, and the requirement is stated in '
          'the block reason rather than discovered',
      () {
        final HabotReasonSelection thin = pick('OTHER', detail: 'x');
        final HabotReasonSelection real =
            pick('OTHER', detail: 'Duplicate of order 4471');
        return HabotReasonCodeGate.resolve('OTHER')!.requiresFreeText &&
            !HabotReasonCodeGate.maySubmit(thin) &&
            HabotReasonCodeGate.blockReason(thin).contains('12 characters') &&
            HabotReasonCodeGate.maySubmit(real) &&
            HabotReasonCodeGate.blockReason(real).isEmpty &&
            HabotReasonCodeGate.minimumDetailLength == 12;
      },
    );

    gate(
      'GEN-01562-G4',
      'A code that needs no elaboration should not demand any.',
      'A specific code submits on its own, so the free-text requirement is '
          'attached to the codes that need it rather than to the whole gate',
      () {
        final HabotReasonSelection specific = pick('PAY_ISSUER_DECLINE');
        return HabotReasonCodeGate.maySubmit(specific) &&
            !HabotReasonCodeGate.resolve('PAY_ISSUER_DECLINE')!
                .requiresFreeText &&
            HabotReasonCodeGate.resolve('ORD_DETAILS_INCONSISTENT')!
                .requiresFreeText;
      },
    );
  });

  group('GEN-01562 :: the code list is a measurement instrument', () {
    gate(
      'GEN-01562-G5',
      '"A false-positive rate is computed by grouping rejections by reason."',
      'Codes are unique, every family has at least one, and a rejection set '
          'groups into families -- which is the form the metric is actually '
          'computed in',
      () {
        final Map<HabotReasonFamily, int> grouped =
            HabotReasonCodeGate.byFamily(<String, int>{
          'PAY_AVS_MISMATCH': 12,
          'PAY_ISSUER_DECLINE': 8,
          'ACC_PRIOR_CHARGEBACK': 15,
          'ACC_VELOCITY': 4,
          'OPS_CAPACITY': 6,
          'OTHER': 5,
          'NOT_A_CODE': 99,
        });
        return HabotReasonCodeGate.codesAreUnique &&
            HabotReasonCodeGate.everyFamilyHasACode &&
            grouped[HabotReasonFamily.payment] == 20 &&
            grouped[HabotReasonFamily.account] == 19 &&
            grouped[HabotReasonFamily.operational] == 6 &&
            grouped[HabotReasonFamily.other] == 5 &&
            grouped[HabotReasonFamily.order] == 0 &&
            grouped.values.fold(0, (int a, int b) => a + b) == 50;
      },
    );

    gate(
      'GEN-01562-G6',
      '"A code added mid-quarter splits a series and nothing in the data says '
          'so."',
      'The list is versioned: a retired code can no longer be chosen but still '
          'resolves, so a rejection filed under it renders as what it was '
          'rather than as a blank',
      () =>
          HabotReasonCodeGate.listVersion == 3 &&
          HabotReasonCodeGate.retiredCodesStillResolve &&
          !HabotReasonCodeGate.maySubmit(pick('ACC_VELOCITY')) &&
          HabotReasonCodeGate.offered()
              .every((HabotReasonCode c) => c.code != 'ACC_VELOCITY') &&
          HabotReasonCodeGate.offered(version: 2)
              .any((HabotReasonCode c) => c.code == 'ACC_VELOCITY') &&
          HabotReasonCodeGate.offered(version: 1).length == 6 &&
          HabotReasonCodeGate.codesAreTheInstrumentNote
              .contains('measurement instrument'),
    );

    gate(
      'GEN-01562-G7',
      'Metric: Fraud Detection False-Positive Rate -- lower is better. "A '
          'catch-all absorbing a third of rejections makes every other group '
          'under-counted by an unknown amount."',
      'The Other share is watched against a declared ceiling -- 40% fails and '
          '5% passes -- and all nine gate checks hold at 1.0, while the rate '
          'itself is left to data the app never sees',
      () {
        adherence = HabotReasonCodeGate.adherence;
        return HabotReasonCodeGate.otherShareCeiling == 0.15 &&
            HabotReasonCodeGate.otherShare(
                  <String, int>{'OTHER': 40, 'OPS_CAPACITY': 60},
                ) ==
                0.4 &&
            !HabotReasonCodeGate.catchAllIsHealthy(
              <String, int>{'OTHER': 40, 'OPS_CAPACITY': 60},
            ) &&
            HabotReasonCodeGate.catchAllIsHealthy(
              <String, int>{'OTHER': 5, 'OPS_CAPACITY': 95},
            ) &&
            HabotReasonCodeGate.lowerIsBetter &&
            HabotReasonCodeGate.qualitativeOutput(0.004) == 'Good' &&
            HabotReasonCodeGate.checks.length == 9 &&
            HabotReasonCodeGate.checks.values.every((bool b) => b) &&
            adherence == 1.0 &&
            HabotReasonCodeGate.catchAllNote.contains('confident and wrong') &&
            HabotReasonCodeGate.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01562',
        atomicStepReferenceId: 'GEN-01562',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Program a mandatory reason-code drop-down gate that '
            'requires input before an order rejection can be submitted."',
        implementationOrder: 213,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotReasonCodeGate / HabotReasonCode',
          'Component Properties':
              '${HabotReasonCodeGate.codes.length} codes at list version '
              '${HabotReasonCodeGate.listVersion}, '
              '${HabotReasonCodeGate.offered().length} currently offered and '
              'one retired but still resolving; '
              '${HabotReasonFamily.values.length} families for grouping; null '
              'initial selection; free text required behind the catch-all at '
              '${HabotReasonCodeGate.minimumDetailLength} characters; Other '
              'share watched against a '
              '${HabotReasonCodeGate.otherShareCeiling} ceiling',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: a drop-down with a selected first item is not '
              'mandatory, and it is the commonest way this requirement gets '
              'implemented and silently fails. The control shows a value, the '
              'validation sees a value, and the reviewer never touched it -- '
              'after which every rejection carries whichever code sorts first '
              'and that code becomes the majority of the rejection data. Named '
              'here: a pre-selected drop-down would submit PAY_AVS_MISMATCH. '
              'The selection starts as null and null is not a code. SECOND '
              'FINDING: the codes are what the metric is MADE OF. A '
              'false-positive rate is computed by grouping rejections by '
              'reason and finding which reasons turned out to be wrong, which '
              'makes this list a measurement instrument -- closed, versioned, '
              'never renamed or reused, retired rather than deleted so old '
              'rejections still resolve. THIRD: a catch-all absorbing a third '
              'of the volume makes every other group under-counted by an '
              'unknown amount and the rate computed from them confident and '
              'wrong. The Other share is watched against a declared ceiling '
              'and the catch-all demands typed detail so it is not the fast '
              'path out of the gate.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Fraud Detection False-Positive Rate '
                '(gate contribution)',
            observed:
                'The rate is not computable in the app -- see Step 212. What '
                'is measured is the instrument it would be computed from: '
                '${adherence.toStringAsFixed(2)} over '
                '${HabotReasonCodeGate.checks.length} checks, including a null '
                'initial selection, a blocked submission, a catch-all that '
                'demands detail, and a retired code that cannot be chosen but '
                'still resolves.',
            floor: '<5%',
            optimal: '<1%',
            ceiling: '<10%',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Catch-all share of rejections',
            observed:
                'Ceiling ${HabotReasonCodeGate.otherShareCeiling}. Exercised '
                'at 0.40, which fails, and 0.05, which passes. Above the '
                'ceiling every other reason group is under-counted by an '
                'unknown amount, so the number computed from them is confident '
                'and wrong.',
            floor: '0.15',
            optimal: '0.05',
            ceiling: '0.15',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/reason_code_gate.dart',
        ],
      ),
    );
  });
}
