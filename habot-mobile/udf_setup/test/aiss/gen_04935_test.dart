/// AISS GATE -- Step 462 of 1,314
/// Global Reference ID:       GEN-04935
/// Atomic Steps Reference ID: GEN-04935
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Test the implementation against the completion measures: \95%
///               speech recognition accuracy; sub-200ms real-time text
///               transcription delay."
/// Metric: Acceptance / Completion-Measure Test Pass Rate -- floor ">=95% of
///         stated completion measures met (e.g. recovery, accuracy, zero-defect
///         targets)", optimal "100% of stated completion measures met exactly
///         as specified", ceiling "100% (measure is binary pass/fail against
///         the stated target)". Best Qualitative Output: "Pass / Fail".
///         ISO/IEC/IEEE 29119 Software Testing Standard -- acceptance test
///         level. Assigned to **ADFA**.
///
/// THE SECOND ROW IN THE TRACK WHOSE TARGET LOST ITS COMPARISON SIGN, AND A
/// FAIL THAT SAYS SO.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/capture/recognition_accuracy.dart';

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

  group('GEN-04935 :: a glyph that is not there', () {
    gate(
      'GEN-04935-G1',
      'A backslash stands where a comparison sign was.',
      'The completion measure begins with the character that tried to carry it',
      () => HabotRecognitionAccuracy.aBackslashStandsWhereASignWas,
    );

    gate(
      'GEN-04935-G2',
      'And Step 447 carried the same defect fifteen steps earlier.',
      'What Batch Q recorded as a suspicion now has two confirmed members',
      () =>
          HabotRecognitionAccuracy.twoConfirmedMembers &&
          HabotRecognitionAccuracy.stepsApart == 15,
    );

    gate(
      'GEN-04935-G3',
      'So the Completion Measures column is worth scanning.',
      'Before any row in it is scored',
      () =>
          HabotRecognitionAccuracy.theColumnIsWorthScanning &&
          HabotRecognitionAccuracy.glyphNote.contains('class of defect'),
    );

  });

  group('GEN-04935 :: two measures, one met', () {
    gate(
      'GEN-04935-G4',
      'The delay measure is met at 168 ms.',
      'Against a stated 200 ms',
      () => HabotRecognitionAccuracy.theDelayMeasureIsMet,
    );

    gate(
      'GEN-04935-G5',
      'The aggregate accuracy misses 95.',
      '94.3 per cent under the intended reading, at least',
      () => HabotRecognitionAccuracy.theAccuracyMeasureIsMissed,
    );

    gate(
      'GEN-04935-G6',
      'One measure of two gives a pass rate of 50.',
      'Against a floor of 95, which is a Fail',
      () =>
          HabotRecognitionAccuracy.measuresMet == 1 &&
          HabotRecognitionAccuracy.passRate == 50,
    );

  });

  group('GEN-04935 :: an aggregate that hides a cohort', () {
    gate(
      'GEN-04935-G7',
      'Three cohorts, 320 utterances.',
      'Reported separately, because they do not behave alike',
      () =>
          HabotRecognitionAccuracy.cohorts.length == 3 &&
          HabotRecognitionAccuracy.totalUtterances == 320,
    );

    gate(
      'GEN-04935-G8',
      'The children are one utterance in eight of the evidence.',
      'And the easiest cohort is five times their size',
      () =>
          HabotRecognitionAccuracy.oneUtteranceInEight &&
          HabotRecognitionAccuracy.theEasiestCohortDominates,
    );

    gate(
      'GEN-04935-G9',
      'Dropping them would pass, and they stay.',
      'Which is the trade an aggregate target invites, and Step 447 refused',
      () =>
          HabotRecognitionAccuracy.droppingThemWouldPass &&
          HabotRecognitionAccuracy.theTestSetIsUnchanged &&
          HabotRecognitionAccuracy.refusalNote.contains('Step 447 refused'),
    );

  });

  group('GEN-04935 :: the result', () {
    gate(
      'GEN-04935-G10',
      'Five obligations met, and the row reports Fail.',
      'The gates verify the evidence; the evidence says the row fails',
      () =>
          HabotRecognitionAccuracy.obligations.length == 5 &&
          HabotRecognitionAccuracy.obligations.values.every((bool b) => b) &&
          HabotRecognitionAccuracy.qualitativeOutput == 'Fail',
    );
  });

  tearDownAll(() {
    final double aggregate = HabotRecognitionAccuracy.aggregateAccuracy;
    final double rate = HabotRecognitionAccuracy.passRate;
    final int total = HabotRecognitionAccuracy.totalUtterances;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04935',
        atomicStepReferenceId: 'GEN-04935',
        setupStepAction:
            'COLUMN NOTE: this row\'s completion measure begins with a '
            'backslash where a comparison sign was lost in export, confirming '
            'the defect first seen at Step 447 as a class with two members; '
            'read as at least 95 per cent, the aggregate accuracy of 94.3 '
            'misses while the 168 ms delay is met, so one measure of two gives '
            'a pass rate of 50 against a floor of 95 and the row reports Fail; '
            'and the aggregate itself is refused as a single number, because '
            'the cohort the service exists for is one utterance in eight of '
            'the test set. Atomic Step: "Test the implementation against the '
            'completion measures: \\95% speech recognition accuracy; sub-200ms '
            'real-time text transcription delay."',
        implementationOrder: 462,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Test the implementation against the completion measures: \\95% '
          'speech recognition':
              'two measures run: delay 168 ms against 200, and accuracy '
                  '${aggregate.toStringAsFixed(1)} per cent against at least '
                  '95 across $total utterances; one of two met',
          'Completion Status': 'Fail',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Acceptance / Completion-Measure Test Pass Rate',
            observed:
                'FAIL, AND THE SECOND CONFIRMED LOST GLYPH. The completion '
                'measure reads "\\95% speech recognition accuracy" -- a '
                'backslash where a comparison sign was -- exactly as Step 447 '
                'read "\\30% user response rate" fifteen steps earlier. Read '
                'as at least 95 per cent, the aggregate '
                '${aggregate.toStringAsFixed(1)} misses while the 168 ms delay '
                'is met, so one measure of two gives '
                '${rate.toStringAsFixed(0)} per cent against a floor of 95.',
            floor:
                '>=95% of stated completion measures met (e.g. recovery, '
                    'accuracy, zero-defect targets)',
            optimal:
                '100% of stated completion measures met exactly as specified',
            ceiling:
                '100% (measure is binary pass/fail against the stated target)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Cohorts removed from the test set to reach the number',
            observed:
                '0 of 3. The test set is $total utterances, of which 200 come '
                'from staff whose first language matches the recogniser\'s '
                'training data and 40 from children with speech and language '
                'differences, who score 97.1 and 84.2 per cent. Dropping the '
                'children lifts the aggregate above 95; they stay, accuracy is '
                'reported per cohort, and low-confidence text is marked '
                'unverified rather than stored as something a child said.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/capture/recognition_accuracy.dart',
        ],
      ),
    );
  });
}
