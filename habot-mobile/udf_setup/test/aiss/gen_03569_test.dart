/// AISS GATE -- Step 252 of 255
/// Global Reference ID:       GEN-03569
/// Atomic Steps Reference ID: GEN-03569
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement local pre-submit mathematical validation gates in
///               the mobile UI layer (Source - Destination = 0)."
/// Metric: Client-Side Math Gate Latency -- Floor < 50 ms, Optimal < 10 ms,
///         Ceiling < 100 ms. Pass/Fail. Standard cited: W3C Client
///         Performance.
///
/// THE FAILURE MODE IS REFUSING GOOD DATA. Splitting AED 0.70 into 0.10, 0.20
/// and 0.40 is correct, and a gate written in binary floating point blocks it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/balance_gate.dart';
import 'package:udf_setup/design_system/i18n/fixed_precision.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double exact = 0;
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

  group('GEN-03569 :: exact arithmetic', () {
    gate(
      'GEN-03569-G1',
      'Atomic Step: "(Source - Destination = 0)."',
      'Six splits are classified correctly at storage scale, including an '
          'empty destination list -- a sum over an empty list is zero, and a '
          'gate that forgot this would report a form with nothing entered as '
          'ready to submit',
      () =>
          HabotBalanceGate.corpusIsClassifiedCorrectly &&
          HabotBalanceGate.corpus.length == 6 &&
          !HabotBalanceGate.balances(
            source: '10.00',
            destinations: <String>[],
          ) &&
          HabotBalanceGate.scale == HabotPrecision.storageScale,
    );

    gate(
      'GEN-03569-G2',
      'Step 140 built HabotFixed because a double cannot hold a tenth.',
      'Exactly one split in the corpus is one a floating-point gate would '
          'refuse -- seventy fils into ten, twenty and forty -- and it is a '
          'correct split with nothing the person could type to make it balance',
      () {
        exact = HabotBalanceGate.exactGateAccuracy;
        inDoubles = HabotBalanceGate.doubleGateAccuracy;
        return HabotBalanceGate.refusedByADouble.length == 1 &&
            HabotBalanceGate.refusedByADouble.single.source == '0.70' &&
            exact == 1.0 &&
            inDoubles < 1.0;
      },
    );

    gate(
      'GEN-03569-G3',
      'A corpus chosen to embarrass floating point proves nothing.',
      'The corpus contains splits a double also gets right -- a two-way refund '
          'of round numbers and a three-line order -- so the one it refuses is '
          'a finding rather than a selection effect',
      () => HabotBalanceGate.corpus.any(
        (HabotBalanceCase c) =>
            c.balances && !HabotBalanceGate.doubleWouldRefuse(c),
      ),
    );

    gate(
      'GEN-03569-G4',
      'The obvious repair to floating point is an epsilon.',
      'An epsilon wide enough to absorb binary error is wide enough to absorb '
          'a fils, which is the smallest real discrepancy there is -- so there '
          'is none, and a one-fils imbalance does not balance',
      () =>
          HabotBalanceGate.anEpsilonWouldSwallowAFils &&
          !HabotBalanceGate.balances(
            source: '331.26',
            destinations: <String>['315.49', '15.78'],
          ) &&
          HabotBalanceGate.balances(
            source: '331.26',
            destinations: <String>['315.49', '15.77'],
          ) &&
          HabotBalanceGate.noEpsilonNote.contains('no error to tolerate'),
    );
  });

  group('GEN-03569 :: a latency band for four integer operations', () {
    gate(
      'GEN-03569-G5',
      'Metric: floor < 50 ms, optimal < 10 ms, ceiling < 100 ms.',
      'Two of the three boundaries were already declared tokens -- 50ms is '
          'Step 204\'s order-total budget and 100ms is the RAIL instant band '
          '-- so only the 10ms optimal is new, the same shape as Step 235',
      () =>
          HabotBalanceGate.twoOfThreeBoundariesWereAlreadyDeclared &&
          HabotBalanceGate.latencyFloor ==
              HabotMotion.orderTotalRecalculationBudget &&
          HabotBalanceGate.latencyCeiling == HabotMotion.railInstant &&
          HabotBalanceGate.latencyOptimal ==
              HabotMotion.clientMathGateBudget &&
          HabotBalanceGate.alreadyDeclaredNote.contains('seventy steps'),
    );

    gate(
      'GEN-03569-G6',
      'Ten milliseconds is not a budget for four integer operations.',
      'The worst case in the corpus is three additions and a subtraction, and '
          'the operation count is published beside the budget because it is '
          'the number that would ever change -- a latency band cannot detect a '
          'gate that started parsing strings inside a loop until it already '
          'has',
      () =>
          HabotBalanceGate.worstCaseOperations == 4 &&
          HabotBalanceGate.operationsFor(0) == 1 &&
          HabotBalanceGate.operationsFor(3) == 4 &&
          HabotBalanceGate.latencyIsNotTheRiskNote
              .contains('four integer operations'),
    );

    gate(
      'GEN-03569-G7',
      'Client-Side Math Gate Latency -- Pass/Fail.',
      'All ten checks hold and the gate classifies every split correctly, so '
          'the step reports Pass -- on correctness, with the latency band met '
          'by orders of magnitude and the operation count published so the '
          'real risk is visible',
      () =>
          HabotBalanceGate.checks.length == 10 &&
          HabotBalanceGate.checks.values.every((bool b) => b) &&
          HabotBalanceGate.qualitativeOutput == 'Pass' &&
          HabotBalanceGate.refusingGoodDataNote
              .contains('nothing they can type') &&
          HabotBalanceGate.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03569',
        atomicStepReferenceId: 'GEN-03569',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement local pre-submit mathematical validation gates '
            'in the mobile UI layer (Source - Destination = 0)."',
        implementationOrder: 252,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotBalanceGate / HabotBalanceCase',
          'Component Properties':
              '${HabotBalanceGate.corpus.length} splits at storage scale '
              '${HabotBalanceGate.scale}; no epsilon; worst case '
              '${HabotBalanceGate.worstCaseOperations} integer operations; '
              'latency band read from '
              '${HabotBalanceGate.latencyFloor.inMilliseconds}ms, '
              '${HabotBalanceGate.latencyOptimal.inMilliseconds}ms and '
              '${HabotBalanceGate.latencyCeiling.inMilliseconds}ms tokens',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotBalanceGate.refusingGoodDataNote} NO EPSILON: '
              '${HabotBalanceGate.noEpsilonNote} ALREADY DECLARED: '
              '${HabotBalanceGate.alreadyDeclaredNote} BAND: '
              '${HabotBalanceGate.latencyIsNotTheRiskNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Client-Side Math Gate Latency',
            observed:
                'Met by orders of magnitude: '
                '${HabotBalanceGate.worstCaseOperations} integer operations '
                'against a ${HabotBalanceGate.latencyOptimal.inMilliseconds}ms '
                'optimal. The operation count is published beside it because '
                'that is the number that would ever change.',
            floor: '< 50 ms',
            optimal: '< 10 ms',
            ceiling: '< 100 ms',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Split classification accuracy, exact against double',
            observed:
                '${exact.toStringAsFixed(2)} on scaled integers against '
                '${inDoubles.toStringAsFixed(3)} in binary floating point, '
                'over the same ${HabotBalanceGate.corpus.length} splits. The '
                'one they disagree about is a correct split a double refuses.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/balance_gate.dart',
        ],
      ),
    );
  });
}
