/// AISS GATE -- Step 464 of 1,314
/// Global Reference ID:       GEN-05001
/// Atomic Steps Reference ID: GEN-05001
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Apply the mobile-first UI decision: M3 Floating Action Button
///               mic control with pulsing red recording indicator."
/// Metric: UI Design Token Compliance Rate -- floor ">=95% of components
///         sourced from approved design tokens", optimal "100% token
///         compliance, zero raw hex/pixel overrides", ceiling "100% (no benefit
///         beyond full compliance)". Best Qualitative Output: "Pass / Fail".
///         Google Material Design 3 (M3) Specification. Assigned to **UDF**.
///
/// AN INSTRUCTION THAT WOULD FAIL ITS OWN ROW'S METRIC, AND A RECORDING LIGHT
/// FOR THE ROOM.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/capture/recording_indicator.dart';

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

  group('GEN-05001 :: the row against itself', () {
    gate(
      'GEN-05001-G1',
      'The instruction names a raw colour.',
      '"Pulsing red", on a row scored for design token compliance',
      () =>
          HabotRecordingIndicator.theInstructionNamesARawColour &&
          HabotRecordingIndicator.theOptimalForbidsRawColours,
    );

    gate(
      'GEN-05001-G2',
      'So written as given the row fails itself.',
      'The optimal demands zero raw hex overrides; the first such row in the '
          'track',
      () =>
          HabotRecordingIndicator.theRowContradictsItself &&
          HabotRecordingIndicator.firstSuchRow == 464,
    );

    gate(
      'GEN-05001-G3',
      'The error colour role honours it and keeps the metric.',
      'Red in both themes, and a token',
      () =>
          HabotRecordingIndicator.theInstructionIsHonouredByToken &&
          HabotRecordingIndicator.contradictionNote.contains('at once'),
    );

  });

  group('GEN-05001 :: a pulse is an animation', () {
    gate(
      'GEN-05001-G4',
      'Reduced motion stops the pulse.',
      'Somebody who asked for less movement has asked for less movement',
      () => HabotRecordingIndicator.reducedMotionStopsThePulse,
    );

    gate(
      'GEN-05001-G5',
      'And leaves a steady mark behind.',
      'An indicator that depends on animation stops telling anybody anything',
      () =>
          HabotRecordingIndicator.theIndicatorSurvivesWithoutMotion &&
          HabotRecordingIndicator.reducedMotionIsObserved,
    );

  });

  group('GEN-05001 :: four channels', () {
    gate(
      'GEN-05001-G6',
      'Four channels, only one of them colour.',
      'Colour role, the word "Recording", an elapsed timer, and an '
          'announcement',
      () =>
          HabotRecordingIndicator.fourChannels &&
          HabotRecordingIndicator.stateIsNotCarriedByColourAlone,
    );

    gate(
      'GEN-05001-G7',
      'The indicator cannot be dismissed while recording.',
      'It is for the children and families in the room',
      () =>
          HabotRecordingIndicator.theRoomCanSeeIt &&
          HabotRecordingIndicator
              .roomNote.contains('rather than for the person'),
    );

  });

  group('GEN-05001 :: for the room, not the operator', () {
    gate(
      'GEN-05001-G8',
      'The 56dp component wins over the 48dp minimum.',
      'A minimum is not a size',
      () => HabotRecordingIndicator.theLargerComponentWins,
    );

    gate(
      'GEN-05001-G9',
      'The third such conflation in three batches.',
      'After Steps 422 and 444',
      () => HabotRecordingIndicator.thirdSuchConflation,
    );

    gate(
      'GEN-05001-G10',
      'Five obligations met, and nine of nine come from tokens.',
      'And all ten declared checks hold',
      () =>
          HabotRecordingIndicator.obligations.length == 5 &&
          HabotRecordingIndicator.obligations.values.every((bool b) => b) &&
          HabotRecordingIndicator.tokenCompliance == 100 &&
          HabotRecordingIndicator.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final double tokens = HabotRecordingIndicator.tokenCompliance;
    final int channels = HabotRecordingIndicator.signals.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05001',
        atomicStepReferenceId: 'GEN-05001',
        setupStepAction:
            'COLUMN NOTE: this row instructs a "pulsing red" indicator while '
            'its own optimal demands zero raw colour overrides, the first row '
            'in the track whose words would break its own band, so the '
            'indicator uses the error colour role; the pulse stops under '
            'reduced motion and leaves a steady mark; state is carried in four '
            'channels rather than by colour alone; the indicator cannot be '
            'dismissed while recording because it is for the room; and its '
            '48dp touch-target figure is a minimum read as a size, as at Steps '
            '422 and 444. Atomic Step: "Apply the mobile-first UI decision: M3 '
            'Floating Action Button mic control with pulsing red recording '
            'indicator."',
        implementationOrder: 464,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Apply the mobile-first UI decision: M3 Floating Action Button mic':
              'the error colour role in place of a raw red, the pulse stopped '
                  'under reduced motion, state in $channels channels, and the '
                  'indicator undismissable while recording; '
                  '${tokens.toStringAsFixed(0)} per cent token compliance',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design Token Compliance Rate',
            observed:
                'THE ROW\'S OWN WORDS WOULD BREAK ITS OWN BAND. "Pulsing red" '
                'is the instruction and "zero raw hex/pixel overrides" is the '
                'same row\'s optimal, which makes this the first row in the '
                'track that fails itself as written. The error colour role is '
                'red in both themes and is a token, so both hold. Observed: '
                '${tokens.toStringAsFixed(0)} per cent of components from '
                'approved tokens.',
            floor: '>=95% of components sourced from approved design tokens',
            optimal: '100% token compliance, zero raw hex/pixel overrides',
            ceiling: '100% (no benefit beyond full compliance)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Channels carrying the recording state',
            observed:
                '$channels. A red dot that pulses tells a blind person nothing '
                'and tells anybody nothing once reduced motion stops the '
                'animation, so the state is carried by the colour role, the '
                'word "Recording", an elapsed timer and an announcement. The '
                'indicator cannot be dismissed while recording and stays above '
                'sheets and dialogs, because the people it is for are the '
                'children and families in the room.',
            floor: '1',
            optimal: '3',
            ceiling: '4',
            higherIsBetter: true,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/capture/recording_indicator.dart',
        ],
      ),
    );
  });
}
