/// AISS GATE -- Step 447 of 415
/// Global Reference ID:       GEN-05133
/// Atomic Steps Reference ID: GEN-05133
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Test the implementation against the completion measures: \30%
///               user response rate on triggered feedback prompts; sub-16ms
///               star tap response."
/// Metric: Acceptance / Completion-Measure Test Pass Rate -- floor ">=95% of
///         stated completion measures met (e.g. recovery, accuracy, zero-defect
///         targets)", optimal "100% of stated completion measures met exactly
///         as specified", ceiling "100% (measure is binary pass/fail against
///         the stated target)". Best Qualitative Output: "Pass / Fail".
///         ISO/IEC/IEEE 29119 Software Testing Standard -- acceptance test
///         level. Assigned to **ADFA**.
///
/// A TARGET THAT LOST ITS COMPARISON SIGN IN EXPORT, AND A ROW THAT FAILS ON
/// THE READING THAT MATCHES THE INTENT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/voice/feedback_acceptance.dart';

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

  group('GEN-05133 :: a lost glyph', () {
    gate(
      'GEN-05133-G1',
      'A backslash stands where a comparison sign was.',
      'A new kind of defect: not a wrong value but a lost character',
      () =>
          HabotFeedbackAcceptance.aBackslashStandsWhereASignWas &&
          !HabotFeedbackAcceptance.thisDefectKindWasSeenBefore,
    );

    gate(
      'GEN-05133-G2',
      'And the same defect is on another row.',
      'GEN-04935, still in the pool, so it is systematic',
      () =>
          HabotFeedbackAcceptance.itIsSystematic &&
          HabotFeedbackAcceptance.theOtherRowWithTheSameDefect == 'GEN-04935' &&
          HabotFeedbackAcceptance.glyphNote.contains('lost glyph'),
    );

  });

  group('GEN-05133 :: three readings, one outcome', () {
    gate(
      'GEN-05133-G3',
      'The three readings disagree about the outcome.',
      'At least, at most, or not evaluable at all',
      () =>
          HabotFeedbackAcceptance.theReadingsDisagree &&
          !HabotFeedbackAcceptance.theLiteralReadingCanBeEvaluated,
    );

    gate(
      'GEN-05133-G4',
      'Under the intended reading 27 per cent misses 30.',
      'A response-rate target is a minimum',
      () =>
          !HabotFeedbackAcceptance.passesAsAtLeast &&
          HabotFeedbackAcceptance.readingNote.contains('restored'),
    );

    gate(
      'GEN-05133-G5',
      'The tap measure is met at 9 ms.',
      'Under the 16 ms target',
      () =>
          HabotFeedbackAcceptance
              .observedTapMs < HabotFeedbackAcceptance.tapTargetMs &&
          HabotFeedbackAcceptance.oneOfTwoIsMet,
    );

    gate(
      'GEN-05133-G6',
      'One of two measures is met, which misses the 95 per cent floor.',
      'A pass rate of 50 per cent',
      () =>
          HabotFeedbackAcceptance.passRate == 50 &&
          HabotFeedbackAcceptance.theFloorIsMissed,
    );

  });

  group('GEN-05133 :: the fix is not to prompt more', () {
    gate(
      'GEN-05133-G7',
      'The cap stays and refusals still never prompt.',
      'Step 446\'s rules are not relaxed to hit the target',
      () =>
          HabotFeedbackAcceptance.theWeeklyCapStays &&
          HabotFeedbackAcceptance.theNoPromptAfterRefusalStays,
    );

    gate(
      'GEN-05133-G8',
      'Because prompting more would make the prompts worse.',
      'Which is the trade a response-rate target invites',
      () => HabotFeedbackAcceptance.fixNote.contains('the cap stays'),
    );

  });

  group('GEN-05133 :: stars and a slider', () {
    gate(
      'GEN-05133-G9',
      'The measure assumes stars and the control is a slider.',
      'Two rows in four design one control two ways',
      () =>
          HabotFeedbackAcceptance.twoRowsDesignOneControlTwoWays &&
          HabotFeedbackAcceptance.theCeilingExplainsItself,
    );

    gate(
      'GEN-05133-G10',
      'Five obligations met, and the row reports Fail.',
      'The gates verify the evidence; the evidence says the row fails',
      () =>
          HabotFeedbackAcceptance.obligations.length == 5 &&
          HabotFeedbackAcceptance.obligations.values.every((bool b) => b) &&
          HabotFeedbackAcceptance.qualitativeOutput == 'Fail',
    );
  });

  tearDownAll(() {
    final double response = HabotFeedbackAcceptance.observedResponsePercent;
    final double passRate = HabotFeedbackAcceptance.passRate;
    final int tapMs = HabotFeedbackAcceptance.observedTapMs;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05133',
        atomicStepReferenceId: 'GEN-05133',
        setupStepAction:
            'COLUMN NOTE: this row\'s completion measure reads "\\30% user '
            'response rate", with a backslash where a comparison sign was lost '
            'in export -- the same defect sits on GEN-04935 -- and the outcome '
            'depends on the missing character: read as at least 30% the '
            'observed 27% fails, read as at most 30% it passes; the intended '
            'reading is used and the row reports Fail; the measure says "star '
            'tap" while Step 444 built a slider; its floor and optimal are '
            'sentences and its ceiling reads "100% (measure is binary '
            'pass/fail against the stated target)", the eighth annotated '
            'boundary. Atomic Step: "Test the implementation against the '
            'completion measures: \\30% user response rate on triggered '
            'feedback prompts; sub-16ms star tap response."',
        implementationOrder: 447,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Test the implementation against the completion measures: \\30% user '
          'response':
              'two measures run: response rate ${response.toStringAsFixed(0)} '
                  'per cent against at least 30, and tap response $tapMs ms '
                  'against 16; one of two met',
          'Completion Status': 'Fail',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Acceptance / Completion-Measure Test Pass Rate',
            observed:
                'FAIL. The completion measure reads "\\30% user response '
                'rate": a backslash where a comparison sign was lost in '
                'export, and the same defect sits on GEN-04935. Read as at '
                'least 30 per cent -- the only sensible reading of a '
                'response-rate target -- the observed '
                '${response.toStringAsFixed(0)} per cent misses it; read as at '
                'most 30 it would pass. The tap measure is met at $tapMs ms. '
                'One of two measures met gives ${passRate.toStringAsFixed(0)} '
                'per cent against a floor of 95. The ceiling reads "100% '
                '(measure is binary pass/fail against the stated target)", the '
                'eighth annotated boundary.',
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
            metricName: 'Prompting rules relaxed to reach the target',
            observed:
                '0. Removing Step 446\'s weekly cap, or prompting after '
                'refusals, would lift the response rate over 30 per cent and '
                'make the prompts worse, which is the trade a response-rate '
                'target invites. The shortfall is reported and the rules stay. '
                'The measure also says "star tap" while Step 444 built a '
                'slider -- two rows designing one control two ways.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/voice/feedback_acceptance.dart',
        ],
      ),
    );
  });
}
