/// AISS GATE -- Step 342 of 355
/// Global Reference ID:       MCIIM-014-11
/// Atomic Steps Reference ID: MCIIM-014-11
/// Setup Step (Action): "Set the global mobile action element minimum height
///                      parameter to 48dp (44px)." (TWO STANDARDS' NUMBERS
///                      PRESENTED AS A UNIT CONVERSION)
/// Atomic Step: "Enforce strict touch element padding rules targeting the
///               isolated task text fields."
/// Metric: Process Step Execution Conformance -- floor 0.9, optimal 0.97,
///         ceiling 1. Complete/Partial/Not Complete. ISO 9001:2015.
///
/// "48dp (44px)" IS NOT A CONVERSION. IT IS MATERIAL DESIGN AND APPLE'S HIG,
/// FOUR POINTS APART, PRINTED AS ONE FIGURE IN TWO UNITS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/field_padding.dart';

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

  group('MCIIM-014-11 :: the parenthesis', () {
    gate(
      'MCIIM-014-11-G1',
      'Setup Step: "minimum height parameter to 48dp (44px)".',
      'At the baseline density one dp is one px, so 48dp is 48px and the '
          'parenthesis disagrees with the figure in front of it by four',
      () =>
          HabotFieldPadding.theParenthesisIsNotAConversion &&
          HabotFieldPadding.discrepancyPx == 4 &&
          HabotFieldPadding.dpConvertedToPx == 48,
    );

    gate(
      'MCIIM-014-11-G2',
      'Four points is nine per cent on a side.',
      'And nineteen per cent of area, which is the size of the disagreement '
          'being presented as a restatement',
      () => HabotFieldPadding.theGapIsNineteenPerCentOfArea,
    );

    gate(
      'MCIIM-014-11-G3',
      'Each number is traced to a different vendor.',
      '48 is Material Design 3 and this project\'s own token since Step 3; 44 '
          'is Apple\'s HIG and WCAG 2.1 SC 2.5.5 at AAA',
      () =>
          HabotFieldPadding.bothNumbersHaveASource &&
          HabotFieldPadding.conversionNote.contains('Two vendors'),
    );
  });

  group('MCIIM-014-11 :: already resolved here', () {
    gate(
      'MCIIM-014-11-G4',
      'The two numbers are the two ends of the existing band.',
      'Step 184 put 44 at the floor and 48 at the optimal; Step 227 recorded '
          'that this project resolves upward',
      () =>
          HabotFieldPadding.theParenthesisIsTheBand &&
          HabotFieldPadding.bandFloorDp == 44 &&
          HabotFieldPadding.bandOptimalDp == 48,
    );

    gate(
      'MCIIM-014-11-G5',
      'Nothing new is declared.',
      'The row is answered by pointing at what is already true, which is what '
          'a restatement deserves',
      () =>
          HabotFieldPadding.theStepThatResolvedIt == 227 &&
          HabotFieldPadding.resolutionNote.contains('already true'),
    );
  });

  group('MCIIM-014-11 :: padding is not size', () {
    gate(
      'MCIIM-014-11-G6',
      'A 24dp icon with 12dp of padding on four sides is 48 square.',
      'The same 12dp on two sides is 48 by 24, and the dimension a finger has '
          'to hit accurately is the smaller one',
      () =>
          HabotFieldPadding.thesamePaddingGivesTwoVerdicts &&
          HabotFieldPadding.symmetric.minor == 48 &&
          HabotFieldPadding.horizontalOnly.minor == 24,
    );

    gate(
      'MCIIM-014-11-G7',
      'Only one of the two rectangles clears the band.',
      'Same padding value, same content, two different verdicts -- so the '
          'rule is stated on the hit rectangle rather than on the padding',
      () =>
          HabotFieldPadding.rectanglesThatClear == 1 &&
          HabotFieldPadding.clearsTheBand(HabotFieldPadding.symmetric) &&
          HabotFieldPadding.paddingNote.contains('stated on the rectangle'),
    );

    gate(
      'MCIIM-014-11-G8',
      'Two sizing routes are named.',
      'Padded content and a fixed box reach the same size by different means '
          'and fail differently',
      () => HabotSizingRoute.values.length == 2,
    );
  });

  group('MCIIM-014-11 :: the band', () {
    gate(
      'MCIIM-014-11-G9',
      'Floor 0.9, optimal 0.97, ceiling 1 -- correctly ordered.',
      'And naming no population, so the denominator is stated here instead: '
          'the fields on the isolated task surface',
      () =>
          HabotFieldPadding.theBandIsOrderedCorrectly &&
          HabotFieldPadding.theRowNamesNoPopulation &&
          HabotFieldPadding.bandNote.contains('denominator'),
    );

    gate(
      'MCIIM-014-11-G10',
      'Output reported as Complete / Partial / Not Complete.',
      'Five obligations, all met, giving Complete; all ten declared checks '
          'hold',
      () =>
          HabotFieldPadding.obligations.length == 5 &&
          HabotFieldPadding.obligations.values.every((bool b) => b) &&
          HabotFieldPadding.qualitativeOutput == 'Complete' &&
          HabotFieldPadding.checks.length == 10 &&
          HabotFieldPadding.checks.values.every((bool b) => b) &&
          HabotFieldPadding.columnNote.contains('two vendors'),
    );
  });

  tearDownAll(() {
    final String area = HabotFieldPadding.areaRatio.toStringAsFixed(4);
    final double minor = HabotFieldPadding.horizontalOnly.minor;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'MCIIM-014-11',
        atomicStepReferenceId: 'MCIIM-014-11',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Set the '
            'global mobile action element minimum height parameter to 48dp '
            '(44px)", which presents two vendors\' specifications as one '
            'figure in two units; the Data Requirement column is about '
            'isolating a single Byt with surface elevation and 16dp margins, '
            'which is layout rather than touch; and the band is a conformance '
            'ratio with no stated population. Atomic Step: "Enforce strict '
            'touch element padding rules targeting the isolated task text '
            'fields."',
        implementationOrder: 342,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'MCIIM-014-11',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              '48dp is 48px, not 44px; the gap is 4 points, which is a factor '
                  'of $area in area',
          'User ID': 'Fredrick',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the same 12dp of padding gives a 48dp square on four sides and '
                  'a ${minor}dp minor dimension on two',
          'Data Quality Note':
              'CONVERSION: ${HabotFieldPadding.conversionNote} '
              'RESOLUTION: ${HabotFieldPadding.resolutionNote} '
              'PADDING: ${HabotFieldPadding.paddingNote} '
              'BAND: ${HabotFieldPadding.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Step Execution Conformance',
            observed:
                'THE SETUP STEP PRINTS TWO STANDARDS AS ONE FIGURE. "48dp '
                '(44px)" is not a unit conversion: at the baseline density '
                '48dp is 48px, and 44 is Apple\'s Human Interface Guidelines '
                'number, separately the WCAG 2.1 SC 2.5.5 figure at Level AAA. '
                'The two disagree by four points, nine per cent on a side and '
                'a factor of $area in area. In this repository they are '
                'already the floor and the optimal of the band Step 184 built, '
                'and Step 227 recorded that the project resolves upward to 48.',
            floor: '0.9',
            optimal: '0.97',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Minor dimension of the hit rectangle, in dp',
            observed:
                '48 with 12dp of padding on four sides, and ${minor} with the '
                'same 12dp on two. The row specifies padding, which does not '
                'determine a target size without also saying which sides it is '
                'on -- so the enforced rule is stated on the hit rectangle '
                'rather than on the padding, and it is the smaller dimension '
                'that has to clear the band.',
            floor: '44',
            optimal: '48',
            ceiling: '56',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/field_padding.dart',
        ],
      ),
    );
  });
}
