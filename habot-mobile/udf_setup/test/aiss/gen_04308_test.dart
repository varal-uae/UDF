/// AISS GATE -- Step 262 of 275
/// Global Reference ID:       GEN-04308
/// Atomic Steps Reference ID: GEN-04308
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Add file attachment inputs with type and size validation to
///               the ticket form."
/// Metric: Form Field Validation Accuracy -- Floor 0.95, Optimal 0.99,
///         Ceiling 1. Good/Average/Poor.
///
/// AN EXTENSION IS A CLAIM THE UPLOADER MAKES. THE BYTES ARE THE EVIDENCE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/file_attachment.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double accuracy = 0;

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

  group('GEN-04308 :: type validation that reads the file', () {
    gate(
      'GEN-04308-G1',
      'Atomic Step: "with type and size validation".',
      'Four types are allowed, each with the magic bytes that identify it and '
          'a reason it is on the list, so "type validation" means the '
          'content rather than the last three characters of a name',
      () =>
          HabotFileAttachment.allowedTypes.length == 4 &&
          HabotFileAttachment.everyTypeGivesAReason &&
          HabotFileAttachment.sniffLength == 4,
    );

    gate(
      'GEN-04308-G2',
      'An extension is a claim, not a fact.',
      'A file named .png whose bytes are not a PNG is refused, and the sniff '
          'catches cases the name alone cannot',
      () =>
          HabotFileAttachment.theSniffCatchesWhatTheNameCannot &&
          HabotFileAttachment.extensionIsAClaimNote.contains('claim'),
    );

    gate(
      'GEN-04308-G3',
      'A file name arrives from somewhere else.',
      'Path separators and traversal sequences are refused in a name, '
          'including the backslash, which is a separator on one of the two '
          'platforms and an ordinary character on the other',
      () =>
          !HabotFileAttachment.nameIsSafe('../etc/passwd') &&
          !HabotFileAttachment.nameIsSafe(
            'a${HabotFileAttachment.pathSeparatorBackslash}b.png',
          ) &&
          HabotFileAttachment.nameIsSafe('receipt.png') &&
          HabotFileAttachment.pathSeparatorBackslash.length == 1,
    );

    gate(
      'GEN-04308-G4',
      'Size is checked before anything is read.',
      'The size limit is applied before the bytes are touched, because '
          'reading an oversized file to discover it is oversized is the bug '
          'the limit exists to prevent',
      () =>
          HabotFileAttachment.maxBytes == 8 * 1024 * 1024 &&
          HabotFileAttachment.sizeIsRefusedBeforeAnythingIsRead &&
          HabotFileAttachment.sizeBeforeReadNote.isNotEmpty,
    );
  });

  group('GEN-04308 :: the corpus and the metric', () {
    gate(
      'GEN-04308-G5',
      'A validator with no wrong answers in its corpus was not tested.',
      'Eight cases are classified across six verdicts and the evaluator '
          'agrees with the expected verdict on every one',
      () =>
          HabotFileAttachment.corpus.length == 8 &&
          HabotFileAttachment.corpusIsClassifiedCorrectly &&
          HabotAttachmentVerdict.values.length == 6,
    );

    gate(
      'GEN-04308-G6',
      'Metric: Form Field Validation Accuracy -- 0.95 / 0.99 / 1.',
      'Accuracy is 1.0 over the corpus, and the same corpus scored by name '
          'alone gives 0.875 -- below the floor, which is what the sniff is '
          'worth in the row\'s own units',
      () {
        accuracy = HabotFileAttachment.validationAccuracy;
        return accuracy == 1.0 &&
            (HabotFileAttachment.nameOnlyAccuracy - 0.875).abs() < 1e-9 &&
            HabotFileAttachment.nameOnlyAccuracy < HabotFileAttachment.floor;
      },
    );

    gate(
      'GEN-04308-G7',
      'Decoding an image is where the cost and the risk are.',
      'The cost of decoding and the reason PDFs are handled differently are '
          'both recorded rather than left to the reader to rediscover',
      () =>
          HabotFileAttachment.decodeCostNote.isNotEmpty &&
          HabotFileAttachment.pdfNote.isNotEmpty,
    );

    gate(
      'GEN-04308-G8',
      'Output: Good/Average/Poor.',
      'All nine declared checks hold and the reported band is Good, against '
          'a ceiling of 1 that this corpus reaches',
      () =>
          HabotFileAttachment.checks.length == 9 &&
          HabotFileAttachment.checks.values.every((bool b) => b) &&
          HabotFileAttachment.qualitativeOutput == 'Good' &&
          HabotFileAttachment.floor == 0.95 &&
          HabotFileAttachment.optimal == 0.99 &&
          HabotFileAttachment.ceiling == 1 &&
          HabotFileAttachment.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String cases = '${HabotFileAttachment.corpus.length}';
    final String nameOnly =
        HabotFileAttachment.nameOnlyAccuracy.toStringAsFixed(3);
    final String limit = '${HabotFileAttachment.maxBytes ~/ (1024 * 1024)}MB';
    final String types = '${HabotFileAttachment.allowedTypes.length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04308',
        atomicStepReferenceId: 'GEN-04308',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Add file attachment inputs with type and size validation '
            'to the ticket form."',
        implementationOrder: 262,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotFileAttachment / HabotAllowedType / HabotAttachmentCase',
          'Component Properties':
              '$types allowed types identified by their first '
              '${HabotFileAttachment.sniffLength} bytes; a $limit ceiling '
              'applied before anything is read; file names refused for path '
              'separators and traversal; $cases classified cases',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotFileAttachment.extensionIsAClaimNote} '
              'COST: ${HabotFileAttachment.decodeCostNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Form Field Validation Accuracy',
            observed:
                '${accuracy.toStringAsFixed(3)} over $cases cases. The same '
                'corpus judged by file name alone scores $nameOnly, which is '
                'below the row\'s floor -- the difference is what reading the '
                'first ${HabotFileAttachment.sniffLength} bytes is worth.',
            floor: '0.95',
            optimal: '0.99',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Unsafe file names accepted',
            observed:
                '0. Forward slash, the backslash separator and traversal '
                'sequences are all refused; the backslash is a separator on '
                'one platform and an ordinary character on the other, which '
                'is why it is named rather than assumed.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/file_attachment.dart',
        ],
      ),
    );
  });
}
