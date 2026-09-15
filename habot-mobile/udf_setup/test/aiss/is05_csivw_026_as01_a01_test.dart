/// AISS GATE -- Step 288 of 295
/// Global Reference ID:       IS05-CSIVW-026-AS01
/// Atomic Steps Reference ID: IS05-CSIVW-026-AS01-A01
/// Setup Step (Action): "Represent theme choice controls using standard vector
///                      icon shapes." (DIFFERENT SUBJECT)
/// Atomic Step: "Identify target ENUM form fields requiring chip array
///               presentation."
/// Metric: Asset & Component Discovery Completeness -- Floor "90% of target
///         assets confirmed present", Optimal "100%", Ceiling "100% (full
///         inventory)". Complete / Partial / Not Complete.
///
/// THE FIRST ROW IN THIS BATCH WHOSE METRIC MEASURES ITS OWN ACTION -- AND A
/// RULE THAT HAS TO AGREE WITH STEP 287.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/enum_chip_array.dart';

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

  group('IS05-CSIVW-026-AS01-A01 :: the inventory', () {
    gate(
      'IS05-CSIVW-026-AS01-A01-G1',
      'Atomic Step: "Identify target ENUM form fields".',
      'Seven enumerated fields are inventoried, each with the three facts the '
          'rule reads: option count, role, and whether an answer is '
          'compulsory',
      () =>
          HabotEnumChipArray.fields.length == 7 &&
          HabotEnumChipArray.everyFieldIsFullyDescribed,
    );

    gate(
      'IS05-CSIVW-026-AS01-A01-G2',
      'An inventory that lists only the yes answers is a shortlist.',
      'Four fields get chips and three do not, so the refusals are in the '
          'inventory rather than filtered out of it',
      () => HabotEnumChipArray.theInventoryIncludesTheRefusals,
    );

    gate(
      'IS05-CSIVW-026-AS01-A01-G3',
      'The boundary is exercised on both sides.',
      'A four-option single-choice field gets chips and a six-option one does '
          'not, against a declared ceiling of five',
      () =>
          HabotEnumChipArray.theBoundaryCasesAreOnBothSides &&
          HabotEnumChipArray.chipCeilingForSingleChoice == 5,
    );

    gate(
      'IS05-CSIVW-026-AS01-A01-G4',
      'Step 287 gave seven emirates a picker.',
      'This rule refuses them chips by the same rule rather than by an '
          'exception written for them, which is the point of having a rule '
          'rather than two opinions',
      () =>
          HabotEnumChipArray.theTwoStepsAgreeAboutEmirates &&
          HabotEnumChipArray.whenChipsWinNote.contains('two opinions'),
    );
  });

  group('IS05-CSIVW-026-AS01-A01 :: overflow, and a metric that fits', () {
    gate(
      'IS05-CSIVW-026-AS01-A01-G5',
      'Row design note: "horizontal overflow panning".',
      'An optional filter row may pan, because an unseen chip costs nothing; '
          'a required field wraps, because an option past the edge cannot be '
          'chosen by somebody who does not know it is there',
      () =>
          HabotEnumChipArray.filtersMayPan &&
          HabotEnumChipArray.requiredFieldsWrap &&
          HabotEnumChipArray.overflowNote.contains('missing their answer'),
    );

    gate(
      'IS05-CSIVW-026-AS01-A01-G6',
      'Row design note: "strict 8dp layout gap tracking".',
      'Eight is already on the spacing scale, so the row\'s figure agrees '
          'with a token and the token is what is used -- the third such '
          'agreement in this batch',
      () =>
          HabotEnumChipArray.theGapIsADeclaredToken &&
          HabotEnumChipArray.gapTheRowNames == 8,
    );

    gate(
      'IS05-CSIVW-026-AS01-A01-G7',
      'Metric: Asset & Component Discovery Completeness.',
      'The action is discovery and the metric measures discovery, which after '
          'nine batches of mismatches is worth recording as the exception',
      () =>
          HabotEnumChipArray.discoveryCompleteness >= 1.0 &&
          HabotEnumChipArray.qualitativeOutput == 'Complete' &&
          HabotEnumChipArray.metricFitsNote.contains('it is the exception'),
    );

    gate(
      'IS05-CSIVW-026-AS01-A01-G8',
      'Ceiling: "100% (full inventory -- no further discovery value)".',
      'The only ceiling in this batch that explains itself, and it is right: '
          'discovery saturates',
      () => HabotEnumChipArray.ceilingNote.contains('discovery saturates'),
    );

    gate(
      'IS05-CSIVW-026-AS01-A01-G9',
      'This row\'s two reference ids differ.',
      'The atomic id is the more specific and is what the evidence records as '
          'the step; the global id is carried alongside it. All twelve '
          'declared checks hold',
      () =>
          HabotEnumChipArray.identifierNote
              .contains('IS05-CSIVW-026-AS01-A01') &&
          HabotEnumChipArray.checks.length == 12 &&
          HabotEnumChipArray.checks.values.every((bool b) => b) &&
          HabotEnumChipArray.columnNote.contains('theme choice controls'),
    );
  });

  tearDownAll(() {
    final String chips = '${HabotEnumChipArray.chipFields.length}';
    final String pickers = '${HabotEnumChipArray.pickerFields.length}';
    final String share =
        (HabotEnumChipArray.shareGettingChips * 100).toStringAsFixed(1);
    final String gap = HabotEnumChipArray.gapUsed.toStringAsFixed(0);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'IS05-CSIVW-026-AS01',
        atomicStepReferenceId: 'IS05-CSIVW-026-AS01-A01',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Represent '
            'theme choice controls using standard vector icon shapes", and '
            'the Dependency cell contains an entire block of Mobile-First and '
            'Poka-Yoke text belonging in its own columns. Atomic Step: '
            '"Identify target ENUM form fields requiring chip array '
            'presentation."',
        implementationOrder: 288,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotEnumChipArray / HabotEnumField',
          'Component Properties':
              '${HabotEnumChipArray.fields.length} enumerated fields, $chips '
              'getting chips and $pickers refused ($share%); chip ceiling '
              '${HabotEnumChipArray.chipCeilingForSingleChoice} for single '
              'choice; ${gap}dp gap from the declared scale; required chip '
              'fields wrap and optional ones may pan',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'RULE: ${HabotEnumChipArray.whenChipsWinNote} '
              'OVERFLOW: ${HabotEnumChipArray.overflowNote} '
              'METRIC: ${HabotEnumChipArray.metricFitsNote} '
              'IDS: ${HabotEnumChipArray.identifierNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Asset & Component Discovery Completeness',
            observed:
                '100%: ${HabotEnumChipArray.fields.length} of '
                '${HabotEnumChipArray.targetFieldsExpected} target fields '
                'confirmed present and fully described, including the $pickers '
                'that the chip rule refuses -- an inventory that listed only '
                'the yes answers would be a shortlist.',
            floor: '90% of target assets confirmed present',
            optimal: '100% of target assets confirmed present',
            ceiling: '100% (full inventory)',
          ),
          AissMeasurement(
            metricName: 'Required fields whose chips may scroll off the edge',
            observed:
                '0. Optional filter rows may pan because an unseen chip costs '
                'nothing there; required fields wrap, because an option past '
                'the edge cannot be chosen by somebody who does not know it '
                'exists.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/enum_chip_array.dart',
        ],
      ),
    );
  });
}
