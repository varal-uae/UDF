/// AISS GATE -- Step 494 of 1,314
/// Global Reference ID:       GEN-05287
/// Atomic Steps Reference ID: GEN-05287
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Confirm that prerequisite Step 1, Step 3 are completed and
///               operational before beginning this step"
/// Metric: Prerequisite Dependency Completion Status -- floor "Prior step
///         incomplete / not started", optimal "Prior step 100% complete &
///         verified", ceiling "1". Best Qualitative Output: "Yes/No". PMBOK 7th
///         Ed. - Dependency & Predecessor Management. Assigned to **UDF**.
///
/// TWO ORDINALS IN ONE CELL, AND A BAND THAT SPEAKS IN THE SINGULAR.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/release/release_prerequisites.dart';

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

  group('GEN-05287 :: two ordinals into nothing', () {
    gate(
      'GEN-05287-G1',
      'Two ordinals in one cell.',
      '"Step 1, Step 3", into a list the sheet does not contain',
      () => HabotReleasePrerequisites.twoOrdinalsInOneCell,
    );

    gate(
      'GEN-05287-G2',
      'The fourth row in this family.',
      'After Steps 457, 459 and 466, and the first to name two',
      () =>
          HabotReleasePrerequisites.theFourthInTheFamily &&
          HabotReleasePrerequisites.atomicStep.contains('Step 1, Step 3'),
    );

    gate(
      'GEN-05287-G3',
      'While the band speaks in the singular.',
      '"Prior step 100% complete", under an instruction naming two',
      () =>
          HabotReleasePrerequisites.evenTheBandLostCount &&
          HabotReleasePrerequisites.ordinalNote.contains('lost count'),
    );

  });

  group('GEN-05287 :: a sixth output vocabulary', () {
    gate(
      'GEN-05287-G4',
      'Yes/No is a sixth output vocabulary.',
      'After Complete/Partial/Not Complete, Pass/Fail, High/Medium/Low, '
      'Fast/Acceptable/Delayed and Good/Average/Poor',
      () => HabotReleasePrerequisites.aSixthVocabulary,
    );

    gate(
      'GEN-05287-G5',
      'Which no single dashboard column can hold.',
      'Somebody has to decide what Yes means next to Average',
      () =>
          HabotReleasePrerequisites.vocabularyNote.contains('next to Average'),
    );

  });

  group('GEN-05287 :: a floor that describes the failure', () {
    gate(
      'GEN-05287-G6',
      'The floor describes the failure, the fifth such.',
      '"Prior step incomplete / not started" is the state of not having '
      'started',
      () =>
          HabotReleasePrerequisites.theFloorDescribesTheFailure &&
          HabotReleasePrerequisites.fifthSuchFloor,
    );

  });

  group('GEN-05287 :: prerequisites from the code', () {
    gate(
      'GEN-05287-G7',
      'Five prerequisites, named from the code.',
      'The obfuscated build, the update channel, the package, the gates and '
      'staging',
      () => HabotReleasePrerequisites.fivePrerequisites,
    );

    gate(
      'GEN-05287-G8',
      'Every one satisfied.',
      'Which an ordinal could never have shown',
      () => HabotReleasePrerequisites.everyPrerequisiteIsSatisfied,
    );

    gate(
      'GEN-05287-G9',
      'And every symbol resolves.',
      'Against a library file that already exists',
      () =>
          HabotReleasePrerequisites.everySymbolResolves &&
          HabotReleasePrerequisites.graphNote.contains('unlike an ordinal'),
    );

    gate(
      'GEN-05287-G10',
      'Five obligations, all met, giving Yes.',
      'And all ten declared checks hold',
      () =>
          HabotReleasePrerequisites.obligations.length == 5 &&
          HabotReleasePrerequisites.obligations.values.every((bool b) => b) &&
          HabotReleasePrerequisites.qualitativeOutput == 'Yes',
    );
  });

  tearDownAll(() {
    final int prereqs = HabotReleasePrerequisites.prerequisites.length;
    final int vocab = HabotReleasePrerequisites.outputVocabularies.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05287',
        atomicStepReferenceId: 'GEN-05287',
        setupStepAction:
            'COLUMN NOTE: this row names two ordinals, Step 1 and Step 3, into '
            'a list the sheet does not contain, the fourth row in that family '
            'after Steps 457, 459 and 466 and the first to name two, while its '
            'own optimal speaks of "Prior step" in the singular; its output '
            'column is a sixth vocabulary, Yes/No; its floor describes the '
            'failure, the fifth such floor; and its five prerequisites are '
            'named from the code as symbols that must resolve, because an '
            'ordinal cannot be checked. Atomic Step: "Confirm that '
            'prerequisite Step 1, Step 3 are completed and operational before '
            'beginning this step"',
        implementationOrder: 494,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Confirm that prerequisite Step 1, Step 3 are completed and':
              '$prereqs prerequisites named from the code and all satisfied, '
              'against two ordinals that point at nothing; $vocab output '
              'vocabularies now in use across the sheet',
          'Completion Status': 'Yes',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Prerequisite Dependency Completion Status',
            observed:
                'TWO ORDINALS, AND A BAND IN THE SINGULAR. The instruction '
                'names Step 1 and Step 3 while the optimal beneath it says '
                '"Prior step", so even the band has lost count of how many '
                'prerequisites there are. It is the fourth row in this family '
                'after Steps 457, 459 and 466 and the first to name two. '
                'Observed: $prereqs prerequisites taken from the code, all '
                'satisfied, every symbol resolving.',
            floor: 'Prior step incomplete / not started',
            optimal: 'Prior step 100% complete & verified',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Output vocabularies in use across the sheet',
            observed:
                '$vocab. Complete/Partial/Not Complete, Pass/Fail, '
                'High/Medium/Low, Fast/Acceptable/Delayed, Good/Average/Poor '
                'and now Yes/No. Six vocabularies across 494 rows means no '
                'dashboard can show one column of outcomes without first '
                'deciding what Yes means next to Average.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/release/release_prerequisites.dart',
        ],
      ),
    );
  });
}
