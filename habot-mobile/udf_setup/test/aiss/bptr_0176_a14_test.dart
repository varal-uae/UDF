/// AISS GATE -- Step 480 of 1,314
/// Global Reference ID:       BPTR-0176
/// Atomic Steps Reference ID: BPTR-0176-A14
/// Setup Step (Action): Set the notification module\'s visibility state to
///                      remain hidden unless an orphan record condition is
///                      confirmed.
/// Atomic Step: "Deploy the mobile application structure to a staging
///               environment environment."
/// Metric: Release Readiness / Deployment Success Rate -- floor "95", optimal
///         "99.5", ceiling "100". Best Qualitative Output: "Pass (Scale:
///         Pass/Fail)". Deployments to staging/production should pass automated
///         smoke tests on first attempt at a >=95% rate, per standard CI/CD
///         release-engineering benchmarks.. Assigned to **UDF**.
///
/// A CELL THAT ADMITS NOTHING MATCHED, AND A ROW SPLICED ANYWAY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/release/staging_deploy.dart';

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

  group('BPTR-0176-A14 :: a cell that admits its own failure', () {
    gate(
      'BPTR-0176-A14-G1',
      'The Data Requirement says no reference row matched.',
      'The first cell in 480 rows to declare its own failure to match',
      () => HabotStagingDeploy.theCellAdmitsNoMatch,
    );

    gate(
      'BPTR-0176-A14-G2',
      'Which is more useful than a silent splice.',
      'An unmatched row you can see is a row somebody can fix',
      () =>
          HabotStagingDeploy.anUnmatchedRowIsWorseWhenSilent &&
          HabotStagingDeploy.admissionNote.contains('somebody can fix'),
    );

  });

  group('BPTR-0176-A14 :: spliced, and a word repeated', () {
    gate(
      'BPTR-0176-A14-G3',
      'Four foreign subjects in the lower half.',
      'Font bundles, a 30kb payload budget, a 40kb build budget, an '
      'orphan-record notification',
      () =>
          HabotStagingDeploy.fourForeignSubjects &&
          HabotStagingDeploy.theTwelfthSplicedRow,
    );

    gate(
      'BPTR-0176-A14-G4',
      'And the instruction repeats a word.',
      '"A staging environment environment"',
      () =>
          HabotStagingDeploy.aWordIsRepeated &&
          HabotStagingDeploy.rowsBeforeThisOne == 480,
    );

  });

  group('BPTR-0176-A14 :: three bare numbers', () {
    gate(
      'BPTR-0176-A14-G5',
      'The band is three bare numbers.',
      '95, 99.5 and 100, on a metric named as a rate',
      () => HabotStagingDeploy.theBandCarriesNoUnit,
    );

    gate(
      'BPTR-0176-A14-G6',
      'So a reading is declared instead of assumed.',
      'The share of deployments passing smoke tests first time',
      () => HabotStagingDeploy.aReadingIsDeclared,
    );

  });

  group('BPTR-0176-A14 :: what staging is for', () {
    gate(
      'BPTR-0176-A14-G7',
      'Four attempts, three passing first time.',
      'Reported as it came out',
      () =>
          HabotStagingDeploy.attempts.length == 4 &&
          HabotStagingDeploy.firstAttemptRate == 75,
    );

    gate(
      'BPTR-0176-A14-G8',
      'Every first-time pass is the artefact that was promoted.',
      'Staging tests the build that goes to production, not a rebuild',
      () => HabotStagingDeploy.thePromotedArtefactIsTheTestedOne,
    );

    gate(
      'BPTR-0176-A14-G9',
      'Staging holds lifelike data and no real data.',
      'A staging environment with real records is a production environment '
      'with worse access control',
      () => HabotStagingDeploy.noRealDataInStaging,
    );

    gate(
      'BPTR-0176-A14-G10',
      'Five obligations met, and 75 per cent reports Fail.',
      'Against a floor of 95',
      () =>
          HabotStagingDeploy.obligations.length == 5 &&
          HabotStagingDeploy.obligations.values.every((bool b) => b) &&
          HabotStagingDeploy.stagingNote.contains('is a ceremony') &&
          HabotStagingDeploy.qualitativeOutput == 'Fail',
    );
  });

  tearDownAll(() {
    final double rate = HabotStagingDeploy.firstAttemptRate;
    final int attempts = HabotStagingDeploy.attempts.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'BPTR-0176',
        atomicStepReferenceId: 'BPTR-0176-A14',
        setupStepAction:
            'COLUMN NOTE: this row\'s Data Requirement declares in its own '
            'words that no reference row matched, the first cell in 480 rows '
            'to do so, and the row is spliced anyway -- four foreign subjects '
            'about font bundles, payload budgets and an orphan-record '
            'notification, making it the twelfth spliced row; its instruction '
            'repeats the word "environment"; its band is three bare numbers '
            'read here as first-attempt smoke-test percentages; and what is '
            'built promotes the tested artefact, keeps real data out of '
            'staging, and smoke-tests the first two minutes of a shift. Atomic '
            'Step: "Deploy the mobile application structure to a staging '
            'environment environment."',
        implementationOrder: 480,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mobile Platform; OS Version; Device Type; Screen Dimensions':
              '$attempts staging attempts at ${rate.toStringAsFixed(0)} per '
              'cent first-time smoke pass, the tested artefact promoted, and '
              'no real data in staging',
          'Completion Status': 'Fail',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Release Readiness / Deployment Success Rate',
            observed:
                'FAIL, AND A CELL THAT SAYS SO ITSELF. The Data Requirement '
                'declares "No matched reference row in Setup Implementation '
                'master list ... verify manually", the first cell in 480 rows '
                'to admit its own failure to match -- and the row is spliced '
                'anyway, its lower half covering variable font bundles and '
                'payload budgets. Observed: ${rate.toStringAsFixed(0)} per '
                'cent first-time smoke pass over $attempts attempts, against a '
                'floor of 95.',
            floor: '95',
            optimal: '99.5',
            ceiling: '100',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Real records in the staging environment',
            observed:
                '0. A staging deployment nobody uses is a ceremony, so this '
                'one promotes the same artefact it tested rather than a '
                'rebuild, is seeded with data that looks like real data and '
                'contains none of it, and runs a smoke suite covering the four '
                'things a support worker does in the first two minutes of a '
                'shift.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/release/staging_deploy.dart',
        ],
      ),
    );
  });
}
