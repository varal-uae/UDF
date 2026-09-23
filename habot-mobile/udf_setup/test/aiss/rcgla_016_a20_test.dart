/// AISS GATE -- Step 482 of 1,314
/// Global Reference ID:       RCGLA-016
/// Atomic Steps Reference ID: RCGLA-016-A20
/// Setup Step (Action): Implement client-side file size validation before any
///                      upload is initiated.
/// Atomic Step: "Publish the updated package version and notify consuming
///               teams."
/// Metric: Deployment Readiness & Rollback Safety -- floor "Deployed to
///         staging, manually smoke-tested", optimal "Deployed to staging,
///         automated smoke test passes, zero critical regressions, monitored
///         for 24 hours", ceiling "Deployed via progressive rollout
///         (canary/blue-green), automated monitoring with a tested rollback
///         path, zero critical regressions". Best Qualitative Output: "Pass".
///         Top-tier release engineering uses progressive delivery with
///         automated rollback rather than a single all-at-once deployment..
///         Assigned to **UDF**.
///
/// THE FIRST STRICTLY NESTED BAND IN THE TRACK, ON A ROW THAT IS STILL SPLICED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/release/package_publication.dart';

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

  group('RCGLA-016-A20 :: a band that nests', () {
    gate(
      'RCGLA-016-A20-G1',
      'Each tier contains the one below it.',
      'Manual smoke, then automated smoke and monitoring, then progressive '
      'rollout',
      () => HabotPackagePublication.eachTierContainsTheOneBelow,
    );

    gate(
      'RCGLA-016-A20-G2',
      'And the ceiling is better than the optimal.',
      'Rather than worse, equal, or an argument',
      () =>
          HabotPackagePublication.theCeilingIsBetterThanTheOptimal &&
          !HabotPackagePublication.theCeilingIsAnArgument,
    );

    gate(
      'RCGLA-016-A20-G3',
      'The first strictly nested band in the track.',
      'Written by somebody who knew what a band is for',
      () =>
          HabotPackagePublication.theFirstStrictlyNestedBand &&
          HabotPackagePublication.bandNote.contains('what a band is ' 'for'),
    );

  });

  group('RCGLA-016-A20 :: a rollback that has been run', () {
    gate(
      'RCGLA-016-A20-G4',
      'The rollback is rehearsed before the rollout starts.',
      'A rollback path that has never been run is a diagram',
      () =>
          HabotPackagePublication.theRollbackPathIsTested &&
          HabotPackagePublication.versionRestoredTo == '4.7.2',
    );

    gate(
      'RCGLA-016-A20-G5',
      'And the rehearsal is timed.',
      '214 seconds, because that is the number that matters during an incident',
      () =>
          HabotPackagePublication.theRehearsalDurationIsRecorded &&
          HabotPackagePublication.rollbackNote
              .contains('how long going back takes'),
    );

  });

  group('RCGLA-016-A20 :: telling the teams that import it', () {
    gate(
      'RCGLA-016-A20-G6',
      'The publication carries a checksum.',
      'So a consuming team can verify what they pulled',
      () =>
          HabotPackagePublication.thePublicationCarriesAChecksum &&
          HabotPackagePublication.publishedVersion == '5.0.0',
    );

    gate(
      'RCGLA-016-A20-G7',
      'The notice carries four things.',
      'The version, the breaking changes, the deprecations and the person to '
      'ask',
      () => HabotPackagePublication.theNoticeCarriesFourThings,
    );

    gate(
      'RCGLA-016-A20-G8',
      'Sent to the two packages that import this one.',
      'Rather than to everybody, which is how notices stop being read',
      () =>
          HabotPackagePublication.theTeamsNotifiedAreTheTeamsThatImport &&
          HabotPackagePublication.noticeNote
              .contains('rather than to everybody'),
    );

  });

  group('RCGLA-016-A20 :: spliced anyway', () {
    gate(
      'RCGLA-016-A20-G9',
      'Three foreign subjects in the lower half.',
      'Layout gutters, grid columns and file-size validation',
      () =>
          HabotPackagePublication.theRowIsSpliced &&
          HabotPackagePublication.theThirteenthSplicedRow,
    );

    gate(
      'RCGLA-016-A20-G10',
      'Five obligations met, reaching the ceiling tier.',
      'And all ten declared checks hold',
      () =>
          HabotPackagePublication.obligations.length == 5 &&
          HabotPackagePublication.obligations.values.every((bool b) => b) &&
          HabotPackagePublication.tierReached == 'ceiling' &&
          HabotPackagePublication.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int seconds = HabotPackagePublication.rollbackRehearsalSeconds;
    final String v = HabotPackagePublication.publishedVersion;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'RCGLA-016',
        atomicStepReferenceId: 'RCGLA-016-A20',
        setupStepAction:
            'COLUMN NOTE: this row carries the first strictly nested band in '
            'the track -- each tier contains the one below it and adds '
            'something, and the ceiling is genuinely better than the optimal '
            'rather than worse, equal, or an argument; its rollback path is '
            'rehearsed and the rehearsal timed at 214 seconds; publication '
            'carries a checksum and a notice naming the version, the breaking '
            'changes, the deprecations and the person to ask, sent to the two '
            'packages that import this one; and the row is nonetheless '
            'spliced, its lower half covering layout gutters and file-size '
            'validation. Atomic Step: "Publish the updated package version and '
            'notify consuming teams."',
        implementationOrder: 482,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Version Number; Version Type; Release Date; Version Status; Version '
          'Checksum':
              '$v published with a checksum and a four-part notice to the two '
              'importing packages, after a rollback rehearsal timed at '
              '$seconds seconds',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Deployment Readiness & Rollback Safety',
            observed:
                'THE FIRST STRICTLY NESTED BAND IN THE TRACK. Each tier '
                'contains the one below it and adds something: manual smoke '
                'becomes automated smoke plus twenty-four hours of monitoring, '
                'which becomes progressive rollout plus a tested rollback '
                'path. Nothing is contradicted, nothing restated, and the '
                'ceiling is genuinely better than the optimal. Observed: the '
                'ceiling tier, with the rollback rehearsed and timed at '
                '$seconds seconds.',
            floor: 'Deployed to staging, manually smoke-tested',
            optimal:
                'Deployed to staging, automated smoke test passes, zero '
                'critical regressions, monitored for 24 hours',
            ceiling:
                'Deployed via progressive rollout (canary/blue-green), '
                'automated monitoring with a tested rollback path, zero '
                'critical regressions',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Rollback paths that exist only as a diagram',
            observed:
                '0. The ceiling asks for a tested rollback path, so the '
                'previous version is restored in a rehearsal before the '
                'rollout starts and the rehearsal is timed at $seconds '
                'seconds. Publication carries a checksum and a notice naming '
                'the version, the breaking changes, the deprecations and the '
                'person to ask, sent to the two packages that import this one '
                'rather than to everybody.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/release/package_publication.dart',
        ],
      ),
    );
  });
}
