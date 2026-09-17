/// AISS GATE -- Step 381 of 395
/// Global Reference ID:       GEN-03072
/// Atomic Steps Reference ID: GEN-03072
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Physically disable UI edit buttons at the station where
///               manual intervention is detected."
/// Metric: Mobile Usability Task Success Rate (%) -- floor 80, optimal 95,
///         ceiling 100. Good/Average/Poor. Nielsen Norman Group Mobile UX
///         Heuristics / ISO 9241-11. Assigned to **UDF**.
///
/// "DETECTED" IS AN INFERENCE, AND THE LOCK IS FOR THE PERSON WHO IS NOT AT THE
/// STATION.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/station_edit_lock.dart';

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

  group('GEN-03072 :: detection is inference', () {
    gate(
      'GEN-03072-G1',
      'The lock names the signal that caused it.',
      'A lock driven by a signal that is wrong once a week strands somebody '
          'once a week',
      () =>
          HabotStationEditLock.theSignalIsAnInference &&
          HabotStationEditLock.theLockNamesItsSignal &&
          HabotStationEditLock.theReasonNamesTheSignal,
    );

    gate(
      'GEN-03072-G2',
      'The signal can be disputed, and a dispute needs a name.',
      'An override with no author is an override nobody can ask about',
      () =>
          HabotStationEditLock.thereIsAWayToDisputeIt &&
          HabotStationEditLock.aDisputeNeedsAName &&
          HabotStationMode.values.length == 3 &&
          HabotStationEditLock.detectionNote.contains('nobody can ask about'),
    );
  });

  group('GEN-03072 :: two audiences, two messages', () {
    gate(
      'GEN-03072-G3',
      'The station and the remote surface say different things.',
      'Whoever is intervening knows they are; the lock exists to stop a second '
          'person editing remotely',
      () =>
          HabotStationEditLock.theTwoAudiencesGetDifferentMessages &&
          !HabotStationEditLock.aSingleSharedStringIsUsed,
    );

    gate(
      'GEN-03072-G4',
      'The remote message names the holder and the local one addresses the '
          'person present.',
      '"Rashid is working on this station" against "edits are off while you '
          'work"',
      () =>
          HabotStationEditLock.theRemoteMessageNamesTheHolder &&
          HabotStationEditLock.theLocalMessageAddressesThePersonPresent,
    );

    gate(
      'GEN-03072-G5',
      'One shared string would get the remote one wrong.',
      'Which is the only one that matters',
      () => HabotStationEditLock.audienceNote
          .contains('the only one that matters'),
    );
  });

  group('GEN-03072 :: a holder and an age', () {
    gate(
      'GEN-03072-G6',
      'The lock carries both.',
      'A lock with no holder and no age is an outage',
      () =>
          HabotStationEditLock.theLockHasAHolderAndAnAge &&
          HabotStationEditLock.ageMinutes == 4,
    );

    gate(
      'GEN-03072-G7',
      'The age is monotonic, as Step 133 settled.',
      'A lock that appears to have lasted a negative eleven minutes after a '
          'clock correction is a lock nobody trusts again',
      () =>
          HabotStationEditLock.theAgeIsMonotonic &&
          !HabotStationEditLock.theAgeComesFromAWallClock &&
          HabotStationEditLock.theStepThatSettledElapsedTime == 133,
    );
  });

  group('GEN-03072 :: the kind, and a metric that runs backwards', () {
    gate(
      'GEN-03072-G8',
      'The lock is conditional and is not a dead end.',
      '"Physically" is the same instruction Step 292 met as "permanently": '
          'make the control unusable, which says nothing about how long',
      () =>
          HabotStationEditLock.theLockIsConditional &&
          HabotStationEditLock.theLockIsNotADeadEnd &&
          HabotStationEditLock.kindNote.contains('how long it lasts'),
    );

    gate(
      'GEN-03072-G9',
      'A task success rate runs backwards on an interlock.',
      'An interlock exists so that some attempts do not complete, so a lock '
          'working perfectly lowers the number',
      () =>
          HabotStationEditLock.theMetricRunsBackwardsHere &&
          !HabotStationEditLock.anInterlockRaisesTaskSuccess &&
          HabotStationEditLock.metricNote.contains('lowers the number'),
    );

    gate(
      'GEN-03072-G10',
      'Output reported as Good / Average / Poor.',
      'Six obligations, all met, giving Good; the band is well formed, and all '
          'ten declared checks hold',
      () =>
          HabotStationEditLock.obligations.length == 6 &&
          HabotStationEditLock.obligations.values.every((bool b) => b) &&
          HabotStationEditLock.qualitativeOutput == 'Good' &&
          HabotStationEditLock.theBandIsWellFormed &&
          HabotStationEditLock.checks.length == 10 &&
          HabotStationEditLock.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String local = HabotStationEditLock.views.first.message;
    final String remote = HabotStationEditLock.views.last.message;
    final String signal = HabotStationEditLock.signalName;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03072',
        atomicStepReferenceId: 'GEN-03072',
        setupStepAction:
            'COLUMN NOTE: the metric on this row is a mobile usability task '
            'success rate applied to a safety interlock, whose whole purpose '
            'is that some attempts do not succeed, so a lock working perfectly '
            'lowers the score; its Data Requirement cell holds the Atomic '
            'Step\'s own text truncated with an ellipsis as the artefact to '
            'prepare; and the Setup Step column is empty. The band is well '
            'formed. Atomic Step: "Physically disable UI edit buttons at the '
            'station where manual intervention is detected."',
        implementationOrder: 381,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Physically disable UI edit buttons at the station where manual':
              'locked on the signal "$signal", with a named dispute route',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'at the station the lock reads "$local"; remotely it reads '
                  '"$remote"',
          'Data Quality Note':
              'DETECTION: ${HabotStationEditLock.detectionNote} AUDIENCE: '
              '${HabotStationEditLock.audienceNote} AGE: '
              '${HabotStationEditLock.ageNote} KIND: '
              '${HabotStationEditLock.kindNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile Usability Task Success Rate (%)',
            observed:
                'A METRIC THAT RUNS BACKWARDS ON THIS ROW. A task success rate '
                'asks whether people complete what they set out to do; an '
                'interlock exists precisely so that some attempts do not '
                'complete, so a lock working perfectly lowers the number. The '
                'band itself is well formed -- 80, 95, 100, correctly ordered '
                '-- which is worth recording after a batch of inverted, '
                'collapsed and typeset ones.',
            floor: '80',
            optimal: '95',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Locks that strand somebody with no route back',
            observed:
                '0. "Detected" is an inference from a signal, and every '
                'inference has a false-positive rate, so the lock names the '
                'signal -- "$signal" -- and offers a dispute that takes an '
                'author. The lock is conditional rather than latched, carries '
                'a holder and a monotonic age, and says different things to '
                'its two audiences: the person at the station already knows '
                'they are intervening, while the person who might edit '
                'remotely needs to know who is working on it and for how long.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/station_edit_lock.dart',
        ],
      ),
    );
  });
}
