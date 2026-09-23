/// AISS GATE -- Step 483 of 1,314
/// Global Reference ID:       DRVUT-010
/// Atomic Steps Reference ID: DRVUT-010-A18
/// Setup Step (Action): Map final view content components to render when
///                      isLoading == false.
/// Atomic Step: "Release the automated visual escalation features onto the live
///               production runtime builds."
/// Metric: Production Release Success Rate (%) / Change Failure Rate -- floor
///         "98% successful releases (<=2% change-failure rate)", optimal "99.5%
///         successful releases (<=0.5% change-failure rate)", ceiling "99.9%+
///         successful releases (elite DevOps benchmark)". Best Qualitative
///         Output: "Pass/Fail". Industry elite-performer DevOps benchmarks
///         (DORA) place production change-failure rate inside this band;
///         anything below the floor is considered a high-risk release process..
///         Assigned to **ADFA**.
///
/// A BAND THAT CITES DORA AND GETS IT RIGHT, OVER A FLOOR FIFTY RELEASES WIDE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/release/escalation_release.dart';

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

  group('DRVUT-010-A18 :: a band that is right', () {
    gate(
      'DRVUT-010-A18-G1',
      'The band ascends and cites a benchmark that exists.',
      '98, 99.5 and 99.9 per cent, where DORA places its performers',
      () =>
          HabotEscalationRelease.theBandAscends &&
          HabotEscalationRelease.theBenchmarkIsReal,
    );

    gate(
      'DRVUT-010-A18-G2',
      'One of two well-formed bands in this batch.',
      'With Step 482\'s, and both are about releasing',
      () =>
          HabotEscalationRelease.twoWellFormedBands &&
          HabotEscalationRelease.bandNote.contains('elite one'),
    );

  });

  group('DRVUT-010-A18 :: what counts as a failure', () {
    gate(
      'DRVUT-010-A18-G3',
      'The band defines no failure, so three are named here.',
      'Rolled back, hotfixed inside a day, or worked around by a worker',
      () =>
          !HabotEscalationRelease.theBandDefinesFailure &&
          HabotEscalationRelease.threeWaysToFail,
    );

    gate(
      'DRVUT-010-A18-G4',
      'Four releases, one of them failed.',
      'A hotfix inside twenty-four hours on 25 August',
      () =>
          HabotEscalationRelease.releases.length == 4 &&
          HabotEscalationRelease.failedCount == 1,
    );

    gate(
      'DRVUT-010-A18-G5',
      'A change-failure rate of 25 per cent, reported as it came out.',
      'Nowhere near the floor, and not rounded',
      () =>
          HabotEscalationRelease.changeFailurePercent == 25 &&
          HabotEscalationRelease.failureNote.contains('nowhere near the floor'),
    );

    gate(
      'DRVUT-010-A18-G6',
      'And the floor needs fifty releases to be reachable at all.',
      'Below that, 98 per cent means no failures; Step 458 found the same '
      'arithmetic',
      () =>
          HabotEscalationRelease.theFloorNeedsFiftyReleases &&
          HabotEscalationRelease.belowThatItMeansZeroFailures &&
          HabotEscalationRelease.arithmeticNote
              .contains('by releasing more often'),
    );

  });

  group('DRVUT-010-A18 :: what an escalation may do', () {
    gate(
      'DRVUT-010-A18-G7',
      'The colour comes from the error container role.',
      'As Step 464 established, and never a raw value',
      () =>
          HabotEscalationRelease.theColourComesFromARole &&
          HabotEscalationRelease.itFollowsStep464,
    );

    gate(
      'DRVUT-010-A18-G8',
      'No escalation takes the whole screen.',
      'It occupies a reserved region rather than interrupting data entry',
      () =>
          HabotEscalationRelease.nobodyLosesTheScreenMidEntry &&
          HabotEscalationRelease.escalationNote.contains('reserved region'),
    );

    gate(
      'DRVUT-010-A18-G9',
      'An acknowledged escalation stays visible.',
      'Acknowledgement stops the noise, not the notice',
      () =>
          HabotEscalationRelease.acknowledgementStopsTheNoiseNotTheNotice &&
          !HabotEscalationRelease.urgencyIsCarriedByColourAlone,
    );

  });

  group('DRVUT-010-A18 :: the result', () {
    gate(
      'DRVUT-010-A18-G10',
      'Five obligations met, and the row reports Fail.',
      'The gates verify the evidence; the evidence says the row fails',
      () =>
          HabotEscalationRelease.obligations.length == 5 &&
          HabotEscalationRelease.obligations.values.every((bool b) => b) &&
          HabotEscalationRelease.schedulingSitsInADataField &&
          HabotEscalationRelease.columnDriftNote
              .contains('stops meaning one thing') &&
          HabotEscalationRelease.qualitativeOutput == 'Fail',
    );
  });

  tearDownAll(() {
    final double cfr = HabotEscalationRelease.changeFailurePercent;
    final int needed =
        HabotEscalationRelease.releasesNeededForTheFloorToBeReachable;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'DRVUT-010',
        atomicStepReferenceId: 'DRVUT-010-A18',
        setupStepAction:
            'COLUMN NOTE: this row\'s band ascends correctly and cites DORA, '
            'one of two well-formed bands in this batch with Step 482\'s; it '
            'gives no definition of a release failure, so three are named here '
            'and the observed rate of 25 per cent over four releases is '
            'reported as it came out, below the floor; a floor of 98 per cent '
            'needs fifty releases before it is reachable with any failure in '
            'it at all, the same arithmetic Step 458 found on a twelve-case '
            'test suite; the escalation surfaces take their colour from the '
            'error container role, never carry urgency by colour alone, never '
            'take the screen from somebody mid-entry, and stay visible after '
            'acknowledgement; and the row keeps "Order: 43 | Duration: 3 '
            'Hours" inside its Data Requirement cell. Atomic Step: "Release '
            'the automated visual escalation features onto the live production '
            'runtime builds."',
        implementationOrder: 483,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Build Status; Build Timestamp; Build Artifacts Path; Build Logs':
              'four releases with a change-failure rate of '
              '${cfr.toStringAsFixed(0)} per cent against a floor that needs '
              '$needed releases to be reachable with any failure in it',
          'Completion Status': 'Fail',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Production Release Success Rate (%) / Change Failure Rate',
            observed:
                'FAIL, AND A FLOOR FIFTY RELEASES WIDE. The band ascends '
                'correctly and cites DORA, one of two well-formed bands in '
                'this batch, but it defines no failure, so three definitions '
                'are named here and one of four releases meets them: a '
                'change-failure rate of ${cfr.toStringAsFixed(0)} per cent '
                'against a floor of 2. That floor is only reachable with a '
                'failure in it once there are $needed releases to divide by, '
                'so for a team releasing fortnightly it means no failures at '
                'all.',
            floor: '98% successful releases (<=2% change-failure rate)',
            optimal: '99.5% successful releases (<=0.5% change-failure rate)',
            ceiling: '99.9%+ successful releases (elite DevOps benchmark)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName:
                'Escalations that take the screen from somebody mid-entry',
            observed:
                '0. Visual escalation means the screen changes colour, '
                'elevates and interrupts, so the colour comes from the error '
                'container role rather than a raw value, urgency is never '
                'carried by colour alone, an escalation occupies a reserved '
                'region instead of taking the screen, and acknowledging it '
                'stops the escalation without hiding the notice. The row also '
                'keeps "Order: 43 | Duration: 3 Hours" inside its Data '
                'Requirement cell.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/release/escalation_release.dart',
        ],
      ),
    );
  });
}
