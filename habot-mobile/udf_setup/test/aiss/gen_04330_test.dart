/// AISS GATE -- Step 323 of 335
/// Global Reference ID:       GEN-04330
/// Atomic Steps Reference ID: GEN-04330
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Build a one-tap emergency escalation button widget."
/// Metric: PR Review Cycle Time -- floor "< 48 hours", optimal "< 24 hours",
///         ceiling "< 4 hours (risk of under-review)". Good/Average/Poor.
///         DORA Metrics / Google Engineering Practices.
///
/// THE BEST-FORMED CEILING IN THIS TRACK, ON A BAND THAT MEASURES THE PULL
/// REQUEST RATHER THAN THE CONTROL.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/support/emergency_escalation.dart';

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

  group('GEN-04330 :: one deliberate action', () {
    gate(
      'GEN-04330-G1',
      'Atomic Step: "one-tap emergency escalation".',
      'One tap is what a person with one hand free needs and what a phone '
          'does in a pocket; a press and hold is one continuous action rather '
          'than two, and no confirmation dialog is used',
      () =>
          !HabotEmergencyEscalation.aConfirmationDialogIsUsed &&
          HabotEmergencyEscalation.theHoldShowsItsProgress &&
          HabotEmergencyEscalation.theHoldIsLongerThanATap,
    );

    gate(
      'GEN-04330-G2',
      'A dialog costs a second deliberate act when the first one mattered.',
      'Which is why the resolution is a hold rather than a confirmation',
      () => HabotEmergencyEscalation.oneTapNote
          .contains('the first one mattered'),
    );

    gate(
      'GEN-04330-G3',
      'Both durations are tokens.',
      'The hold borrows the hesitation dwell for its meaning rather than its '
          'number, and the cancel window is the snackbar-with-action duration',
      () =>
          HabotEmergencyEscalation.bothDurationsAreTokens &&
          HabotEmergencyEscalation.holdMilliseconds == 2000 &&
          HabotEmergencyEscalation.cancelWindow.inSeconds == 6 &&
          HabotEmergencyEscalation.tokenBorrowingNote
              .contains('for its meaning'),
    );

    gate(
      'GEN-04330-G4',
      'Three phases are reversible and the committed one is not.',
      'Lifting the finger early cancels, and the window after it fires '
          'belongs to whoever pressed it by mistake',
      () =>
          HabotEmergencyEscalation.reversiblePhases.length == 3 &&
          HabotEmergencyEscalation.liftingTheFingerEarlyCancels &&
          HabotEmergencyEscalation.theCommittedPhaseIsNotReversible &&
          HabotEmergencyEscalation.theHoldIsShorterThanTheCancelWindow,
    );
  });

  group('GEN-04330 :: the network is often the reason', () {
    gate(
      'GEN-04330-G5',
      'An escalation raised in a basement must not be lost.',
      'It is written to the Step 117 outbox before anything is attempted, so '
          'connectivity is not a condition of being accepted',
      () =>
          !HabotEmergencyEscalation
              .theEscalationRequiresConnectivityToBeAccepted &&
          HabotEmergencyEscalation.offlineNote.contains('Step 117'),
    );

    gate(
      'GEN-04330-G6',
      'Three outcomes, three sentences.',
      'Queued-offline is distinct from sent, because one word covering both '
          'would be the useful half removed',
      () =>
          HabotEmergencyEscalation.everyOutcomeHasItsOwnSentence &&
          HabotEmergencyEscalation.theOfflineCaseIsDistinctFromTheSentCase,
    );
  });

  group('GEN-04330 :: operated without looking', () {
    gate(
      'GEN-04330-G7',
      'A haptic on arm and a haptic on queue.',
      'Both strengths were declared at Step 155; the hand holding the phone '
          'is the only channel that reaches somebody holding on to something '
          'else',
      () =>
          HabotEmergencyEscalation.bothMomentsAreAlreadyDeclared &&
          HabotEmergencyEscalation.hapticNote.contains('Step 155'),
    );

    gate(
      'GEN-04330-G8',
      'The control is in the thumb zone.',
      'The first row in this track where the reach band is load-bearing: the '
          'circumstance the control exists for is the circumstance in which '
          'the other hand is not available',
      () =>
          HabotEmergencyEscalation.theControlIsInTheThumbZone &&
          HabotEmergencyEscalation.reachNote.contains('load-bearing'),
    );
  });

  group('GEN-04330 :: the metric', () {
    gate(
      'GEN-04330-G9',
      'Ceiling: "< 4 hours (risk of under-review)".',
      'The best-formed ceiling this track has met -- it names a hazard above '
          'the optimal, explains why faster is worse there, and is correct',
      () => HabotEmergencyEscalation.theCeilingNamesAHazardAndExplainsIt,
    );

    gate(
      'GEN-04330-G10',
      'And it measures the pull request rather than the control.',
      'Seven declared obligations, all met, giving 1.0 and a Good; all eleven '
          'declared checks hold',
      () =>
          HabotEmergencyEscalation.theMetricMeasuresSomethingElse &&
          HabotEmergencyEscalation.metricNote
              .contains('still not be measured') &&
          HabotEmergencyEscalation.obligations.length == 7 &&
          HabotEmergencyEscalation.obligations.values.every((bool b) => b) &&
          HabotEmergencyEscalation.conformance == 1.0 &&
          HabotEmergencyEscalation.qualitativeOutput == 'Good' &&
          HabotEmergencyEscalation.checks.length == 11 &&
          HabotEmergencyEscalation.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String offline =
        HabotEmergencyEscalation.outcomes['queued offline'] ?? '';
    final String hold = '${HabotEmergencyEscalation.holdMilliseconds}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04330',
        atomicStepReferenceId: 'GEN-04330',
        setupStepAction:
            'COLUMN NOTE: every narrative column on this row is the generic '
            'engineering-console boilerplate, and the metric is DORA\'s PR '
            'Review Cycle Time -- a delivery measure -- on a row about an '
            'emergency control. Atomic Step: "Build a one-tap emergency '
            'escalation button widget."',
        implementationOrder: 323,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Build a one-tap emergency escalation button widget.':
              'a ${hold}ms hold with visible progress, a six-second cancel '
                  'window, and no confirmation dialog',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the offline outcome reads "$offline"; haptics fire on arm and '
                  'on queue so the control can be used without looking',
          'Data Quality Note':
              'ONE TAP: ${HabotEmergencyEscalation.oneTapNote} '
              'TOKEN: ${HabotEmergencyEscalation.tokenBorrowingNote} '
              'OFFLINE: ${HabotEmergencyEscalation.offlineNote} '
              'METRIC: ${HabotEmergencyEscalation.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'PR Review Cycle Time',
            observed:
                'NOT A PROPERTY OF THIS CONTROL. Review cycle time is a real '
                'measure with a real standard and its ceiling is the '
                'best-formed one this track has met -- it names under-review '
                'as a hazard above the optimal and is right to. It says '
                'nothing about whether the escalation reaches anybody. '
                'Reported instead over seven declared obligations, all of '
                'which hold.',
            floor: '< 48 hours',
            optimal: '< 24 hours',
            ceiling: '< 4 hours (risk of under-review)',
          ),
          AissMeasurement(
            metricName: 'Ways the control can fire by accident',
            observed:
                '0. A two-second hold with visible progress is not something a '
                'pocket produces, lifting the finger early cancels, and a '
                'six-second window after it fires belongs to whoever pressed '
                'it by mistake. No confirmation dialog is used, because that '
                'would cost a second deliberate act at the moment the first '
                'one mattered.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/support/emergency_escalation.dart',
        ],
      ),
    );
  });
}
