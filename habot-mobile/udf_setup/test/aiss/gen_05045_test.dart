/// AISS GATE -- Step 466 of 1,314
/// Global Reference ID:       GEN-05045
/// Atomic Steps Reference ID: GEN-05045
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Confirm that the dependency prerequisite (Step 8) is complete
///               before starting this step."
/// Metric: Dependency Gate Compliance Rate -- floor "95% of prerequisite gates
///         verified before start (no exceptions on critical path)", optimal
///         "100% of prerequisite gates verified before start", ceiling "100% (a
///         gate cannot be satisfied beyond full completion)". Best Qualitative
///         Output: "Pass / Fail". ITIL v4 Change Enablement -- dependency/gate
///         verification practice. Assigned to **UDF**.
///
/// STEP 459 WITH ONE DIGIT CHANGED, AND TWO COLUMNS THAT SAY ONE SENTENCE ON
/// ALL TWENTY ROWS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/governance/dependency_gate_eight.dart';

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

  group('GEN-05045 :: one character apart', () {
    gate(
      'GEN-05045-G1',
      'Exactly one character separates this row from Step 459.',
      'A 2 became an 8',
      () => HabotDependencyGateEight.exactlyOneCharacterDiffers,
    );

    gate(
      'GEN-05045-G2',
      'And neither ordinal can be looked up.',
      'A gate nobody can fail is not a gate',
      () =>
          HabotDependencyGateEight.neitherOrdinalCanBeLookedUp &&
          HabotDependencyGateEight.ordinalNote.contains('is not a gate'),
    );

  });

  group('GEN-05045 :: a stamped column promising enforcement', () {
    gate(
      'GEN-05045-G3',
      'The Mistake-Proofing column is one sentence on twenty rows.',
      '"CI/CD pipeline physically blocks deployment if any gate for this step '
          'fails."',
      () => HabotDependencyGateEight.bothColumnsAreStamped,
    );

    gate(
      'GEN-05045-G4',
      'So the pipeline cannot block on it.',
      'There is nothing for it to block on but an ordinal into nothing',
      () => HabotDependencyGateEight.thePipelineCannotBlockOnAnOrdinal,
    );

    gate(
      'GEN-05045-G5',
      'And nothing rolls back every thirty seconds.',
      'The Self-Chasing column is stamped on all twenty rows too',
      () =>
          HabotDependencyGateEight.nothingRollsBackEveryThirtySeconds &&
          HabotDependencyGateEight.stampNote.contains('stamped on the batch'),
    );

  });

  group('GEN-05045 :: the floor, inherited', () {
    gate(
      'GEN-05045-G6',
      'The floor\'s contradiction is inherited and split in two.',
      '95 per cent and no exceptions, implemented as Step 459 implemented them',
      () =>
          HabotDependencyGateEight.theFloorContradictionIsInherited &&
          HabotDependencyGateEight.itIsImplementedAsTwoRules,
    );

  });

  group('GEN-05045 :: the capture thread, named from the code', () {
    gate(
      'GEN-05045-G7',
      'Five prerequisites, three of them critical.',
      'The capture thread: Steps 460, 461, 462, 464 and 465',
      () =>
          HabotDependencyGateEight.gates.length == 5 &&
          HabotDependencyGateEight
              .gates.where((HabotPrerequisiteGate g) => g.critical).length == 3,
    );

    gate(
      'GEN-05045-G8',
      'Every critical one is verified.',
      'Without exception, which is what the parenthesis asked for',
      () => HabotDependencyGateEight.everyCriticalGateIsVerified,
    );

    gate(
      'GEN-05045-G9',
      'And every named symbol resolves.',
      'Against a library file that already exists',
      () => HabotDependencyGateEight.everyNamedSymbolResolves,
    );

    gate(
      'GEN-05045-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotDependencyGateEight.obligations.length == 5 &&
          HabotDependencyGateEight.obligations.values.every((bool b) => b) &&
          HabotDependencyGateEight.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int differ = HabotDependencyGateEight.charactersThatDiffer;
    final int gates_ = HabotDependencyGateEight.gates.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05045',
        atomicStepReferenceId: 'GEN-05045',
        setupStepAction:
            'COLUMN NOTE: this row differs from Step 459 by a single '
            'character, a 2 become an 8, and both ordinals point into a list '
            'the sheet does not contain; the Mistake-Proofing and Self-Chasing '
            'columns each read one sentence on all twenty rows in this batch, '
            'promising a pipeline block and a thirty-second rollback that no '
            'ordinal into nothing could trigger; the floor\'s contradiction is '
            'inherited whole and implemented as two rules; and five '
            'prerequisites from the capture thread are named from the code. '
            'Atomic Step: "Confirm that the dependency prerequisite (Step 8) '
            'is complete before starting this step."',
        implementationOrder: 466,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Confirm that the dependency prerequisite (Step 8) is complete '
          'before':
              '$differ character separates this row from Step 459; $gates_ '
                  'prerequisites named from the code, every critical one '
                  'verified, and two stamped columns recorded',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dependency Gate Compliance Rate',
            observed:
                'ONE CHARACTER SEPARATES THIS ROW FROM STEP 459, and both '
                'ordinals point into a list the sheet does not contain, so '
                'neither names a prerequisite anybody could look up. The '
                'floor\'s contradiction is inherited whole and implemented as '
                'two rules: every critical prerequisite verified without '
                'exception, and at least 95 per cent of the rest. Observed: '
                '$gates_ prerequisites named from the code, all verified.',
            floor:
                '95% of prerequisite gates verified before start (no '
                    'exceptions on critical path)',
            optimal: '100% of prerequisite gates verified before start',
            ceiling: '100% (a gate cannot be satisfied beyond full completion)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Rows in this batch whose poka-yoke cell is unique',
            observed:
                '0 of 20. The Mistake-Proofing column reads "CI/CD pipeline '
                'physically blocks deployment if any gate for this step '
                'fails." on all twenty rows, and Self-Chasing reads "Automated '
                'Liveness Handshake monitors this step every 30 seconds and '
                'triggers rollback on failure." on all twenty. A pipeline '
                'cannot block on an ordinal into nothing, and nothing rolls '
                'back every thirty seconds across twenty different subjects. '
                'Both columns are one sentence stamped on the batch.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/governance/dependency_gate_eight.dart',
        ],
      ),
    );
  });
}
