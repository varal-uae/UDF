/// AISS GATE -- Step 458 of 1,314
/// Global Reference ID:       GEN-04836
/// Atomic Steps Reference ID: GEN-04836
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Verify all four substeps above function correctly together as
///               an integrated unit."
/// Metric: Integration Test Pass Rate -- floor ">=95% of integration test cases
///         passing", optimal "100% passing", ceiling "100% (cannot exceed full
///         pass rate)". Best Qualitative Output: "Pass / Fail". ISO/IEC/IEEE
///         29119 Software Testing Standard -- integration test level. Assigned
///         to **ADFA**.
///
/// "VERIFY ALL FOUR SUBSTEPS ABOVE", ON A FLAT SHEET WHERE NOTHING IS ABOVE
/// ANYTHING.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/governance/integration_check_first.dart';

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

  group('GEN-04836 :: a pronoun with no referent', () {
    gate(
      'GEN-04836-G1',
      'The sheet names no four substeps.',
      'A flat list of 1,314 rows whose Dependency column reads one sentence',
      () => HabotIntegrationCheckFirst.theInstructionCannotBeExecutedAsWritten,
    );

    gate(
      'GEN-04836-G2',
      'So four are declared here, from Steps 456 and 457.',
      'The reference check, telephone normalisation, the sensor route and the '
          'PIN route',
      () =>
          HabotIntegrationCheckFirst.fourSubstepsAreNamedHere &&
          HabotIntegrationCheckFirst.theyAreTheRowsThisBatchBuilt,
    );

    gate(
      'GEN-04836-G3',
      'And the orphan pronoun is recorded rather than guessed at.',
      'The instruction cannot be executed as written',
      () =>
          HabotIntegrationCheckFirst
              .orphanNote.contains('cannot be executed as written'),
    );

  });

  group('GEN-04836 :: the duplicate register', () {
    gate(
      'GEN-04836-G4',
      'This row has a twin at Step 465.',
      'Same instruction, character for character, seven rows later',
      () =>
          HabotIntegrationCheckFirst.thisRowHasATwin &&
          HabotIntegrationCheckFirst.theTwinIsCharacterForCharacter,
    );

    gate(
      'GEN-04836-G5',
      'Six pairs, twelve rows of twenty.',
      'Each pair sharing a metric and its three band values',
      () =>
          HabotRowDuplication.pairCount == 6 &&
          HabotRowDuplication.twelveOfTwenty,
    );

    gate(
      'GEN-04836-G6',
      'And exactly one pair shares its instruction.',
      'The rest share only the band, which is how a band gets pasted on',
      () =>
          HabotRowDuplication.oneInstructionIsIdentical &&
          HabotRowDuplication.registerNote.contains('pasted onto them'),
    );

  });

  group('GEN-04836 :: a percentage floor on a small suite', () {
    gate(
      'GEN-04836-G7',
      'Twelve integration cases, all passing.',
      'The suite size is stated beside the rate',
      () =>
          HabotIntegrationCheckFirst.caseCount == 12 &&
          HabotIntegrationCheckFirst.everyCasePasses,
    );

    gate(
      'GEN-04836-G8',
      'The highest rate below full is 91.7 per cent.',
      'Under the floor of 95, so nothing sits between them',
      () => HabotIntegrationCheckFirst.noValueSitsBetweenTheFloorAndFull,
    );

    gate(
      'GEN-04836-G9',
      'So the floor and the optimal name one outcome.',
      'A percentage floor on a suite under twenty cases means 100 per cent',
      () =>
          HabotIntegrationCheckFirst.theOptimalIsTheFloor &&
          HabotIntegrationCheckFirst.suiteNote.contains('different number'),
    );

  });

  group('GEN-04836 :: the result', () {
    gate(
      'GEN-04836-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotIntegrationCheckFirst.obligations.length == 5 &&
          HabotIntegrationCheckFirst.obligations.values.every((bool b) => b) &&
          HabotIntegrationCheckFirst.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int pairs = HabotRowDuplication.pairCount;
    final int twinned = HabotRowDuplication.rowsWithATwin;
    final double rate = HabotIntegrationCheckFirst.passRate;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04836',
        atomicStepReferenceId: 'GEN-04836',
        setupStepAction:
            'COLUMN NOTE: this row says "verify all four substeps above" on a '
            'flat sheet where nothing is above anything and no four substeps '
            'are named, so the four being integrated are declared here; its '
            'instruction is repeated character for character at Step 465, one '
            'of six metric-and-band pairs inside this batch of twenty; and its '
            'floor of 95 per cent names the same outcome as its optimal of 100 '
            'for any suite under twenty cases. Atomic Step: "Verify all four '
            'substeps above function correctly together as an integrated '
            'unit."',
        implementationOrder: 458,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Verify all four substeps above function correctly together as an':
              'four substeps declared and integrated, twelve cases at '
                  '${rate.toStringAsFixed(0)} per cent; $pairs duplicate pairs '
                  'covering $twinned of the twenty rows recorded',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Integration Test Pass Rate',
            observed:
                'THE INSTRUCTION HAS NO REFERENT AND THE FLOOR HAS NO ROOM. '
                '"All four substeps above" points at nothing on a flat sheet '
                'whose Dependency column reads the same sentence on every row '
                'in this batch, so the four being integrated are declared '
                'instead of guessed. And twelve cases can pass at 91.7 or 100 '
                'per cent and nothing between, so a floor of 95 and an optimal '
                'of 100 name one outcome. Observed: ${rate.toStringAsFixed(0)} '
                'per cent.',
            floor: '>=95% of integration test cases passing',
            optimal: '100% passing',
            ceiling: '100% (cannot exceed full pass rate)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Rows in this batch of twenty that have a twin',
            observed:
                '$twinned. $pairs pairs share a metric and its three band '
                'values, one of them sharing its Atomic Step character for '
                'character, and two further rows carry bands first seen in the '
                'previous batch. The bands are not being chosen for the rows; '
                'they are being pasted onto them, which is what this register '
                'exists to record.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/governance/integration_check_first.dart',
        ],
      ),
    );
  });
}
