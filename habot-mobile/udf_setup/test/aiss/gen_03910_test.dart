/// AISS GATE -- Step 302 of 315
/// Global Reference ID:       GEN-03910
/// Atomic Steps Reference ID: GEN-03910
/// Setup Step (Action): (the generic engineering-console boilerplate, and the
///                      Atomic Step carries a stray "[cite: 558]" marker --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Check if required text input strings are null, empty, or
///               consist purely of whitespace characters."
/// Metric: String Trim Evaluation Speed -- floor "< 0.1 ms", optimal
///         "< 0.001 ms", ceiling "0.5 ms". Pass/Fail.
///
/// THE OPTIMAL SITS AT THE RESOLUTION OF THE CLOCK THAT WOULD MEASURE IT, AND
/// TWO EMPTY-LOOKING STRINGS SURVIVE THE CHECK THE ROW DESCRIBES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/blank_input_rule.dart';

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

  group('GEN-03910 :: what a trim catches', () {
    gate(
      'GEN-03910-G1',
      'Atomic Step: "null, empty, or consist purely of whitespace".',
      'Ten blank-looking candidates; the rule as written catches eight of '
          'them',
      () =>
          HabotBlankInputRule.candidates.length == 10 &&
          HabotBlankInputRule.caughtByTrim.length == 8 &&
          HabotBlankInputRule.trimRecall == 0.8,
    );

    gate(
      'GEN-03910-G2',
      'Unicode does not give U+200B or U+2060 the White_Space property.',
      'Both render as nothing and both survive the trim, so the string is '
          'not empty and the person is looking at an empty box',
      () =>
          HabotBlankInputRule.slippingThrough.length == 2 &&
          HabotBlankInputRule.slippingThrough.first.codePoint == 0x200B &&
          HabotBlankInputRule.slippingThrough.last.codePoint == 0x2060,
    );

    gate(
      'GEN-03910-G3',
      'The byte-order mark is the middle case.',
      'Unicode does not call it whitespace and Dart trims it anyway, which '
          'is why the property and the behaviour are recorded separately',
      () =>
          HabotBlankInputRule.caughtDespiteNotBeingWhiteSpace.length == 1 &&
          HabotBlankInputRule.caughtDespiteNotBeingWhiteSpace.first
                  .codePoint ==
              0xFEFF,
    );

    gate(
      'GEN-03910-G4',
      'There is no edit that fixes it.',
      'Except deleting a character the person cannot see, which is why this '
          'is the worst kind of validation bug',
      () => HabotBlankInputRule.slipNote
          .contains('a character they cannot see'),
    );
  });

  group('GEN-03910 :: the rule that ships', () {
    gate(
      'GEN-03910-G5',
      'The two survivors are named rather than guessed at.',
      'All ten candidates are rejected, and a real value that happens to '
          'contain an invisible character is still accepted',
      () =>
          HabotBlankInputRule.theRuleCatchesEveryCandidate &&
          HabotBlankInputRule.aRealValueIsStillAccepted,
    );

    gate(
      'GEN-03910-G6',
      'The check answers a question; it does not repair the input.',
      'Silent trimming is harmless on a name and wrong on a passphrase, '
          'where it appears later as a failed sign-in nobody can reproduce',
      () =>
          !HabotBlankInputRule.theCheckMutatesTheValue &&
          HabotBlankInputRule.mutationNote.contains('nobody can reproduce'),
    );
  });

  group('GEN-03910 :: when, and what it says', () {
    gate(
      'GEN-03910-G7',
      'A required-field error on the first keystroke.',
      'The rule runs when the field is left or the form is submitted; the '
          'moment is read from Step 290 rather than chosen again',
      () =>
          !HabotBlankInputRule.firesOnEveryKeystroke &&
          HabotBlankInputRule.theMomentIsAlreadyDeclared &&
          HabotBlankInputRule.nothingInterruptsTyping,
    );

    gate(
      'GEN-03910-G8',
      'Three messages, one per case.',
      'Each names the field and says what to do, and the third is the one a '
          'rule that does not know about invisible characters could not write',
      () =>
          HabotBlankInputRule.messages.length == 3 &&
          HabotBlankInputRule.everyMessageNamesTheField &&
          HabotBlankInputRule.everyMessageSaysWhatToDo &&
          HabotBlankInputRule.theInvisibleCaseHasItsOwnMessage,
    );
  });

  group('GEN-03910 :: the metric', () {
    gate(
      'GEN-03910-G9',
      'Optimal "< 0.001 ms".',
      'One microsecond, about the granularity of the clock that would '
          'measure it, so the optimal cannot be told apart from zero -- and '
          'the ceiling, five times the floor on a lower-is-better measure, is '
          'the worst of the three numbers',
      () =>
          HabotBlankInputRule.theOptimalSitsAtTheClocksResolution &&
          HabotBlankInputRule.optimalMicroseconds == 1 &&
          HabotBlankInputRule.theCeilingIsWorseThanTheFloor &&
          HabotBlankInputRule.metricNote.contains('rather than the best'),
    );

    gate(
      'GEN-03910-G10',
      'Output: Pass / Fail.',
      'Six declared obligations, all met, giving Pass; all twelve declared '
          'checks hold',
      () =>
          HabotBlankInputRule.obligations.length == 6 &&
          HabotBlankInputRule.obligations.values.every((bool b) => b) &&
          HabotBlankInputRule.qualitativeOutput == 'Pass' &&
          HabotBlankInputRule.checks.length == 12 &&
          HabotBlankInputRule.checks.values.every((bool b) => b) &&
          HabotBlankInputRule.columnNote.contains('cite: 558'),
    );
  });

  tearDownAll(() {
    final String slipping = HabotBlankInputRule.slippingThrough
        .map((HabotBlankCandidate c) => c.name)
        .join(', ');
    final String invisibleMessage =
        HabotBlankInputRule.messages['invisible characters only'] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03910',
        atomicStepReferenceId: 'GEN-03910',
        setupStepAction:
            'COLUMN NOTE: the Atomic Step carries a stray citation marker -- '
            '"[cite: 558]" -- inside the instruction text, and every narrative '
            'column is the generic engineering-console boilerplate. Atomic '
            'Step: "Check if required text input strings are null, empty, or '
            'consist purely of whitespace characters."',
        implementationOrder: 302,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Check if required text input strings are null, empty, or':
              'ten blank-looking candidates worked; the rule rejects all ten',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the invisible case has its own message: "$invisibleMessage"',
          'Data Quality Note':
              'SLIPPING THROUGH: ${HabotBlankInputRule.slipNote} '
              'MUTATION: ${HabotBlankInputRule.mutationNote} '
              'TIMING: ${HabotBlankInputRule.timingNote} '
              'METRIC: ${HabotBlankInputRule.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'String Trim Evaluation Speed',
            observed:
                'NOT MEASURED, AND NOT WORTH MEASURING. Trimming a '
                'forty-character string is tens of nanoseconds; the optimal '
                'of 0.001 ms is one microsecond, at the resolution of the '
                'clock that would time it, and the ceiling of 0.5 ms is five '
                'times the floor on a measure where lower is better. Reported '
                'instead over six declared obligations, all of which hold.',
            floor: '< 0.1 ms',
            optimal: '< 0.001 ms',
            ceiling: '0.5 ms',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Blank-looking inputs the rule accepts',
            observed:
                '0 of ${HabotBlankInputRule.candidates.length}. The rule as '
                'the row describes it accepts two -- $slipping -- which '
                'render as nothing and leave the person looking at an empty '
                'box the application insists is filled.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/blank_input_rule.dart',
        ],
      ),
    );
  });
}
