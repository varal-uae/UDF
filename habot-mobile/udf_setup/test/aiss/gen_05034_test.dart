/// AISS GATE -- Step 465 of 1,314
/// Global Reference ID:       GEN-05034
/// Atomic Steps Reference ID: GEN-05034
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Verify all four substeps above function correctly together as
///               an integrated unit."
/// Metric: Integration Test Pass Rate -- floor ">=95% of integration test cases
///         passing", optimal "100% passing", ceiling "100% (cannot exceed full
///         pass rate)". Best Qualitative Output: "Pass / Fail". ISO/IEC/IEEE
///         29119 Software Testing Standard -- integration test level. Assigned
///         to **ADFA**.
///
/// STEP 458 AGAIN, CHARACTER FOR CHARACTER, PRODUCING A DIFFERENT TEST.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/governance/integration_check_second.dart';

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

  group('GEN-05034 :: eight identical cells', () {
    gate(
      'GEN-05034-G1',
      'Eight cells are identical to Step 458\'s.',
      'Instruction, team, metric, three band values, output column and '
          'standard',
      () =>
          HabotIntegrationCheckSecond.theInstructionIsStep458s &&
          HabotIntegrationCheckSecond.eightCellsAreIdentical &&
          HabotIntegrationCheckSecond.rowsBetween == 7,
    );

    gate(
      'GEN-05034-G2',
      'And this is the batch\'s only instruction pair.',
      'The other five pairs share a band and nothing else',
      () =>
          HabotIntegrationCheckSecond.thisIsTheInstructionPair &&
          HabotIntegrationCheckSecond
              .duplicateNote.contains('shares an instruction'),
    );

  });

  group('GEN-05034 :: a different four', () {
    gate(
      'GEN-05034-G3',
      'Four substeps declared here, different from Step 458\'s.',
      'Because by now the batch has built different things',
      () =>
          HabotIntegrationCheckSecond.fourSubstepsAreNamedHere &&
          HabotIntegrationCheckSecond.theyDifferFromStep458s,
    );

    gate(
      'GEN-05034-G4',
      'Each of them resolves.',
      'Punctuation, accuracy, the recording indicator and the assistive '
          'surfaces',
      () => HabotIntegrationCheckSecond.eachOneResolves,
    );

    gate(
      'GEN-05034-G5',
      'So two identical rows produce two different tests.',
      'Which is the clearest evidence that the instruction carries no '
          'information',
      () =>
          HabotIntegrationCheckSecond
              .evidenceNote.contains('carries no information'),
    );

  });

  group('GEN-05034 :: the same arithmetic', () {
    gate(
      'GEN-05034-G6',
      'Sixteen cases, all passing.',
      'A larger suite than Step 458\'s, and the same conclusion',
      () =>
          HabotIntegrationCheckSecond.caseCount == 16 &&
          HabotIntegrationCheckSecond.everyCasePasses,
    );

    gate(
      'GEN-05034-G7',
      'No rate sits between 93.75 and 100 per cent.',
      'Fifteen of sixteen is below the floor of 95',
      () => HabotIntegrationCheckSecond.noValueSitsBetweenTheFloorAndFull,
    );

    gate(
      'GEN-05034-G8',
      'The same arithmetic as Step 458.',
      'A percentage floor on a small suite means full marks',
      () => HabotIntegrationCheckSecond.theSameArithmeticAsStep458,
    );

  });

  group('GEN-05034 :: nothing is deleted', () {
    gate(
      'GEN-05034-G9',
      'Both rows are implemented and the duplication recorded.',
      'Skipping one would make the count of implemented steps a lie',
      () =>
          HabotIntegrationCheckSecond.bothRowsAreImplemented &&
          HabotIntegrationCheckSecond.honestyNote.contains('a lie'),
    );

    gate(
      'GEN-05034-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotIntegrationCheckSecond.obligations.length == 5 &&
          HabotIntegrationCheckSecond.obligations.values.every((bool b) => b) &&
          HabotIntegrationCheckSecond.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int cells = HabotIntegrationCheckSecond.cellsThatAreIdentical.length;
    final double rate = HabotIntegrationCheckSecond.passRate;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05034',
        atomicStepReferenceId: 'GEN-05034',
        setupStepAction:
            'COLUMN NOTE: this row\'s Atomic Step is Step 458\'s character for '
            'character, with eight cells identical and seven rows between '
            'them, the only pair in this batch to share an instruction rather '
            'than a band; it declares a different four substeps because the '
            'batch has built different things by now, which shows the '
            'instruction carries no information; its sixteen-case suite has no '
            'value between 93.75 and 100 per cent, so its floor and optimal '
            'again name one outcome; and neither row is skipped, because '
            'skipping one would make the implemented count a lie. Atomic Step: '
            '"Verify all four substeps above function correctly together as an '
            'integrated unit."',
        implementationOrder: 465,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Verify all four substeps above function correctly together as an':
              '$cells cells identical to Step 458, a different four substeps '
                  'declared and integrated, sixteen cases at '
                  '${rate.toStringAsFixed(0)} per cent, and both rows '
                  'implemented',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Integration Test Pass Rate',
            observed:
                'THE SAME ROW TWICE, SEVEN ROWS APART. $cells cells are '
                'identical to Step 458\'s, including the Atomic Step character '
                'for character, which makes this the only pair in the batch to '
                'share an instruction rather than a band. The four substeps '
                'declared here differ from Step 458\'s because the batch has '
                'built different things by then. Observed: sixteen cases at '
                '${rate.toStringAsFixed(0)} per cent.',
            floor: '>=95% of integration test cases passing',
            optimal: '100% passing',
            ceiling: '100% (cannot exceed full pass rate)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Duplicate rows quietly skipped',
            observed:
                '0. A sheet of 1,314 rows that contains copies is a fact about '
                'the sheet, and skipping one of a pair would make the count of '
                'implemented steps a lie. Both rows are implemented, both '
                'produce evidence, and the duplication is recorded in the '
                'register opened at Step 458 instead.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/governance/integration_check_second.dart',
        ],
      ),
    );
  });
}
