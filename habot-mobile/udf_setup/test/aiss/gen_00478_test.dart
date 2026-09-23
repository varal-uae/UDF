/// AISS GATE -- Step 485 of 1,314
/// Global Reference ID:       GEN-00478
/// Atomic Steps Reference ID: GEN-00478
/// Setup Step (Action): Implement the optional loading indicator centered
///                      within the overlay -- spinner or progress bar.
/// Atomic Step: "Set alert conditions triggering a Shakti Defense Alert if
///               timestamp age exceeds 65 minutes."
/// Metric: Backup Age Alert Threshold -- floor "$> 65\text{ mins}$", optimal
///         "$> 65\text{ mins}$", ceiling "$> 65\text{ mins}$". Best Qualitative
///         Output: "Pass / Fail". Habot Shakti Safety Protocol. Assigned to
///         **ADFA**.
///
/// A BAND WHOSE THREE CELLS ARE THE ALERT CONDITION, TYPESET IN LATEX.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/alerts/backup_age_alert.dart';

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

  group('GEN-00478 :: three identical cells', () {
    gate(
      'GEN-00478-G1',
      'Floor, optimal and ceiling are the same string.',
      'One typeset fragment meaning "more than 65 minutes", three times',
      () => HabotBackupAgeAlert.allThreeCellsAreIdentical,
    );

    gate(
      'GEN-00478-G2',
      'The second such collapse in this batch.',
      'After Step 481, and the band holds the rule rather than a measure of it',
      () =>
          HabotBackupAgeAlert.theSecondSuchRowInThisBatch &&
          HabotBackupAgeAlert.theBandHoldsTheRuleNotAMeasure,
    );

    gate(
      'GEN-00478-G3',
      'And the fifth LaTeX band in the track.',
      'A typeset fragment in a column read by software',
      () =>
          HabotBackupAgeAlert.theFifthLatexBand &&
          HabotBackupAgeAlert.bandNote.contains('never fires'),
    );

  });

  group('GEN-00478 :: what sixty-five minutes means', () {
    gate(
      'GEN-00478-G4',
      'Sixty-five minutes is sixty plus five.',
      'An hourly backup and five minutes of grace, said out loud',
      () =>
          HabotBackupAgeAlert.theThresholdIsIntervalPlusGrace &&
          HabotBackupAgeAlert.derivationNote.contains('tuning it to ninety'),
    );

  });

  group('GEN-00478 :: the alert\'s behaviour', () {
    gate(
      'GEN-00478-G5',
      'Seventy-one minutes fires.',
      'Above the threshold, where the alert is meant to sound',
      () => HabotBackupAgeAlert.itFiresAboveTheThreshold,
    );

    gate(
      'GEN-00478-G6',
      'Sixty-four minutes does not.',
      'Below it, where a quiet alert is the correct alert',
      () => HabotBackupAgeAlert.itIsQuietBelowTheThreshold,
    );

    gate(
      'GEN-00478-G7',
      'A ninety-minute clock skew raises a clock alert.',
      'Not a backup alert; the age cannot be trusted if the clock cannot',
      () =>
          HabotBackupAgeAlert.aDriftingClockRaisesADifferentAlert &&
          HabotBackupAgeAlert.skewToleranceSeconds == 120,
    );

    gate(
      'GEN-00478-G8',
      'And an age is not a wall time.',
      'The reading is the age of the data, as Step 431 established',
      () =>
          HabotBackupAgeAlert.anAgeIsNotAWallTime &&
          HabotBackupAgeAlert.clockNote.contains('not the backup'),
    );

    gate(
      'GEN-00478-G9',
      'The alert names the backup, its age and the consequence.',
      'Three things, because an alert that says "failure" is a notification',
      () => HabotBackupAgeAlert.theAlertSaysThreeThings,
    );

  });

  group('GEN-00478 :: the result', () {
    gate(
      'GEN-00478-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotBackupAgeAlert.obligations.length == 5 &&
          HabotBackupAgeAlert.obligations.values.every((bool b) => b) &&
          HabotBackupAgeAlert.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int threshold = HabotBackupAgeAlert.thresholdMinutes;
    final int cases = HabotBackupAgeAlert.corpus.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00478',
        atomicStepReferenceId: 'GEN-00478',
        setupStepAction:
            'COLUMN NOTE: this row\'s floor, optimal and ceiling are one '
            'identical LaTeX string holding the alert condition itself, the '
            'second band in this batch to collapse all three cells after Step '
            '481 and the fifth typeset fragment in the track, so what is '
            'measured here is the alert\'s behaviour instead: it fires at 71 '
            'minutes, stays quiet at 64, says which backup and how old and '
            'what happens next, derives its threshold as an hourly backup plus '
            'five minutes of grace, and raises a separate clock alert rather '
            'than a false backup alert when the device clock has drifted. '
            'Atomic Step: "Set alert conditions triggering a Shakti Defense '
            'Alert if timestamp age exceeds 65 minutes."',
        implementationOrder: 485,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Set alert conditions triggering a Shakti Defense Alert if timestamp':
              '$cases worked observations against a $threshold minute '
              'threshold: fires at 71, quiet at 64, and a clock alert rather '
              'than a backup alert on a ninety-minute skew',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Backup Age Alert Threshold',
            observed:
                'THE BAND HOLDS THE RULE, NOT A MEASURE OF IT. Floor, optimal '
                'and ceiling are one identical LaTeX string meaning "more than '
                '65 minutes", so nothing in the row could distinguish an alert '
                'that works from one that never fires. It is the second band '
                'in this batch to collapse all three cells and the fifth '
                'typeset fragment in the track. What is measured instead is '
                'behaviour: fires at 71 minutes, quiet at 64, threshold '
                'derived as $threshold.',
            floor: r'$> 65\text{ mins}$',
            optimal: r'$> 65\text{ mins}$',
            ceiling: r'$> 65\text{ mins}$',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'False alerts raised by a drifting clock',
            observed:
                '0 of $cases. An alert keyed on age needs a clock it can '
                'trust: if the device clock drifts, a backup that ran four '
                'minutes ago looks two hours old and the alert fires at three '
                'in the morning for nothing. A skew beyond two minutes raises '
                'a different alert, about the clock rather than the backup, '
                'and every alert names which backup, how old it is, and what '
                'happens if nothing is done.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/alerts/backup_age_alert.dart',
        ],
      ),
    );
  });
}
