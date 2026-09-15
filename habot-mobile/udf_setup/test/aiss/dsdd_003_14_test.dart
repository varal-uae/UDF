/// AISS GATE -- Step 278 of 295
/// Global Reference ID:       DSDD-003-14
/// Atomic Steps Reference ID: DSDD-003-14
/// Setup Step (Action): "Program an automated cloud function trigger that
///                      executes immediately upon any message landing inside
///                      the DLQ." (DIFFERENT SUBJECT)
/// Atomic Step: "Program the 'Common Mistakes' section to render as a
///               collapsible Material 3 accordion."
/// Metric: UI Design-System Adherence Rate -- Floor ">=85%", Optimal ">=95%",
///         Ceiling 1. Good / Average / Poor.
///
/// COLLAPSING THE MISTAKES HIDES THEM FROM EVERYBODY WHO DOES NOT ALREADY
/// SUSPECT THEY MADE ONE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/disclosure/mistakes_section.dart';

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

  group('DSDD-003-14 :: the inversion', () {
    gate(
      'DSDD-003-14-G1',
      'Atomic Step: "render as a collapsible accordion".',
      'The disclosure is two-level: titles stay visible so a reader can scan '
          'for their own situation, and the explanations are what collapses',
      () =>
          HabotMistakesSection.titlesAreAlwaysVisible &&
          HabotMistakesSection.explanationsAreCollapsible &&
          HabotMistakesSection.entries.length == 5,
    );

    gate(
      'DSDD-003-14-G2',
      'Progressive disclosure hides what nobody needs by default.',
      'A list of common mistakes is needed before acting rather than after, '
          'so collapsing it wholesale reaches only the people who already '
          'suspect they made one',
      () => HabotMistakesSection.invertedDisclosureNote
          .contains('helps least'),
    );

    gate(
      'DSDD-003-14-G3',
      'The space saving has to survive the inversion.',
      'Over four fifths of the section\'s text is still in the collapsible '
          'half, measured over the entries rather than asserted',
      () =>
          HabotMistakesSection.collapsingStillSavesMostOfTheSpace &&
          HabotMistakesSection.everyExplanationIsTheLongPart,
    );

    gate(
      'DSDD-003-14-G4',
      'A title nobody can scan is not an index.',
      'Every title is short enough to scan and every entry says what a reader '
          'would have seen that brings them to it',
      () => HabotMistakesSection.everyTitleIsScannable,
    );
  });

  group('DSDD-003-14 :: the component, reused', () {
    gate(
      'DSDD-003-14-G5',
      'One open panel at a time loses the reader\'s place.',
      'Multiple explanations may be open, so somebody comparing two mistakes '
          'can, and the reason is recorded',
      () =>
          HabotMistakesSection.allowsMultipleOpenPanels &&
          HabotMistakesSection.singleOpenNote.contains('loses the reader'),
    );

    gate(
      'DSDD-003-14-G6',
      'The accordion already exists.',
      'The Step 111 latch vocabulary and semantics rule are reused, and the '
          'presentation -- header height, panel padding -- comes from that '
          'component rather than from this file',
      () =>
          HabotMistakesSection.theLatchVocabularyIsReused &&
          HabotMistakesSection.theExistingSemanticRuleApplies &&
          HabotMistakesSection.presentationComesFromTheExistingComponent,
    );

    gate(
      'DSDD-003-14-G7',
      'Metric: UI Design-System Adherence Rate -- 85% / 95% / 1.',
      'Six adherence items, every one of them sourced from a declared token '
          'or an existing component, giving 100% and a Good',
      () =>
          HabotMistakesSection.adherenceItems.length == 6 &&
          HabotMistakesSection.adherenceItems.values.every((bool b) => b) &&
          HabotMistakesSection.adherenceRate == 1.0 &&
          HabotMistakesSection.qualitativeOutput == 'Good',
    );

    gate(
      'DSDD-003-14-G8',
      'The row\'s design notes describe a documentation site.',
      'A web sidebar, an "Ask Expert" chat and a team-facing interface are '
          'recorded as not being this application; all ten declared checks '
          'hold',
      () =>
          HabotMistakesSection.documentationSiteNote.contains('handbook') &&
          HabotMistakesSection.checks.length == 10 &&
          HabotMistakesSection.checks.values.every((bool b) => b) &&
          HabotMistakesSection.columnNote.contains('DLQ'),
    );
  });

  tearDownAll(() {
    final String share =
        (HabotMistakesSection.shareOfTextThatCollapses * 100)
            .toStringAsFixed(1);
    final String entries = '${HabotMistakesSection.entries.length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'DSDD-003-14',
        atomicStepReferenceId: 'DSDD-003-14',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Program an '
            'automated cloud function trigger that executes immediately upon '
            'any message landing inside the DLQ", a different subject '
            'entirely. Atomic Step: "Program the \'Common Mistakes\' section '
            'to render as a collapsible Material 3 accordion."',
        implementationOrder: 278,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotMistakesSection / HabotMistakeEntry',
          'Component Properties':
              '$entries entries with always-visible titles and collapsible '
              'explanations; $share% of the section\'s text is in the '
              'collapsible half; multiple panels may be open; presentation '
              'and latch vocabulary reused from the Step 111 accordion',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotMistakesSection.invertedDisclosureNote} '
              'LATCH: ${HabotMistakesSection.singleOpenNote} '
              'CONTEXT: ${HabotMistakesSection.documentationSiteNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                '100% over ${HabotMistakesSection.adherenceItems.length} '
                'presentational decisions, every one of them read from a '
                'declared token or the existing accordion rather than chosen '
                'in this file.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Share of section text that collapses',
            observed:
                '$share%. The inversion keeps the index visible and still '
                'hides the long part, so the row\'s space saving survives the '
                'change it asks for.',
            floor: 'most of it',
            optimal: 'most of it',
            ceiling: 'most of it',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/disclosure/mistakes_section.dart',
        ],
      ),
    );
  });
}
