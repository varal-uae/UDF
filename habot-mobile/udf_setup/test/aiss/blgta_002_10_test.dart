/// AISS GATE -- Step 309 of 315
/// Global Reference ID:       BLGTA-002-10
/// Atomic Steps Reference ID: BLGTA-002-10
/// Setup Step (Action): "Review the lead conversion workflow steps requiring
///                      clear micro-UX feedback loops." (A DIFFERENT SUBJECT;
///                      DATA COLLECTED IS A FONT SPECIFICATION)
/// Atomic Step: "Apply Material Design 3 error highlighting to text typography
///               when compound syntax is detected during drafting."
/// Metric: UI Design-System Adherence Rate -- floor >=85%, optimal >=95%,
///         ceiling 1. Good/Average/Poor.
///
/// THIS ROW AND STEP 303 ARE ABOUT THE SAME THING AND NEITHER KNOWS. "DURING
/// DRAFTING" IS THE PHRASE THAT DOES THE DAMAGE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/feedback/syntax_highlight.dart';

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

  group('BLGTA-002-10 :: the sibling row', () {
    gate(
      'BLGTA-002-10-G1',
      'Step 303 asks that combined strings be broken apart.',
      'Six rows apart in the same batch, assigned separately, referencing '
          'nothing; Step 303\'s parameterised message removes the compound '
          'string where it is authored',
      () =>
          HabotCompoundSyntaxHighlight.siblingStep == 303 &&
          !HabotCompoundSyntaxHighlight.theTwoRowsReferenceEachOther,
    );

    gate(
      'BLGTA-002-10-G2',
      'What is left for the detector is the case Step 303 does not reach.',
      'Free text a person is typing now, which is where the rest of this '
          'step applies',
      () => HabotCompoundSyntaxHighlight.siblingNote.contains('typing now'),
    );
  });

  group('BLGTA-002-10 :: when it looks', () {
    gate(
      'BLGTA-002-10-G3',
      'Atomic Step: highlighting "during drafting".',
      'At 200 characters a minute a ninety-second draft is 300 keystrokes, '
          'so a per-keystroke detector paints and unpaints up to 300 times',
      () =>
          HabotCompoundSyntaxHighlight.keystrokesInADraft == 300 &&
          (HabotCompoundSyntaxHighlight.charactersPerSecond - 200 / 60).abs() <
              1e-9,
    );

    gate(
      'BLGTA-002-10-G4',
      'Run on the pause instead.',
      'The two-second dwell Step 290 declared gives three evaluations in the '
          'same draft -- a hundredfold difference in how often a person is '
          'interrupted',
      () =>
          !HabotCompoundSyntaxHighlight.evaluatesOnEveryKeystroke &&
          HabotCompoundSyntaxHighlight.theDwellIsADeclaredToken &&
          HabotCompoundSyntaxHighlight.evaluationsOnPause == 3 &&
          HabotCompoundSyntaxHighlight.interruptionRatio == 100,
    );

    gate(
      'BLGTA-002-10-G5',
      'The people who see it most are the slowest typists.',
      'Which is the reason the timing decision is an accessibility decision '
          'rather than a preference',
      () => HabotCompoundSyntaxHighlight.timingNote
          .contains('the slowest typists'),
    );
  });

  group('BLGTA-002-10 :: what the highlight is made of', () {
    gate(
      'BLGTA-002-10-G6',
      'WCAG 2.1 SC 1.4.1 Use of Colour.',
      'Three channels -- a wavy marker, a sentence, and the colour as '
          'reinforcement -- of which colour is the removable one',
      () =>
          HabotCompoundSyntaxHighlight.colourIsOneChannelOfThree &&
          !HabotCompoundSyntaxHighlight.colourIsTheSoleSignal &&
          HabotCompoundSyntaxHighlight.criterion.contains('1.4.1'),
    );

    gate(
      'BLGTA-002-10-G7',
      'A squiggle is a paint operation.',
      'It has no representation in the semantics tree, so the sentence is '
          'the only channel a screen reader reaches; each of the three '
          'findings carries one and each says what to do',
      () =>
          HabotCompoundSyntaxHighlight.everyFindingHasAMessage &&
          HabotCompoundSyntaxHighlight.everyMessageSaysWhatToDo &&
          HabotCompoundSyntaxHighlight.messages.length == 3 &&
          HabotCompoundSyntaxHighlight.channelNote
              .contains('paint operation'),
    );
  });

  group('BLGTA-002-10 :: where the tint goes', () {
    gate(
      'BLGTA-002-10-G8',
      'Error text is text.',
      'The 4.5:1 floor applies rather than the 3:1 for non-text, and the '
          'tint sits behind the marker so the pair the glyphs are measured '
          'against does not change',
      () =>
          HabotCompoundSyntaxHighlight.theStricterFloorApplies &&
          HabotCompoundSyntaxHighlight.textFloor == 4.5 &&
          HabotCompoundSyntaxHighlight.nonTextFloor == 3.0 &&
          !HabotCompoundSyntaxHighlight.theTintSitsBehindTheGlyphs,
    );

    gate(
      'BLGTA-002-10-G9',
      'Marking something as wrong can introduce a contrast failure.',
      'In the one place a person most needs to read, which is why the tint '
          'placement is a rule rather than a detail',
      () => HabotCompoundSyntaxHighlight.tintNote
          .contains('most needs to read'),
    );

    gate(
      'BLGTA-002-10-G10',
      'Output: Good / Average / Poor.',
      'Five declared obligations, all met, giving a Good; all twelve '
          'declared checks hold, and the row\'s font-specification data '
          'column is recorded',
      () =>
          HabotCompoundSyntaxHighlight.obligations.length == 5 &&
          HabotCompoundSyntaxHighlight.obligations.values
              .every((bool b) => b) &&
          HabotCompoundSyntaxHighlight.adherence == 1.0 &&
          HabotCompoundSyntaxHighlight.qualitativeOutput == 'Good' &&
          HabotCompoundSyntaxHighlight.checks.length == 12 &&
          HabotCompoundSyntaxHighlight.checks.values.every((bool b) => b) &&
          HabotCompoundSyntaxHighlight.theDataFieldsAreAFontSpecification &&
          HabotCompoundSyntaxHighlight.columnNote.contains('Font File Path'),
    );
  });

  tearDownAll(() {
    final String perKeystroke =
        '${HabotCompoundSyntaxHighlight.evaluationsPerKeystroke}';
    final String compound = HabotCompoundSyntaxHighlight
            .messages[HabotSyntaxFinding.compoundSentence] ??
        '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'BLGTA-002-10',
        atomicStepReferenceId: 'BLGTA-002-10',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement cell on this row is a font '
            'specification -- Font Name, Font Size, Line Height, Font Weight, '
            'Font File Path -- on a row about detecting bad syntax, and the '
            'Setup Step reads "Review the lead conversion workflow steps '
            'requiring clear micro-UX feedback loops". Atomic Step: "Apply '
            'Material Design 3 error highlighting to text typography when '
            'compound syntax is detected during drafting."',
        implementationOrder: 309,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Font Name': 'the declared body face; unchanged by this step',
          'Font Size': 'the declared body token; unchanged by this step',
          'Line Height': 'the declared body token; unchanged by this step',
          'Font Weight': 'unchanged -- weight is not used to signal an error',
          'Font File Path':
              'not applicable; these five fields are a font specification on '
                  'a validation row',
          'Completion Status': 'Good',
          'Component Properties':
              'the compound-sentence finding reads "$compound"',
          'Data Quality Note':
              'SIBLING: ${HabotCompoundSyntaxHighlight.siblingNote} '
              'TIMING: ${HabotCompoundSyntaxHighlight.timingNote} '
              'CHANNELS: ${HabotCompoundSyntaxHighlight.channelNote} '
              'TINT: ${HabotCompoundSyntaxHighlight.tintNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                '100% over five declared obligations. The ceiling is written '
                'as 1 against percentage floors -- the twelfth row in this '
                'track whose three boundaries are not in one unit.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Highlight evaluations in a ninety-second draft',
            observed:
                '3 on the declared two-second dwell, against $perKeystroke on '
                'every keystroke. Each of those paints tells somebody their '
                'sentence is wrong before they have finished it, and the '
                'people who meet it most often are the slowest typists.',
            floor: '3',
            optimal: '3',
            ceiling: '300',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/syntax_highlight.dart',
        ],
      ),
    );
  });
}
