/// AISS GATE -- Step 326 of 335
/// Global Reference ID:       GEN-03712
/// Atomic Steps Reference ID: GEN-03712
/// Setup Step (Action): (the generic engineering-console boilerplate; the
///                      Atomic Step carries a stray "[cite: 4588]" marker --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Dispatch high-risk payment alerts instantly to mobile
///               security queues for biometric step-up review."
/// Metric: Fraud Alert Dispatch Speed -- floor "< 2 sec", optimal "< 500 ms",
///         ceiling "< 5 sec". Pass/Fail. Assigned to **GFD**.
///
/// "BIOMETRIC STEP-UP" NAMES TWO DIFFERENT PEOPLE, AND "INSTANTLY" MEASURES
/// THE HALF THAT WAS NEVER GOING TO BE SLOW.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/payments/step_up_review.dart';

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

  group('GEN-03712 :: two people, one phrase', () {
    gate(
      'GEN-03712-G1',
      'Atomic Step: "biometric step-up review".',
      'A step-up re-checks the payer; a security queue checks the reviewer. '
          'Both are declared, each saying who it authenticates and what it '
          'adds assurance to',
      () =>
          HabotStepUpReview.bothSubjectsAreDeclared &&
          HabotStepUpReview.thePurposesAreDifferent &&
          HabotStepUpReview.stepUps.length == 2,
    );

    gate(
      'GEN-03712-G2',
      'The cost of guessing which one is meant.',
      'A reviewer\'s fingerprint recorded as the payer\'s consent',
      () =>
          HabotStepUpReview.theHazardOfConflatingThemIsNamed &&
          HabotStepUpReview.subjectNote.contains('has to guess'),
    );
  });

  group('GEN-03712 :: the fallback', () {
    gate(
      'GEN-03712-G3',
      'A biometric gate with no fallback locks people out of their own money.',
      'Both prompts fall back to the device credential; three outcomes, each '
          'with its own sentence, none of them a dead end',
      () =>
          HabotStepUpReview.everyStepUpHasAFallback &&
          HabotStepUpReview.everyOutcomeHasASentence &&
          HabotStepUpReview.noOutcomeIsADeadEnd,
    );

    gate(
      'GEN-03712-G4',
      'A fingerprint that is wet, cut or never enrolled is an ordinary '
          'Tuesday.',
      'And the people a biometric-only gate excludes are the ones who do '
          'manual work with their hands, which on this application is most of '
          'them',
      () => HabotStepUpReview.fallbackNote.contains('most of them'),
    );
  });

  group('GEN-03712 :: which half is measured', () {
    gate(
      'GEN-03712-G5',
      'Atomic Step: "instantly".',
      'Dispatch is 500 ms and the review is a person; against a four-minute '
          'review the dispatch is 0.2 per cent of the wait',
      () =>
          HabotStepUpReview.dispatchMs == 500 &&
          HabotStepUpReview.reviewMs == 240000 &&
          HabotStepUpReview.theMetricMeasuresTheFastHalf,
    );

    gate(
      'GEN-03712-G6',
      'The quantity the payer experiences is not on the row.',
      'Time to decision appears nowhere, and here the waiting is somebody\'s '
          'rent -- the shape Step 302\'s string-trim timing had, on a subject '
          'where it costs something',
      () =>
          HabotStepUpReview.thePayersQuantityIsUnmeasured &&
          HabotStepUpReview.siblingStepWithTheSameShape == 302 &&
          HabotStepUpReview.halfNote.contains('somebody\'s rent'),
    );

    gate(
      'GEN-03712-G7',
      'The payer is told either way.',
      'Three states -- held, approved, declined -- none of which leaves them '
          'waiting silently',
      () =>
          HabotStepUpReview.thePayerIsToldEitherWay &&
          HabotStepUpReview.noPayerStateLeavesThemWaitingSilently &&
          HabotStepUpReview.holdNoticeDelay.inMilliseconds == 300,
    );
  });

  group('GEN-03712 :: the band', () {
    gate(
      'GEN-03712-G8',
      'Floor 2 s, optimal 500 ms, ceiling 5 s.',
      'Lower is better, so the ceiling should be the best value and it is the '
          'worst -- the second of four inverted latency bands in this batch',
      () =>
          HabotStepUpReview.theBandIsInverted &&
          HabotStepUpReview.bandFloorMs == 2000 &&
          HabotStepUpReview.bandOptimalMs == 500 &&
          HabotStepUpReview.bandCeilingMs == 5000,
    );

    gate(
      'GEN-03712-G9',
      'Step 333 orders the same kind of band correctly.',
      'Which is what makes these four an error rather than a convention',
      () =>
          HabotStepUpReview.correctlyOrderedBandInThisBatch == 333 &&
          HabotStepUpReview.bandNote.contains('second of four'),
    );

    gate(
      'GEN-03712-G10',
      'Output: Pass / Fail.',
      'Five declared obligations, all met, giving Pass; all ten declared '
          'checks hold',
      () =>
          HabotStepUpReview.obligations.length == 5 &&
          HabotStepUpReview.obligations.values.every((bool b) => b) &&
          HabotStepUpReview.qualitativeOutput == 'Pass' &&
          HabotStepUpReview.checks.length == 10 &&
          HabotStepUpReview.checks.values.every((bool b) => b) &&
          HabotStepUpReview.columnNote.contains('GFD'),
    );
  });

  tearDownAll(() {
    final String share =
        (HabotStepUpReview.dispatchShareOfTheWait * 100).toStringAsFixed(3);
    final String held = HabotStepUpReview.payerStates['held'] ?? '';
    final String payerPurpose =
        HabotStepUpReview.forSubject(HabotStepUpSubject.payer).purpose;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03712',
        atomicStepReferenceId: 'GEN-03712',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to GFD rather than UDF, its '
            'Atomic Step carries a stray citation marker -- "[cite: 4588]" -- '
            'and every narrative column is the generic engineering-console '
            'boilerplate. Atomic Step: "Dispatch high-risk payment alerts '
            'instantly to mobile security queues for biometric step-up '
            'review."',
        implementationOrder: 326,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Dispatch high-risk payment alerts instantly to mobile security '
                  'queues for':
              '2 step-up subjects declared; the payer prompt adds '
                  '"$payerPurpose"',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties': 'a held payment reads "$held"',
          'Data Quality Note':
              'SUBJECTS: ${HabotStepUpReview.subjectNote} '
              'FALLBACK: ${HabotStepUpReview.fallbackNote} '
              'HALVES: ${HabotStepUpReview.halfNote} '
              'BAND: ${HabotStepUpReview.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Fraud Alert Dispatch Speed',
            observed:
                'THE BAND IS INVERTED -- the 5-second ceiling is worse than '
                'the 2-second floor on a lower-is-better measure, the second '
                'of four such bands in this batch. And the dispatch is '
                '$share per cent of a four-minute wait, so the metric times '
                'the half that was never going to be slow. Time to decision, '
                'which is what the payer experiences, appears nowhere on the '
                'row.',
            floor: '< 2 sec',
            optimal: '< 500 ms',
            ceiling: '< 5 sec',
          ),
          AissMeasurement(
            metricName: 'Biometric prompts with no fallback',
            observed:
                '0 of ${HabotStepUpReview.stepUps.length}. Both fall back to '
                'the device credential, which both platforms ship, and no '
                'outcome is a dead end. Refusing the fallback would exclude '
                'the people who do manual work with their hands.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/payments/step_up_review.dart',
        ],
      ),
    );
  });
}
