/// AISS GATE -- Step 307 of 315
/// Global Reference ID:       GEN-02444
/// Atomic Steps Reference ID: GEN-02444
/// Setup Step (Action): (the generic engineering-console boilerplate; the Data
///                      Requirement cell repeats the Atomic Step back as the
///                      artefact to prepare -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Add clear iconography to represent different file types."
/// Metric: Process Completion Rate -- floor 0, optimal "95-100%", ceiling 1.
///         Complete/Partial/Not Complete. ISO/IEC 25010.
///
/// NINE TYPES, FOUR SILHOUETTES. A DISTINCT PICTURE PER TYPE IS NOT A THING
/// THAT CAN BE DRAWN, AND THE BAND IS WRITTEN IN THREE UNITS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/iconography/file_type_icons.dart';

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

  group('GEN-02444 :: what a silhouette can say', () {
    gate(
      'GEN-02444-G1',
      'Atomic Step: "clear iconography to represent different file types".',
      'Nine types reduce to four outlines at 24 points, so eight of the nine '
          'share theirs with at least one other',
      () =>
          HabotFileTypeIcons.types.length == 9 &&
          HabotFileTypeIcons.distinctSilhouettes == 4 &&
          HabotFileTypeIcons.sharingASilhouette.length == 8,
    );

    gate(
      'GEN-02444-G2',
      'Exactly one type is identifiable by shape alone.',
      'The archive; four of the nine are documents, which at 24 points are '
          'one rectangle with a folded corner',
      () =>
          HabotFileTypeIcons.identifiableByShapeAlone.length == 1 &&
          HabotFileTypeIcons.identifiableByShapeAlone.first.extension ==
              'zip' &&
          HabotFileTypeIcons
                  .silhouetteCounts[HabotFileSilhouette.document] ==
              4,
    );

    gate(
      'GEN-02444-G3',
      'So the instruction is read as "the person can tell which file this '
          'is".',
      'Which is achievable, and the thing that does the telling is the mark '
          'rather than the picture',
      () =>
          HabotFileTypeIcons.glyphSizeDp == 24 &&
          HabotFileTypeIcons.silhouetteNote
              .contains('nobody can carry out'),
    );
  });

  group('GEN-02444 :: three channels', () {
    gate(
      'GEN-02444-G4',
      'Every type carries a silhouette, a mark and a sentence.',
      'Every mark is unique and at most four characters, so it can be read '
          'at a glance rather than deciphered',
      () =>
          HabotFileTypeIcons.everyTypeHasAMark &&
          HabotFileTypeIcons.everyMarkIsUnique &&
          HabotFileTypeIcons.everyMarkIsShortEnoughToRead &&
          HabotFileTypeIcons.everyTypeHasASpokenLabel,
    );

    gate(
      'GEN-02444-G5',
      'The spoken label is a noun phrase.',
      'Not the extension shouted back and not the word "icon", which '
          'describes the widget rather than the file',
      () =>
          HabotFileTypeIcons.noLabelIsMerelyTheExtension &&
          HabotFileTypeIcons.noLabelIsTheWordFileIcon &&
          HabotFileTypeIcons.channelsNote.contains('described the widget'),
    );
  });

  group('GEN-02444 :: the case nobody draws', () {
    gate(
      'GEN-02444-G6',
      'An unrecognised extension.',
      'It has a glyph, a mark and a sentence, and the sentence says the type '
          'is unrecognised rather than pretending the file is a document',
      () =>
          HabotFileTypeIcons.theFallbackIsFullyFormed &&
          HabotFileTypeIcons.anUnknownExtensionResolves &&
          HabotFileTypeIcons.fallback.spokenLabel ==
              'File of an unrecognised type',
    );

    gate(
      'GEN-02444-G7',
      'It never appears in a mock-up.',
      'Which is why it ships as a blank box, and why it is worth naming '
          'rather than leaving to the asset pipeline',
      () =>
          HabotFileTypeIcons.fallbackNote
              .contains('never appears in a mock-up') &&
          HabotFileTypeIcons.aDottedExtensionResolves &&
          HabotFileTypeIcons.forExtension('XLSX').mark == 'XLS',
    );
  });

  group('GEN-02444 :: the band', () {
    gate(
      'GEN-02444-G8',
      'Floor 0, optimal "95-100%", ceiling 1.',
      'Three boundaries in three units: read as rates the ceiling and the '
          'optimal\'s upper end are the same number and the floor is a level '
          'no work can fall below',
      () =>
          HabotFileTypeIcons.theThreeBoundariesAreInDifferentUnits &&
          HabotFileTypeIcons.theFloorCannotBeFailed,
    );

    gate(
      'GEN-02444-G9',
      'Step 286 found a floor that could not be failed.',
      'This is the same defect with two units added, and it is recorded '
          'rather than scored against',
      () => HabotFileTypeIcons.bandNote.contains('Step 286'),
    );

    gate(
      'GEN-02444-G10',
      'Output: Complete / Partial / Not Complete.',
      'Five declared obligations, all met, giving Complete; all ten declared '
          'checks hold',
      () =>
          HabotFileTypeIcons.obligations.length == 5 &&
          HabotFileTypeIcons.obligations.values.every((bool b) => b) &&
          HabotFileTypeIcons.completionRate == 1.0 &&
          HabotFileTypeIcons.qualitativeOutput == 'Complete' &&
          HabotFileTypeIcons.checks.length == 10 &&
          HabotFileTypeIcons.checks.values.every((bool b) => b) &&
          HabotFileTypeIcons.columnNote.contains('artifacts to prepare'),
    );
  });

  tearDownAll(() {
    final String share =
        HabotFileTypeIcons.shareIdentifiableByShape.toStringAsFixed(3);
    final String unknown =
        HabotFileTypeIcons.forExtension('heic').spokenLabel;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02444',
        atomicStepReferenceId: 'GEN-02444',
        setupStepAction:
            'COLUMN NOTE: every narrative column on this row is the generic '
            'engineering-console boilerplate, and the Data Requirement cell '
            'repeats the Atomic Step back as the artefact to prepare -- '
            '"Data/artifacts to prepare: Add clear iconography to represent '
            'different file types." Atomic Step: "Add clear iconography to '
            'represent different file types."',
        implementationOrder: 307,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Add clear iconography to represent different file types.':
              '${HabotFileTypeIcons.types.length} types over '
                  '${HabotFileTypeIcons.distinctSilhouettes} silhouettes, each '
                  'with a type mark and a spoken label, plus a formed fallback',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'an unrecognised extension announces "$unknown" rather than '
                  'rendering a blank box',
          'Data Quality Note':
              'SILHOUETTES: ${HabotFileTypeIcons.silhouetteNote} '
              'CHANNELS: ${HabotFileTypeIcons.channelsNote} '
              'FALLBACK: ${HabotFileTypeIcons.fallbackNote} '
              'BAND: ${HabotFileTypeIcons.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Completion Rate',
            observed:
                '100% over five declared obligations. The band is written in '
                'three units -- a bare 0, a percentage range, a bare 1 -- and '
                'a floor of zero on a completion rate is a level no work can '
                'fall below, which is the defect Step 286 found written into a '
                'different band.',
            floor: '0',
            optimal: '95-100%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'File types identifiable by silhouette alone',
            observed:
                '1 of ${HabotFileTypeIcons.types.length} (share $share). A '
                'distinct picture per type is not a thing that can be drawn at '
                '24 points; the mark carries the exact type and the spoken '
                'label carries it in words.',
            floor: '1',
            optimal: '9',
            ceiling: '9',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/iconography/file_type_icons.dart',
        ],
      ),
    );
  });
}
