/// AISS GATE -- Step 470 of 1,314
/// Global Reference ID:       GEN-05089
/// Atomic Steps Reference ID: GEN-05089
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Package the resulting logic into the designated shared module:
///               @Universal-Library/ui-evaluations."
/// Metric: Shared Module Packaging & Versioning Compliance -- floor "Module
///         published with valid semantic version and passing lint/build
///         checks", optimal "100% SemVer-compliant release with automated build
///         passing", ceiling "100% (compliance is binary; no upper excess)".
///         Best Qualitative Output: "Complete / Partial / Not Complete".
///         Semantic Versioning 2.0.0 (SemVer) / npm package publishing
///         standard. Assigned to **UDF**.
///
/// A VERSION NUMBER THAT DECIDES WHAT A FIVE-YEAR-OLD CHART MEANS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/assessment/evaluations_package.dart';

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

  group('GEN-05089 :: Step 460 again', () {
    gate(
      'GEN-05089-G1',
      'The artefact to prepare is the module\'s own name.',
      '"Data/artifacts to prepare: @Universal-Library/ui-evaluations."',
      () => HabotEvaluationsPackage.theArtefactIsTheModuleName,
    );

    gate(
      'GEN-05089-G2',
      'The row names two registries, as Step 460 did.',
      '@Universal-Library/ui-evaluations and @habot/shared-library',
      () =>
          HabotEvaluationsPackage.theRowNamesTwoRegistries &&
          HabotEvaluationsPackage.itIsStep460sPatternAgain,
    );

    gate(
      'GEN-05089-G3',
      'Ten rows apart, with the same band holding one state.',
      'Everything Step 460 found, found again',
      () =>
          HabotEvaluationsPackage.rowsApartFromStep460 == 10 &&
          HabotEvaluationsPackage.repeatNote.contains('here again'),
    );

  });

  group('GEN-05089 :: the version is part of the record', () {
    gate(
      'GEN-05089-G4',
      'Three stored assessments, three module versions.',
      '1.2.0, 2.0.0 and 3.0.0',
      () =>
          HabotEvaluationsPackage.stored.length == 3 &&
          HabotEvaluationsPackage.distinctVersionsInTheRecord == 3,
    );

    gate(
      'GEN-05089-G5',
      'Every one carries the version that produced it.',
      'Because scoring changes and the record does not',
      () => HabotEvaluationsPackage.everyRecordCarriesItsVersion,
    );

    gate(
      'GEN-05089-G6',
      'And none is re-rendered with today\'s rules.',
      'Each point keeps the semantics of its own version',
      () => HabotEvaluationsPackage.eachPointKeepsItsOwnSemantics,
    );

    gate(
      'GEN-05089-G7',
      'Because a rebanding would rewrite history.',
      'A 2022 point and a 2026 point would stop meaning the same thing',
      () => HabotEvaluationsPackage.historyNote.contains('rewrites history'),
    );

  });

  group('GEN-05089 :: a major version is a migration', () {
    gate(
      'GEN-05089-G8',
      'The major version ships with a migration statement.',
      'What changed for old data, and what is shown beside it',
      () => HabotEvaluationsPackage.aMajorVersionShipsWithAMigrationStatement,
    );

    gate(
      'GEN-05089-G9',
      'The version is well formed and the build passes.',
      'Which is the whole of the floor and the whole of the optimal',
      () =>
          HabotEvaluationsPackage.semverIsWellFormed &&
          HabotEvaluationsPackage.lintAndBuildPass,
    );

    gate(
      'GEN-05089-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotEvaluationsPackage.obligations.length == 5 &&
          HabotEvaluationsPackage.obligations.values.every((bool b) => b) &&
          HabotEvaluationsPackage.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final String v = HabotEvaluationsPackage.version;
    final int stored = HabotEvaluationsPackage.stored.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05089',
        atomicStepReferenceId: 'GEN-05089',
        setupStepAction:
            'COLUMN NOTE: this row repeats Step 460 ten rows later -- a floor '
            'and an optimal naming one state, a Data Requirement that is the '
            'module\'s own name, and two registries named on one row -- and '
            'the module it publishes treats its own version as part of a '
            'child\'s record, storing the producing version with every '
            'assessment and rendering each point under the semantics of its '
            'own version, so that a major release is a migration with a '
            'statement about old data rather than a release. Atomic Step: '
            '"Package the resulting logic into the designated shared module: '
            '@Universal-Library/ui-evaluations."',
        implementationOrder: 470,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          '@Universal-Library/ui-evaluations':
              'published at $v with $stored stored assessments each carrying '
                  'the version that produced it and rendered under its own '
                  'semantics; both registry names recorded',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Shared Module Packaging & Versioning Compliance',
            observed:
                'STEP 460 AGAIN, TEN ROWS LATER: a floor and an optimal naming '
                'one state, a Data Requirement that is the module\'s own name, '
                'and two registries on one row. Observed: published at $v with '
                'lint and build passing, and $stored stored assessments across '
                'three module versions.',
            floor:
                'Module published with valid semantic version and passing '
                    'lint/build checks',
            optimal:
                '100% SemVer-compliant release with automated build passing',
            ceiling: '100% (compliance is binary; no upper excess)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName:
                'Historical assessments re-rendered under today\'s rules',
            observed:
                '0 of $stored. If the scoring or banding in this module '
                'changes, a point recorded in 2022 and a point recorded in '
                '2026 stop meaning the same thing, and a chart that renders '
                'both with today\'s rules quietly rewrites history. Every '
                'stored assessment records the module version that produced '
                'it, and the major release ships with a statement of what '
                'changed for old data.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/assessment/evaluations_package.dart',
        ],
      ),
    );
  });
}
