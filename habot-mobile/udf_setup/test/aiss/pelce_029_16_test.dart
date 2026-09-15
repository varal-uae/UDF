/// AISS GATE -- Step 291 of 295
/// Global Reference ID:       PELCE-029-16
/// Atomic Steps Reference ID: PELCE-029-16
/// Setup Step (Action): "Embed hardware-accelerated CSS properties (transform,
///                      opacity) as the preferred animation approach." (CSS,
///                      IN A DART APPLICATION)
/// Atomic Step: "Programmatically link the button's enabled/disabled state to
///               the output of the 'Design Reconciliation Test' equation."
/// Metric: QA Test Case Pass Rate -- Floor ">=95%", Optimal 1, Ceiling 1.
///         Pass / Fail -> Best = Pass (100%).
///
/// THIS ROW ALREADY CONTAINS THE ANTIDOTE TO THE NEXT ROW'S DEAD END, AND
/// NEITHER REFERENCES THE OTHER.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/strict_true_gate.dart';
import 'package:udf_setup/design_system/operations/reconciliation_gate.dart';

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

  group('PELCE-029-16 :: the gate, reused', () {
    gate(
      'PELCE-029-16-G1',
      'Atomic Step: link the button state to the equation\'s output.',
      'A clean result enables the button and either problem disables it, '
          'using the Step 254 gate rather than a second one written here',
      () =>
          HabotReconciliationGate.theCleanCaseEnablesTheButton &&
          HabotReconciliationGate.eitherProblemDisablesIt,
    );

    gate(
      'PELCE-029-16-G2',
      'A boolean says no and nothing else.',
      'Every disabled state carries at least one reason, and an enabled one '
          'carries none -- which is the only time it may',
      () => HabotReconciliationGate.everyDisabledStateCanSayWhy,
    );

    gate(
      'PELCE-029-16-G3',
      'Row design note: "tap the widget to see which logic chunk is '
          'missing".',
      'The tap lands on the first field-level reason, and a form-level '
          'problem has no field to land on and says so rather than guessing',
      () =>
          HabotReconciliationGate.theTapLandsOnAField &&
          HabotReconciliationGate.aFormLevelProblemHasNoField,
    );

    gate(
      'PELCE-029-16-G4',
      'The score and the enabled state have to agree.',
      'The score is zero exactly when the button is enabled, checked across '
          'all three results rather than on the one that was thought about',
      () => HabotReconciliationGate.theScoreIsZeroExactlyWhenEnabled,
    );

    gate(
      'PELCE-029-16-G5',
      'This row contains the fix for Step 292.',
      'A tappable explanation is exactly what a disabled control needs and '
          'exactly what "permanently disable" omits; the adjacency is '
          'recorded because a reader implementing 292 alone builds the dead '
          'end',
      () => HabotReconciliationGate.theRowContainsTheAntidoteNote
          .contains('build the dead end'),
    );
  });

  group('PELCE-029-16 :: colour, and the metric', () {
    gate(
      'PELCE-029-16-G6',
      'Row design note: "Green for 0, Red for >0".',
      'Colour alone, which SC 1.4.1 refuses and this repository has enforced '
          'since Step 217; the score carries a word and a shape as well as a '
          'hue',
      () =>
          HabotReconciliationGate.meaningSurvivesWithoutColour &&
          HabotReconciliationGate.colourAloneNote.contains('only channel'),
    );

    gate(
      'PELCE-029-16-G7',
      'And no hex literal appears.',
      'The two presentations name colour roles rather than values, so the '
          'guard rule that has stood since Step 97 is satisfied by '
          'construction',
      () => HabotReconciliationGate.noHexAppearsHere,
    );

    gate(
      'PELCE-029-16-G8',
      'Metric: QA Test Case Pass Rate -- 95% / 1 / 1.',
      'Six exercised cases, all passing, giving 1.0 and a Pass; the metric is '
          'read over the cases this step actually exercises rather than over '
          'a test suite',
      () =>
          HabotReconciliationGate.cases.length == 6 &&
          HabotReconciliationGate.cases.values.every((bool b) => b) &&
          HabotReconciliationGate.passRate == 1.0 &&
          HabotReconciliationGate.qualitativeOutput == 'Pass' &&
          HabotReconciliationGate.metricNote
              .contains('a real number about a real thing') &&
          HabotReconciliationGate.checks.length == 9 &&
          HabotReconciliationGate.checks.values.every((bool b) => b) &&
          HabotReconciliationGate.columnNote.contains('CSS again'),
    );
  });

  tearDownAll(() {
    final HabotGateResult blocked = HabotReconciliationGate.outstanding;
    final String cleanScore =
        '${HabotReconciliationGate.scoreFor(HabotReconciliationGate.clean)}';
    final String blockedScore =
        '${HabotReconciliationGate.scoreFor(blocked)}';
    final String target =
        '${HabotReconciliationGate.tapTargetFor(blocked)}';
    final String adjacency =
        HabotReconciliationGate.theRowContainsTheAntidoteNote;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'PELCE-029-16',
        atomicStepReferenceId: 'PELCE-029-16',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Embed '
            'hardware-accelerated CSS properties (transform, opacity) as the '
            'preferred animation approach" -- CSS, in a Dart application. '
            'Atomic Step: "Programmatically link the button\'s '
            'enabled/disabled state to the output of the \'Design '
            'Reconciliation Test\' equation."',
        implementationOrder: 291,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Test Type': 'gate binding across three declared results',
          'Test Result':
              'clean score $cleanScore and enabled; outstanding score '
                  '$blockedScore and disabled, with the tap landing on '
                  '"$target"',
          'Test Coverage':
              '${HabotReconciliationGate.cases.length} exercised cases '
                  'including the form-level one that has no field to focus',
          'Component Properties':
              'the Step 254 sealed gate reused rather than duplicated; score '
                  'derived as the count of open reasons; presentation carries '
                  'a word and a shape as well as a colour role',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'ADJACENCY: $adjacency '
              'COLOUR: ${HabotReconciliationGate.colourAloneNote} '
              'METRIC: ${HabotReconciliationGate.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'QA Test Case Pass Rate',
            observed:
                '1.0 over ${HabotReconciliationGate.cases.length} cases: the '
                'clean result, both problem results, the score agreement '
                'between them, the form-level case, and the '
                'colour-independent reading of the score.',
            floor: '>=95%',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Disabled states that cannot say why',
            observed:
                '0. The result is a sealed type carrying reasons rather than '
                'a boolean, so a blocked outcome with no explanation does not '
                'compile into existence.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/reconciliation_gate.dart',
        ],
      ),
    );
  });
}
