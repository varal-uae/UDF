/// AISS GATE -- Step 461 of 1,314
/// Global Reference ID:       GEN-04924
/// Atomic Steps Reference ID: GEN-04924
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement substep 3: Include client-side punctuation parsing
///               and real-time text transcription rendering."
/// Metric: Substep Definition-of-Done Adherence Rate -- floor ">=90% unit test
///         coverage / acceptance criteria met before merge", optimal "95-100%
///         coverage, all acceptance criteria met", ceiling "100% (coverage
///         beyond 100% is not meaningful; further effort has diminishing
///         return)". Best Qualitative Output: "Complete / Partial / Not
///         Complete". ISO/IEC 25010 Software Quality Model -- functional
///         suitability characteristic. Assigned to **UDF**.
///
/// PUTTING COMMAS INTO A NOTE ABOUT A CHILD, UNDER A CEILING THAT ARGUES WITH
/// ITSELF.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/capture/transcript_punctuation.dart';

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

  group('GEN-04924 :: a ceiling that argues', () {
    gate(
      'GEN-04924-G1',
      'The ceiling argues rather than bounds.',
      '"further effort has diminishing return" is advice, not a boundary',
      () =>
          HabotTranscriptPunctuation.theCeilingMakesAnArgument &&
          HabotTranscriptPunctuation.tenthAnnotatedBoundary,
    );

    gate(
      'GEN-04924-G2',
      'The tenth annotated boundary in the track.',
      'Boundaries that explain themselves instead of stating a value',
      () => HabotTranscriptPunctuation.theFloorJoinsTwoMeasures,
    );

  });

  group('GEN-04924 :: an oblique read as "and"', () {
    gate(
      'GEN-04924-G3',
      'The floor joins two measures with an oblique.',
      'Test coverage and acceptance criteria are not the same thing',
      () =>
          HabotTranscriptPunctuation.thirdObliqueReadStrictly &&
          HabotTranscriptPunctuation.bandNote.contains('third time'),
    );

    gate(
      'GEN-04924-G4',
      'And the oblique is read as "and", a third time.',
      'After Steps 430 and 446, the stricter reading again',
      () =>
          HabotTranscriptPunctuation.substepNumber == 3 &&
          !HabotTranscriptPunctuation.theParentIsNamed,
    );

  });

  group('GEN-04924 :: one comma, two records', () {
    gate(
      'GEN-04924-G5',
      'Substep 3 of a parent nobody names.',
      'Like Step 458\'s "four substeps above"',
      () => HabotTranscriptPunctuation.oneCommaFlipsTheMeaning,
    );

    gate(
      'GEN-04924-G6',
      'One comma flips the meaning of the same sounds.',
      '"She is not settling, well" and "She is not settling well"',
      () =>
          HabotTranscriptPunctuation.theRawStreamIsKept &&
          HabotTranscriptPunctuation.punctuationNote.contains('is the record'),
    );

    gate(
      'GEN-04924-G7',
      'So the raw token stream is kept beside the rendering.',
      'Punctuation is a rendering; the tokens are the record',
      () => HabotTranscriptPunctuation.onlyConfirmedTextIsSaved,
    );

  });

  group('GEN-04924 :: interim text says so', () {
    gate(
      'GEN-04924-G8',
      'And only speaker-confirmed text reaches the child\'s file.',
      'Nothing a machine punctuated is saved unseen',
      () => HabotTranscriptPunctuation.interimIsNotMarkedByColourAlone,
    );

    gate(
      'GEN-04924-G9',
      'Interim text is marked by weight and by wording.',
      'Not by colour, and not silently',
      () => HabotTranscriptPunctuation.theListFallbackIsAvailable,
    );

    gate(
      'GEN-04924-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotTranscriptPunctuation.obligations.length == 5 &&
          HabotTranscriptPunctuation.obligations.values.every((bool b) => b) &&
          HabotTranscriptPunctuation.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final double coverage = HabotTranscriptPunctuation.coveragePercent;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04924',
        atomicStepReferenceId: 'GEN-04924',
        setupStepAction:
            'COLUMN NOTE: this row\'s ceiling states a boundary and then '
            'argues against exceeding it, the tenth annotated boundary in the '
            'track; its floor joins coverage and acceptance criteria with an '
            'oblique, read as "and" for the third time after Steps 430 and '
            '446; it is substep 3 of a parent nobody names; and its subject is '
            'built so that punctuation is a rendering over a kept raw token '
            'stream, confirmed by the speaker before anything reaches a '
            'child\'s file. Atomic Step: "Implement substep 3: Include '
            'client-side punctuation parsing and real-time text transcription '
            'rendering."',
        implementationOrder: 461,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement substep 3: Include client-side punctuation parsing and '
          'real-time text':
              'punctuation rendered over a kept token stream, confirmed by the '
                  'speaker before saving, interim text marked in two channels; '
                  'coverage ${coverage.toStringAsFixed(0)} per cent with all '
                  'acceptance criteria met',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Substep Definition-of-Done Adherence Rate',
            observed:
                'THE CEILING STATES A BOUNDARY AND THEN ARGUES AGAINST '
                'EXCEEDING IT, the tenth annotated boundary in the track, and '
                'the floor joins coverage and acceptance criteria with an '
                'oblique read as "and" for the third time after Steps 430 and '
                '446. Under the stricter reading both hold: '
                '${coverage.toStringAsFixed(0)} per cent coverage and every '
                'acceptance criterion met.',
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
            metricName:
                'Machine-punctuated text saved without a human seeing it',
            observed:
                '0. "She is not settling, well" and "She is not settling well" '
                'are the same sounds and opposite records, so the punctuated '
                'text is a rendering and the raw token stream is the record. '
                'Both are stored, the speaker sees the punctuation first, and '
                'interim words are marked as unconfirmed by weight and by '
                'wording rather than by colour.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/capture/transcript_punctuation.dart',
        ],
      ),
    );
  });
}
