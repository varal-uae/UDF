/// AISS GATE -- Step 265 of 275
/// Global Reference ID:       MCIIM-010-10
/// Atomic Steps Reference ID: MCIIM-010-10
/// Setup Step (Action): (ABSENT on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Pre-fill the form with the values extracted from the image
///               and let the user correct them."
/// Metric: Image/Document Extraction Accuracy -- Floor 0.9, Optimal 0.97,
///         Ceiling 0.995. Pass (Scale: Pass/Fail).
///
/// A DOCUMENT-LEVEL ACCURACY FIGURE HIDES WHICH FIELDS ARE WRONG, AND THE
/// FIELDS ARE THE ONLY THING A PERSON CAN CORRECT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/extraction_correction.dart';

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

  group('MCIIM-010-10 :: pre-filled, and marked as such', () {
    gate(
      'MCIIM-010-10-G1',
      'Atomic Step: "Pre-fill the form with the values extracted".',
      'Every field that has an extracted value starts with it, and every one '
          'of those also carries an unconfirmed mark -- a pre-filled field '
          'that looks like a typed one is a field nobody checks',
      () =>
          HabotExtractionCorrection.workedDocument.length == 5 &&
          HabotExtractionCorrection.preFilledAndMarked &&
          HabotExtractionCorrection.preFilledNote.isNotEmpty,
    );

    gate(
      'MCIIM-010-10-G2',
      'A field the extractor could not read is not a blank field.',
      'Fields the extractor produced nothing for are shown empty and marked '
          'missing rather than silently left blank, so the person can tell '
          '"nothing was found" from "nothing is required"',
      () =>
          HabotExtractionCorrection.missingFieldsAreShownEmptyAndMarked &&
          HabotExtractionState.values.length == 4,
    );

    gate(
      'MCIIM-010-10-G3',
      '"Let the user correct them" means the correction is distinguishable.',
      'Confirming a value and changing it produce different states, so a '
          'record can say which fields a person actually looked at rather '
          'than only which ones ended up right',
      () => HabotExtractionCorrection.confirmedAndCorrectedAreDistinguishable,
    );

    gate(
      'MCIIM-010-10-G4',
      'An empty field is obvious; a confidently wrong one is not.',
      'The person is taken first to the least confident field that still has '
          'a value, rather than to the empty one, and the worked document '
          'names which field that is',
      () =>
          HabotExtractionCorrection.firstToReview.extracted.isNotEmpty &&
          HabotExtractionCorrection.firstToReview.name == 'expiry date' &&
          HabotExtractionCorrection.firstToReview.confidence <
              HabotExtractionCorrection.attentionThreshold,
    );
  });

  group('MCIIM-010-10 :: the figure and what it hides', () {
    gate(
      'MCIIM-010-10-G5',
      'Metric: Image/Document Extraction Accuracy -- 0.9 / 0.97 / 0.995.',
      'The document-level figure the row reports is its own optimal, while '
          'three of the five fields are below the threshold a person should '
          'be taken to -- both numbers are published so the aggregate cannot '
          'stand in for the detail',
      () =>
          HabotExtractionCorrection.documentLevelFigureTheMetricReports ==
              HabotExtractionCorrection.optimal &&
          HabotExtractionCorrection.belowThreshold.length == 3 &&
          (HabotExtractionCorrection.shareOfFieldsAboveThreshold - 0.4).abs() <
              1e-9 &&
          HabotExtractionCorrection.theDocumentFigureHidesWhichFieldsAreWrong,
    );

    gate(
      'MCIIM-010-10-G6',
      'Ninety-seven per cent is three fields in a hundred wrong.',
      'The row\'s own optimal is restated in the units a person experiences, '
          'and per-field confidence is recorded as the thing that makes the '
          'correction possible at all',
      () =>
          (HabotExtractionCorrection.wrongFieldsPerHundredAtOptimal - 3).abs() <
              1e-9 &&
          HabotExtractionCorrection.perFieldConfidenceNote.isNotEmpty,
    );

    gate(
      'MCIIM-010-10-G7',
      'The image is the evidence for the correction.',
      'While a correction is in progress the image cannot be replaced, '
          'because a corrected value checked against a different image is '
          'not checked at all',
      () =>
          HabotExtractionCorrection.aCorrectionInProgressLocksTheImage &&
          !HabotExtractionCorrection.imageMayBeReplaced(
            HabotLockReason.correctionInProgress,
          ) &&
          HabotExtractionCorrection.imageMayBeReplaced(HabotLockReason.none) &&
          HabotExtractionCorrection.lockNote.isNotEmpty,
    );

    gate(
      'MCIIM-010-10-G8',
      'Three subjects on one row.',
      'The Atomic Step, the metric and the Data Collected column are about '
          'three different things, and all three are recorded rather than the '
          'easiest one being answered',
      () =>
          HabotExtractionCorrection.threeSubjectsNote.isNotEmpty &&
          HabotExtractionCorrection.checks.length == 10 &&
          HabotExtractionCorrection.checks.values.every((bool b) => b) &&
          HabotExtractionCorrection.qualitativeOutput == 'Pass' &&
          HabotExtractionCorrection.columnNote.isNotEmpty,
    );
  });

  tearDownAll(() {
    final String fields = '${HabotExtractionCorrection.workedDocument.length}';
    final String below = '${HabotExtractionCorrection.belowThreshold.length}';
    final String above = HabotExtractionCorrection.shareOfFieldsAboveThreshold
        .toStringAsFixed(2);
    final String first = HabotExtractionCorrection.firstToReview.name;
    final String perHundred = HabotExtractionCorrection
        .wrongFieldsPerHundredAtOptimal
        .toStringAsFixed(0);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'MCIIM-010-10',
        atomicStepReferenceId: 'MCIIM-010-10',
        setupStepAction:
            'COLUMN NOTE: this row carries no Setup Step (Action), no '
            'Expected Output and no Completion Measures. Atomic Step: '
            '"Pre-fill the form with the values extracted from the image and '
            'let the user correct them."',
        implementationOrder: 265,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotExtractionCorrection / HabotExtractedField / '
                  'HabotExtractionState',
          'Component Properties':
              '$fields worked fields each with an extracted value, a '
              'confidence and a state; $below of them below the '
              '${HabotExtractionCorrection.attentionThreshold} attention '
              'threshold; first review target "$first"; confirmed and '
              'corrected kept distinct; the image locked while a correction '
              'is open',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotExtractionCorrection.perFieldConfidenceNote} '
              'PRE-FILL: ${HabotExtractionCorrection.preFilledNote} '
              'SUBJECTS: ${HabotExtractionCorrection.threeSubjectsNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Image/Document Extraction Accuracy',
            observed:
                'The row reports one figure per document, and on this worked '
                'document that figure is its own optimal while only $above of '
                'the fields are above the threshold a person should be taken '
                'to. Both are published: the aggregate cannot say which field '
                'is wrong, and the field is the only thing anybody can '
                'correct.',
            floor: '0.9',
            optimal: '0.97',
            ceiling: '0.995',
          ),
          AissMeasurement(
            metricName: 'Wrong fields per hundred at the row\'s optimal',
            observed:
                '$perHundred. Stated in the units the person experiences '
                'rather than as a decimal, because 0.97 reads like success '
                'and three wrong fields in a hundred reads like work.',
            floor: '10',
            optimal: '3',
            ceiling: '0.5',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/extraction_correction.dart',
        ],
      ),
    );
  });
}
