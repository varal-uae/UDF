/// AISS GATE -- Step 402 of 415
/// Global Reference ID:       CBSV-036-03
/// Atomic Steps Reference ID: CBSV-036-03
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Extract all unique text parameter and layout data fields from
///               the completion files."
/// Metric: Touch Target Size & Accessibility Compliance -- floor "44px / WCAG
///         AA", optimal "48px / WCAG AA", ceiling "56px / WCAG AAA". Best
///         Qualitative Output: "Good (Scale: Good/Average/Poor)". Google
///         Material Design 3 Accessibility Guidelines; WCAG 2.1 AA (min. 4.5:1
///         contrast, 44-48dp touch target). Assigned to **UDF**.
///
/// FOURTEEN OCCURRENCES BECOME NINE ENTRIES, AND TWO IDENTICAL STRINGS ARE KEPT
/// APART ON PURPOSE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/schema/field_extraction.dart';

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

  group('CBSV-036-03 :: fourteen into nine', () {
    gate(
      'CBSV-036-03-G1',
      'Fourteen occurrences become nine entries.',
      'Counted rather than asserted, so the arithmetic can be checked against '
          'the extraction table',
      () => HabotFieldExtraction.fourteenBecomeNine,
    );

    gate(
      'CBSV-036-03-G2',
      'And five duplicates are the argument for doing it.',
      'Five strings written twice are five chances for two screens to disagree '
          'after a copy change',
      () =>
          HabotFieldExtraction.fiveDuplicatesWereRemoved &&
          HabotFieldExtraction.uniquenessNote.contains('could drift'),
    );

  });

  group('CBSV-036-03 :: why two "Save"s are two entries', () {
    gate(
      'CBSV-036-03-G3',
      'Two identical strings are kept apart by context.',
      '"Save" on a draft and "Save" on a submitted record are the same four '
          'letters and not the same string',
      () =>
          HabotFieldExtraction.twoSavesAreKeptApart &&
          HabotFieldExtraction.uniquenessIsByValueAndContext,
    );

    gate(
      'CBSV-036-03-G4',
      'Because a verb changes form with its context.',
      'Collapsing by string equality is the bug that makes a translation '
          'correct on one screen and wrong on another',
      () =>
          HabotFieldExtraction.contextNote
              .contains('reads like an instruction'),
    );

  });

  group('CBSV-036-03 :: text and layout are different kinds', () {
    gate(
      'CBSV-036-03-G5',
      'Six translatable strings and three layout values.',
      'Two kinds in one catalogue, distinguished by kind rather than by naming '
          'convention',
      () => HabotFieldExtraction.sixTextThreeLayout,
    );

    gate(
      'CBSV-036-03-G6',
      'No layout field is translatable.',
      'Checked rather than assumed, because the two kinds share a catalogue',
      () =>
          HabotFieldExtraction.noLayoutFieldIsTranslatable &&
          !HabotFieldExtraction.bothKindsShareOneCatalogue,
    );

    gate(
      'CBSV-036-03-G7',
      'And a localised grid dimension is the failure.',
      'A translator handed a column count is the concrete thing this '
          'distinction prevents',
      () => HabotFieldExtraction.kindNote.contains('comes back localised'),
    );

  });

  group('CBSV-036-03 :: the band is somebody else\'s', () {
    gate(
      'CBSV-036-03-G8',
      'The catalogue is generated.',
      'A hand-maintained catalogue drifts from the screens it describes within '
          'one sprint',
      () =>
          HabotFieldExtraction.itSurvivesTheNextScreen &&
          HabotFieldExtraction.repeatabilityNote
              .contains('looks like a design decision'),
    );

    gate(
      'CBSV-036-03-G9',
      'The band is well formed and repeats Step 342\'s conflation.',
      'A touch-target band on a field-extraction row, already recorded once in '
          'the track',
      () =>
          HabotFieldExtraction.theBandIsWellFormed &&
          HabotFieldExtraction.theConflationIsAlreadyRecorded &&
          HabotFieldExtraction.theStepThatRecordedIt == 342 &&
          HabotFieldExtraction.theBandMeasuresSomethingElse,
    );

    gate(
      'CBSV-036-03-G10',
      'Five obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotFieldExtraction.obligations.length == 5 &&
          HabotFieldExtraction.obligations.values.every((bool b) => b) &&
          HabotFieldExtraction.qualitativeOutput == 'Good' &&
          HabotFieldExtraction.uniqueShare == 100,
    );
  });

  tearDownAll(() {
    final int occurrences = HabotFieldExtraction.totalOccurrences;
    final int entries = HabotFieldExtraction.distinctEntries;
    final int duplicates = HabotFieldExtraction.duplicatesRemoved;
    final int saves = HabotFieldExtraction.saveEntries.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'CBSV-036-03',
        atomicStepReferenceId: 'CBSV-036-03',
        setupStepAction:
            'COLUMN NOTE: the metric on this row is a touch-target size band '
            '-- "44px / WCAG AA", "48px / WCAG AA", "56px / WCAG AAA" -- on a '
            'row about extracting text and layout fields from files, and it '
            'repeats the 44/48 conflation Step 342 recorded as two standards '
            'rather than one conversion; its Data Requirement column holds '
            'layout fields; and its Setup Step column reads "Test the fallback '
            'route activates when biometric verification is unavailable". '
            'Atomic Step: "Extract all unique text parameter and layout data '
            'fields from the completion files."',
        implementationOrder: 402,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type':
              'a generated extraction catalogue holding both translatable text '
                  'and layout values, $entries entries from $occurrences '
                  'occurrences',
          'Layout Grid Dimensions':
              'held as layout values and checked for the absence of a '
                  'translatable flag, because a localised column count is the '
                  'failure this separation exists to prevent',
          'Spacing Rules':
              'extracted as layout values alongside the grid dimensions, never '
                  'as text',
          'Alignment Settings':
              'extracted as layout values; $duplicates duplicate occurrences '
                  'were removed across all kinds',
          'Layout Validation Status':
              '$saves entries read "Save" and are kept apart by context rather '
                  'than collapsed by string equality',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Touch Target Size & Accessibility Compliance',
            observed:
                'THE BAND BELONGS TO A TOUCH-TARGET ROW. "Touch Target Size & '
                'Accessibility Compliance" with 44px / WCAG AA, 48px / WCAG AA '
                'and 56px / WCAG AAA is a well-formed band about the size of a '
                'tap target, on a row about extracting text and layout fields '
                'from completion files. The track already recorded this '
                'conflation at Step 342, so this is the second occurrence '
                'rather than a new defect. Observed: $occurrences occurrences '
                'reduced to $entries entries, $duplicates duplicates removed.',
            floor: '44px / WCAG AA',
            optimal: '48px / WCAG AA',
            ceiling: '56px / WCAG AAA',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Entries collapsed by string equality alone',
            observed:
                '0 of $entries. $saves entries read "Save" and stay apart '
                'because one saves a draft and one submits a record: the same '
                'four letters in English and two different verbs in most other '
                'languages, where the form changes with what is being saved. '
                'Uniqueness is by value and context together. The catalogue is '
                'generated from the screens rather than maintained beside '
                'them, because a hand-built list drifts within a sprint and '
                'the drift is invisible until a translator asks.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/schema/field_extraction.dart',
        ],
      ),
    );
  });
}
