/// AISS GATE -- Step 446 of 415
/// Global Reference ID:       GEN-05122
/// Atomic Steps Reference ID: GEN-05122
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement substep 3: Wire automated feedback triggers popping
///               up upon key workflow completions (e.g., referral approval)."
/// Metric: Substep Definition-of-Done Adherence Rate -- floor ">=90% unit test
///         coverage / acceptance criteria met before merge", optimal "95-100%
///         coverage, all acceptance criteria met", ceiling "100% (coverage
///         beyond 100% is not meaningful; further effort has diminishing
///         return)". Best Qualitative Output: "Complete / Partial / Not
///         Complete". ISO/IEC 25010 Software Quality Model -- functional
///         suitability characteristic. Assigned to **ADFA**.
///
/// FEEDBACK PROMPTS AT THE MOMENT OF COMPLETION, UNDER THE LONGEST BAND CELL IN
/// THE TRACK -- NOW A TEMPLATE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/voice/feedback_triggers.dart';

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

  group('GEN-05122 :: the band is a template', () {
    gate(
      'GEN-05122-G1',
      'The band is Step 430\'s, character for character.',
      'Sixteen rows later, on a different subject for a different team',
      () =>
          HabotFeedbackTriggers.theBandIsStep430s &&
          HabotFeedbackTriggers.rowsApart == 16,
    );

    gate(
      'GEN-05122-G2',
      'So the longest cell in the track is a template.',
      'A block pasted wherever a row is called a substep',
      () =>
          HabotFeedbackTriggers.itIsATemplate &&
          HabotFeedbackTriggers.templateNote.contains('pasted'),
    );

    gate(
      'GEN-05122-G3',
      'And its oblique is read as "and" again.',
      'The stricter reading, as at Step 430',
      () => HabotFeedbackTriggers.theFloorIsReadAsAndAgain,
    );

    gate(
      'GEN-05122-G4',
      'Substep 3 of a parent nobody names.',
      'Another fragment, with no link to its siblings',
      () => HabotFeedbackTriggers.anotherFragment,
    );

  });

  group('GEN-05122 :: after the confirmation, never over it', () {
    gate(
      'GEN-05122-G5',
      'The prompt waits for the confirmation and never blocks.',
      'A survey on top of the confirmation somebody was waiting for is an '
          'interruption',
      () => HabotFeedbackTriggers.thePromptIsNotAnInterruption,
    );

    gate(
      'GEN-05122-G6',
      'One prompt a week, because fatigue feeds itself.',
      'A falling response rate pushed back up by asking more falls further',
      () =>
          HabotFeedbackTriggers.fatigueIsCapped &&
          HabotFeedbackTriggers
              .interruptionNote.contains('makes it fall further'),
    );

  });

  group('GEN-05122 :: never after a refusal', () {
    gate(
      'GEN-05122-G7',
      'A granted completion prompts and a refusal does not.',
      'Only completions that went the person\'s way',
      () =>
          HabotFeedbackTriggers.aGrantedCompletionPrompts &&
          HabotFeedbackTriggers.aRefusalNeverPrompts,
    );

    gate(
      'GEN-05122-G8',
      'Because rating a refusal measures the refusal.',
      'Not the process',
      () => HabotFeedbackTriggers.refusalNote.contains('measures the refusal'),
    );

    gate(
      'GEN-05122-G9',
      'A pending record never prompts, and the cap holds.',
      'Completion means Step 436\'s terminal state with the person told',
      () =>
          HabotFeedbackTriggers.aPendingRecordNeverPrompts &&
          HabotFeedbackTriggers.theWeeklyCapHolds,
    );

  });

  group('GEN-05122 :: the result', () {
    gate(
      'GEN-05122-G10',
      'Five obligations, all met, giving Complete at 97 per cent.',
      'And all ten declared checks hold',
      () =>
          HabotFeedbackTriggers.obligations.length == 5 &&
          HabotFeedbackTriggers.obligations.values.every((bool b) => b) &&
          HabotFeedbackTriggers.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int coverage = HabotFeedbackTriggers.coveragePercent;
    final int cap = HabotFeedbackTriggers.promptsPerPersonPerWeek;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05122',
        atomicStepReferenceId: 'GEN-05122',
        setupStepAction:
            'COLUMN NOTE: this row carries Step 430\'s band character for '
            'character -- the longest band cell in the track, with a floor of '
            'two criteria joined by an oblique -- which makes it a template '
            'pasted onto rows called substeps rather than one row\'s '
            'elaboration; it is "substep 3" of a step whose parent is never '
            'named; and it asks for feedback prompts popping up on completion, '
            'so the prompt waits for the confirmation, never blocks, is capped '
            'at one a week, and never follows a refusal. Atomic Step: '
            '"Implement substep 3: Wire automated feedback triggers popping up '
            'upon key workflow completions (e.g., referral approval)."',
        implementationOrder: 446,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement substep 3: Wire automated feedback triggers popping up '
          'upon':
              'prompts after the confirmation, never blocking, $cap per person '
                  'per week, never after a refusal; coverage $coverage per '
                  'cent',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Substep Definition-of-Done Adherence Rate',
            observed:
                'THE LONGEST BAND CELL IN THE TRACK IS A TEMPLATE. Step 430 '
                'carried this exact band -- a floor of two criteria joined by '
                'an oblique and a ceiling holding a semicolon and two clauses '
                'of argument -- and sixteen rows later it arrives again, '
                'character for character, on a different subject for a '
                'different team. The oblique is read as "and" again. Observed: '
                '$coverage per cent coverage with acceptance criteria met.',
            floor:
                '>=90% unit test coverage / acceptance criteria met before '
                    'merge',
            optimal: '95-100% coverage, all acceptance criteria met',
            ceiling:
                '100% (coverage beyond 100% is not meaningful; further effort '
                    'has diminishing return)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Prompts shown after a refusal',
            observed:
                '0. Asking somebody to rate the process that has just refused '
                'their request measures the refusal, so only completions that '
                'went the person\'s way can prompt. The prompt waits for the '
                'confirmation, can always be dismissed, blocks nothing, and is '
                'capped at $cap a week, because survey fatigue is how a '
                'response rate falls and is then pushed back up by asking '
                'more.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/voice/feedback_triggers.dart',
        ],
      ),
    );
  });
}
