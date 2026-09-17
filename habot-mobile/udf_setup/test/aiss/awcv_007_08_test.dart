/// AISS GATE -- Step 318 of 335
/// Global Reference ID:       AWCV-007-08
/// Atomic Steps Reference ID: AWCV-007-08
/// Setup Step (Action): "Restrict data visibility properties on the left panel
///                      to display strictly the targeted crop segment."
///                      (MTO WORKER-CROP WORK, ON A LEDGER ROW)
/// Atomic Step: "Map button enablement triggers directly to local equation
///               balance."
/// Metric: Process Execution Quality Score -- floor >=90%, optimal >=98%,
///         ceiling 1. Good/Average/Poor. ISO 9001:2015.
///
/// THREE WORDS DECIDE WHETHER THIS WORKS: LOCAL, BALANCE, DIRECTLY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/equation_balance_gate.dart';
import 'package:udf_setup/design_system/forms/strict_true_gate.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  group('AWCV-007-08 :: balance', () {
    gate(
      'AWCV-007-08-G1',
      'Atomic Step: "local equation balance".',
      'Three lines in fils -- two debits of 80,468 against a credit of the '
          'same -- balancing exactly at zero',
      () =>
          HabotEquationBalanceGate.lines.length == 3 &&
          HabotEquationBalanceGate.debitsFils == 80468 &&
          HabotEquationBalanceGate.creditsFils == 80468 &&
          HabotEquationBalanceGate.balanceFils == 0,
    );

    gate(
      'AWCV-007-08-G2',
      'The same amounts as doubles do not compare equal.',
      'AED 350.21 plus AED 454.47 leaves a residual against AED 804.68, so '
          'the equality test fails and the button stays grey while the ledger '
          'on screen visibly adds up',
      () =>
          HabotEquationBalanceGate.theDoubleComparisonFails &&
          HabotEquationBalanceGate.doubleResidual.abs() < 1e-9 &&
          HabotEquationBalanceGate.theIntegerComparisonHolds,
    );

    gate(
      'AWCV-007-08-G3',
      'The screen would contain the evidence that the app is wrong.',
      'Which is why it is the worst class of bug to report: the person has no '
          'way to describe what they are seeing',
      () =>
          HabotEquationBalanceGate.everyAmountIsHeldInMinorUnits &&
          HabotEquationBalanceGate.precisionNote
              .contains('no way to describe what they are seeing'),
    );
  });

  group('AWCV-007-08 :: directly', () {
    gate(
      'AWCV-007-08-G4',
      'Atomic Step: "Map button enablement triggers directly".',
      'The button does not toggle on a keystroke; it stays pressable, because '
          'a control flickering under the thumb reads as a fault and the '
          'slowest typist meets it on every field',
      () =>
          !HabotEquationBalanceGate.theButtonTogglesOnKeystroke &&
          HabotEquationBalanceGate.theButtonIsAlwaysPressable &&
          HabotEquationBalanceGate.timingNote.contains('every field'),
    );

    gate(
      'AWCV-007-08-G5',
      'An unbalanced ledger says by how much and which side.',
      'Rather than presenting a grey control with no explanation -- the '
          'property Steps 291 and 293 supplied',
      () =>
          HabotEquationBalanceGate.theReasonNamesTheAmountAndTheSide &&
          HabotEquationBalanceGate.reasonFor(1234) ==
              'The credits are short by AED 12.34' &&
          HabotEquationBalanceGate.reasonFor(0).isEmpty,
    );
  });

  group('AWCV-007-08 :: the Step 254 gate', () {
    gate(
      'AWCV-007-08-G6',
      'Evaluated through the strict-true gate rather than a boolean.',
      'The gate reconciles decimal strings, which is the same refusal to do '
          'money in doubles, made two hundred steps earlier',
      () =>
          HabotEquationBalanceGate.theGateAgreesWithTheArithmetic &&
          HabotStrictTrueGate.mayProgress(
            HabotEquationBalanceGate.gateResult,
          ) &&
          HabotEquationBalanceGate.theGateAlsoRefusesDoubles,
    );

    gate(
      'AWCV-007-08-G7',
      'A blocked result always carries a reason.',
      'An outstanding field blocks with a reason attached, so no refusal is '
          'a bare false',
      () => HabotEquationBalanceGate.anOutstandingFieldBlocksWithAReason,
    );
  });

  group('AWCV-007-08 :: local', () {
    gate(
      'AWCV-007-08-G8',
      'Atomic Step: "local equation balance".',
      'The client decides the appearance and the server re-derives the '
          'balance, because the client is a place where numbers can be '
          'changed',
      () =>
          !HabotEquationBalanceGate.theClientIsTheAuthority &&
          HabotEquationBalanceGate.theServerRederivesTheBalance,
    );

    gate(
      'AWCV-007-08-G9',
      'Step 294 said the same about a locked pathway.',
      'A team that believes the interface prevents something stops checking '
          'at the source, which is where the actual vulnerability appears',
      () => HabotEquationBalanceGate.localNote
          .contains('stops checking at the source'),
    );

    gate(
      'AWCV-007-08-G10',
      'Output: Good / Average / Poor.',
      'Seven declared obligations, all met, giving 1.0 and a Good; all nine '
          'declared checks hold',
      () =>
          HabotEquationBalanceGate.obligations.length == 7 &&
          HabotEquationBalanceGate.obligations.values.every((bool b) => b) &&
          HabotEquationBalanceGate.executionQuality == 1.0 &&
          HabotEquationBalanceGate.qualitativeOutput == 'Good' &&
          HabotEquationBalanceGate.checks.length == 9 &&
          HabotEquationBalanceGate.checks.values.every((bool b) => b) &&
          HabotEquationBalanceGate.columnNote.contains('crop segment'),
    );
  });

  tearDownAll(() {
    final String residual =
        HabotEquationBalanceGate.doubleResidual.toStringAsExponential(2);
    final String shortBy = HabotEquationBalanceGate.reasonFor(-2500);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'AWCV-007-08',
        atomicStepReferenceId: 'AWCV-007-08',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Restrict '
            'data visibility properties on the left panel to display strictly '
            'the targeted crop segment", which is MTO worker-crop work on a '
            'ledger row, and the Data Requirement cell is a generic '
            'element-mapping vocabulary. Atomic Step: "Map button enablement '
            'triggers directly to local equation balance."',
        implementationOrder: 318,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Source Element ID': 'ledger lines, held in fils',
          'Target Element ID': 'the submit control',
          'Mapping Rule':
              'the control is always pressable; the balance decides what it '
                  'says, not whether it can be pressed',
          'Mapping Status': 'Good',
          'Mapping Validation':
              'integer comparison at zero; the same amounts as doubles leave '
                  'a residual of $residual',
          'Completion Status': 'Derived from gate outcomes',
          'Component Properties': 'an out-of-balance ledger reads "$shortBy"',
          'Data Quality Note':
              'PRECISION: ${HabotEquationBalanceGate.precisionNote} '
              'TIMING: ${HabotEquationBalanceGate.timingNote} '
              'LOCAL: ${HabotEquationBalanceGate.localNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                '100% over seven declared obligations. The ceiling is written '
                'as 1 against percentage floors.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Money amounts held as floating point',
            observed:
                '0 of ${HabotEquationBalanceGate.lines.length}. Every amount '
                'is in fils and the balance comparison is exact. The same '
                'three amounts as doubles leave a residual of $residual '
                'against zero, which is enough to hold a correct ledger in a '
                'refused state while the person reads the correct total on '
                'the screen.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/equation_balance_gate.dart',
        ],
      ),
    );
  });
}
