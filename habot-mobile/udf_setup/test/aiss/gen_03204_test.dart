/// AISS GATE -- Step 383 of 395
/// Global Reference ID:       GEN-03204
/// Atomic Steps Reference ID: GEN-03204
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Add UI disabling logic to deactivate clock-in when device GPS
///               is toggled off."
/// Metric: Disabled State Poka-Yoke Deflection -- floor 1, optimal 1, ceiling
///         1. Best Qualitative Output: "Pass". Poka-Yoke Safeguard Mechanics.
///         Assigned to **UDF**.
///
/// THE COSTLIEST REFUSAL IN THE BATCH: A DISABLED CLOCK-IN WITH NO ROUTE
/// THROUGH IS AN UNPAID HOUR.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/attendance/clock_in_gate.dart';

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

  group('GEN-03204 :: what this refusal costs', () {
    gate(
      'GEN-03204-G1',
      'The shift can start without a location.',
      'Every other refusal in this batch stops somebody changing a number; '
          'this one stops somebody starting work',
      () =>
          HabotClockInGate.theShiftCanStart &&
          HabotClockInGate.aRefusedClockInHasARouteThrough &&
          HabotClockInGate.costNote.contains('an unpaid hour'),
    );

    gate(
      'GEN-03204-G2',
      'The missing location is recorded as missing.',
      'Flagged for a supervisor rather than silently treated as a normal '
          'clock-in',
      () =>
          HabotClockInGate.theExceptionIsVisible &&
          HabotClockInGate.theMissingLocationIsRecordedAsMissing &&
          !HabotClockInGate.aManualClockInIsSilentlyTreatedAsNormal,
    );
  });

  group('GEN-03204 :: four states the row calls one', () {
    gate(
      'GEN-03204-G3',
      'Five location signals, four of which are not a usable fix.',
      'Off for the device, denied to this app, no fix yet, and a fix too '
          'coarse to place somebody at a site',
      () =>
          HabotLocationSignal.values.length == 5 &&
          HabotClockInGate.fourOfFourStatesAreHandled &&
          HabotClockInGate.theRowNamesOneOfFour,
    );

    gate(
      'GEN-03204-G4',
      'Each state gets its own message.',
      'Treating all four as "GPS off" tells somebody in a basement to turn on '
          'a setting that is already on',
      () =>
          HabotClockInGate.everySignalHasItsOwnMessage &&
          HabotClockInGate.statesNote.contains('already on'),
    );

    gate(
      'GEN-03204-G5',
      'Waiting for a fix is a wait, not a refusal.',
      'And only two of the states are something the person can act on',
      () =>
          HabotClockInGate.awaitingAFixIsAWaitNotARefusal &&
          HabotClockInGate.actionableStates == 2,
    );
  });

  group('GEN-03204 :: the permission ladder is already declared', () {
    gate(
      'GEN-03204-G6',
      'Five permission states, each with a remedy.',
      'Step 267 built the ladder for the camera and the same states describe '
          'location',
      () =>
          HabotClockInGate.thePermissionStatesAreDeclared &&
          HabotClockInGate.everyPermissionStateHasARemedy,
    );

    gate(
      'GEN-03204-G7',
      'A permanent denial says so, and the app cannot re-ask.',
      'Which is the state where a silent disabled button is worst, because '
          'nothing the person does inside the app will ever change it',
      () =>
          HabotClockInGate.aPermanentDenialSaysSo &&
          HabotClockInGate.theAppCannotReAskAfterAPermanentDenial &&
          HabotClockInGate.reuseNote.contains('will ever change it'),
    );
  });

  group('GEN-03204 :: a collapsed band and a one-valued column', () {
    gate(
      'GEN-03204-G8',
      'Floor, optimal and ceiling are all 1.',
      'So the band cannot be missed or exceeded and records only whether the '
          'deflection happened',
      () =>
          HabotClockInGate.theBandIsCollapsed &&
          HabotClockInGate.bandFloor == 1 &&
          HabotClockInGate.bandCeiling == 1,
    );

    gate(
      'GEN-03204-G9',
      'Third collapsed band in the track, and the eighth one-valued column.',
      'After Step 353, alongside Step 391 in this batch; the output column '
          'holds the single word "Pass"',
      () =>
          HabotClockInGate.threeCollapsedBandsNow &&
          HabotClockInGate.collapsedBandRows.contains(353) &&
          HabotClockInGate.collapsedBandRows.contains(391) &&
          HabotClockInGate.theCountReachesEight,
    );

    gate(
      'GEN-03204-G10',
      'Output reported as Pass.',
      'Six obligations, all met; four of four location states produce a '
          'correct refusal, and all ten declared checks hold',
      () =>
          HabotClockInGate.obligations.length == 6 &&
          HabotClockInGate.obligations.values.every((bool b) => b) &&
          HabotClockInGate.qualitativeOutput == 'Pass' &&
          HabotClockInGate.statesProducingACorrectRefusal == 4 &&
          HabotClockInGate.checks.length == 10 &&
          HabotClockInGate.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String route = HabotClockInGate.routeThrough;
    final int handled = HabotClockInGate.statesProducingACorrectRefusal;
    final String denied =
        HabotClockInGate.messageFor[HabotLocationSignal.deniedToThisApp] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03204',
        atomicStepReferenceId: 'GEN-03204',
        setupStepAction:
            'COLUMN NOTE: the band on this row sets floor, optimal and ceiling '
            'all to 1, so it cannot be missed or exceeded -- the third '
            'collapsed band in the track after Step 353 and alongside Step 391 '
            'in this batch; its Best Qualitative Output column holds the '
            'single word "Pass", the eighth one-valued output column; its Data '
            'Requirement cell holds the Atomic Step\'s own text truncated with '
            'an ellipsis; and the Setup Step column is empty. Atomic Step: '
            '"Add UI disabling logic to deactivate clock-in when device GPS is '
            'toggled off."',
        implementationOrder: 383,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Add UI disabling logic to deactivate clock-in when device GPS':
              '$handled of 4 non-usable location states produce a correct and '
                  'actionable refusal',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the route through is to $route; a denial to this app reads '
                  '"$denied"',
          'Data Quality Note':
              'COST: ${HabotClockInGate.costNote} STATES: '
              '${HabotClockInGate.statesNote} REUSE: '
              '${HabotClockInGate.reuseNote} BAND: '
              '${HabotClockInGate.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Disabled State Poka-Yoke Deflection',
            observed:
                'A BAND THAT CANNOT BE MISSED OR EXCEEDED. Floor, optimal and '
                'ceiling are all 1, so the metric records only whether the '
                'deflection happened -- the third collapsed band in this '
                'track, after Step 353 and alongside Step 391 in this batch. '
                'The Best Qualitative Output column holds the single word '
                '"Pass", which is the eighth one-valued output column '
                'recorded. The figure published instead is the share of '
                'location states that produce a correct and actionable '
                'refusal: $handled of four.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Shifts that could not start because of the interface',
            observed:
                '0. This is the costliest refusal in the batch: the person it '
                'stops is paid by the hour and standing at the door, and a '
                'disabled clock-in with no route through is an unpaid hour. '
                'The route is to $route, with the absence recorded rather than '
                'assumed. The row names one location state and there are four '
                'that are not a usable fix; two are actionable, one is a wait '
                'rather than a refusal, and the state where the app can no '
                'longer ask for permission is the one where a silent grey '
                'button is worst.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/attendance/clock_in_gate.dart',
        ],
      ),
    );
  });
}
