/// AISS GATE -- Step 301 of 315
/// Global Reference ID:       GEN-04946
/// Atomic Steps Reference ID: GEN-04946
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Apply the mobile-first UX decision: Touch-optimized progress
///               sliders over text field numeric inputs."
/// Metric: UX Decision Adoption Consistency -- floor ">=95% of applicable
///         screens/flows apply the decision", optimal "100%", ceiling "100%".
///         Yes / No. Nielsen Norman Group Mobile UX Heuristics.
///
/// THREE OF EIGHT NUMERIC INPUTS SUIT A SLIDER. THE FLOOR WOULD PUT ONE ON
/// THE PASSCODE FIELD.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/slider_over_numeric_field.dart';

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

  group('GEN-04946 :: the decision needs a condition', () {
    gate(
      'GEN-04946-G1',
      'Atomic Step: sliders over numeric fields, stated without a condition.',
      'Eight numeric inputs, three of which are values a person chooses from '
          'a bounded range; the other five are entered or are not quantities '
          'at all',
      () =>
          HabotSliderOverNumericField.inputs.length == 8 &&
          HabotSliderOverNumericField.sliderInputs.length == 3 &&
          HabotSliderOverNumericField.fieldInputs.length == 5 &&
          HabotSliderOverNumericField.adoptionRate == 0.375,
    );

    gate(
      'GEN-04946-G2',
      'The amount field is the one that matters, in a payments application.',
      'A 0 to 100,000 dirham range across a 328-point track moves 304.88 '
          'dirhams per point and about 101.63 per physical pixel at 3x, so '
          'the number somebody means is not on the track at all',
      () =>
          (HabotSliderOverNumericField.dirhamsPerDp - 304.87804878048783)
                  .abs() <
              1e-6 &&
          (HabotSliderOverNumericField.dirhamsPerPhysicalPixel -
                      101.62601626016261)
                  .abs() <
              1e-6 &&
          HabotSliderOverNumericField.theAmountCannotBeReached,
    );

    gate(
      'GEN-04946-G3',
      'No amount of careful dragging fixes it.',
      'Between one pixel and the next there is no position representing the '
          'value, which is a different failure from imprecision',
      () => HabotSliderOverNumericField.amountNote
          .contains('is not on the track'),
    );
  });

  group('GEN-04946 :: a step has to be wide enough to land on', () {
    gate(
      'GEN-04946-G4',
      'The threshold is the 8-point margin this project already requires '
          'between adjacent targets.',
      'Loan tenure gives 6.07 points a month and a ninety-day range gives '
          '3.69 points a day, both under it',
      () =>
          (HabotSliderOverNumericField.stepWidthDpFor(
                      HabotSliderOverNumericField.inputs[1]) -
                  6.074074074074074)
              .abs() <
              1e-9 &&
          (HabotSliderOverNumericField.stepWidthDpFor(
                      HabotSliderOverNumericField.inputs[3]) -
                  3.685393258426966)
              .abs() <
              1e-9,
    );

    gate(
      'GEN-04946-G5',
      'So two of the three sliders carry a readout and steppers.',
      'And the third, item quantity at 17.26 points a unit, does not',
      () =>
          HabotSliderOverNumericField.needingAReadout.length == 2 &&
          HabotSliderOverNumericField.stepIsWideEnough(
            HabotSliderOverNumericField.inputs[2],
          ),
    );
  });

  group('GEN-04946 :: the floor', () {
    gate(
      'GEN-04946-G6',
      'Floor: ">=95% of applicable screens/flows".',
      'Seven and a half of eight, so eight -- a slider on the mobile number '
          'and on the one-time passcode, which are not quantities',
      () =>
          HabotSliderOverNumericField.inputsRequiredAtTheFloor == 7.6 &&
          HabotSliderOverNumericField.theFloorWouldReachIdentifiers &&
          HabotSliderOverNumericField.identifiers.length == 3,
    );

    gate(
      'GEN-04946-G7',
      'The band leans on a word it never defines.',
      '"Applicable" carries the whole rule and is left undefined, so the '
          'floor becomes a floor over every numeric input',
      () =>
          HabotSliderOverNumericField.undefinedTerm == 'applicable' &&
          HabotSliderOverNumericField.floorNote
              .contains('no definition of applicable'),
    );
  });

  group('GEN-04946 :: the assistive-technology reading', () {
    gate(
      'GEN-04946-G8',
      'An adjustable control is operated by increment.',
      'On the amount field one increment is a fil and the range is ten '
          'million of them -- not slow to operate, not operable',
      () =>
          HabotSliderOverNumericField.incrementsAcrossTheAmountRange ==
              10000000 &&
          HabotSliderOverNumericField.anIncrementIsUnusableOnTheAmount,
    );

    gate(
      'GEN-04946-G9',
      'The rule was written without a condition.',
      'Which is the ordinary shape of an accessibility defect: not that '
          'nobody thought about it',
      () => HabotSliderOverNumericField.assistiveNote
          .contains('without a condition'),
    );

    gate(
      'GEN-04946-G10',
      'Output: Yes / No.',
      'Five declared obligations, all met, giving Yes; all nine declared '
          'checks hold',
      () =>
          HabotSliderOverNumericField.obligations.length == 5 &&
          HabotSliderOverNumericField.obligations.values.every((bool b) => b) &&
          HabotSliderOverNumericField.qualitativeOutput == 'Yes' &&
          HabotSliderOverNumericField.checks.length == 9 &&
          HabotSliderOverNumericField.checks.values.every((bool b) => b) &&
          HabotSliderOverNumericField.columnNote.contains('deep-link'),
    );
  });

  tearDownAll(() {
    final String perDp =
        HabotSliderOverNumericField.dirhamsPerDp.toStringAsFixed(2);
    final String perPx =
        HabotSliderOverNumericField.dirhamsPerPhysicalPixel.toStringAsFixed(2);
    final String sliders = HabotSliderOverNumericField.sliderInputs
        .map((HabotNumericInput i) => i.name)
        .join(', ');

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04946',
        atomicStepReferenceId: 'GEN-04946',
        setupStepAction:
            'COLUMN NOTE: every narrative column on this row is the generic '
            'engineering-console boilerplate -- "Read-only M3 KPI cards with '
            'deep-link drill-down", "Background polling refreshes data every '
            '30 seconds" -- on a row about which control a numeric value gets. '
            'Atomic Step: "Apply the mobile-first UX decision: Touch-optimized '
            'progress sliders over text field numeric inputs."',
        implementationOrder: 301,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Apply the mobile-first UX decision':
              'applied to $sliders, and refused on the five inputs that are '
                  'entered rather than chosen',
          'Completion Status': 'Yes',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Data Quality Note':
              'AMOUNT: ${HabotSliderOverNumericField.amountNote} '
              'FLOOR: ${HabotSliderOverNumericField.floorNote} '
              'ASSISTIVE: ${HabotSliderOverNumericField.assistiveNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UX Decision Adoption Consistency',
            observed:
                '37.5% -- 3 of 8 numeric inputs -- against a floor of 95%. '
                'Meeting the floor would require a slider on the mobile '
                'number and the one-time passcode, which are identifiers '
                'rather than quantities. The band leans on the word '
                '"applicable" and never defines it.',
            floor: '>=95% of applicable screens/flows apply the decision',
            optimal: '100% of applicable screens/flows',
            ceiling: '100% (full adoption is the ceiling)',
          ),
          AissMeasurement(
            metricName: 'Dirhams traversed per point of slider travel',
            observed:
                '$perDp on the amount field, about $perPx per physical pixel '
                'at 3x. The value a person means is not at any position on '
                'the track, so the control is not imprecise -- it cannot '
                'express the answer. That field keeps a numeric input.',
            floor: '0.01 (one fil per point would be reachable)',
            optimal: '0.01',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/slider_over_numeric_field.dart',
        ],
      ),
    );
  });
}
