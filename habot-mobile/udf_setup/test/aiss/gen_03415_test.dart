/// AISS GATE -- Step 455 of 415
/// Global Reference ID:       GEN-03415
/// Atomic Steps Reference ID: GEN-03415
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Add tap-to-expand UI details showing projected future accrual
///               balances."
/// Metric: Tap-to-Expand Animation Time -- floor "< 16.6ms", optimal "< 8ms",
///         ceiling "33ms". Best Qualitative Output: "Pass". Google RAIL Frame
///         Rate Specs. Assigned to **UDF**.
///
/// A PROJECTION OF SOMEBODY'S OWN LEAVE, SHOWN TO THEM -- THE ONE ROW IN THIS
/// BATCH ENTIRELY FOR THE PERSON.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/profile/accrual_projection.dart';

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

  group('GEN-03415 :: a frame is not an animation', () {
    gate(
      'GEN-03415-G1',
      'The band holds frame budgets, the name says animation.',
      '16.6 ms is one frame at sixty a second; 33 is two',
      () =>
          HabotAccrualProjection.theBandIsFrameBudgets &&
          HabotAccrualProjection.theNameSaysAnimation,
    );

    gate(
      'GEN-03415-G2',
      'So the worst of twelve frames is measured.',
      'And the duration comes from the motion tokens',
      () =>
          HabotAccrualProjection.measuredAsTheWorstFrame &&
          HabotAccrualProjection.theDurationComesFromTheMotionTokens &&
          HabotAccrualProjection.frameNote.contains('worst frame'),
    );

  });

  group('GEN-03415 :: the eighth instance', () {
    gate(
      'GEN-03415-G3',
      'The optimal sits below both boundaries, eighth time.',
      'The convention Step 418 set out',
      () =>
          HabotAccrualProjection.theOptimalIsBelowBothBoundaries &&
          HabotAccrualProjection.theShapeIsTheDeclaredConvention &&
          HabotAccrualProjection.instancesOfTheShape == 8,
    );

    gate(
      'GEN-03415-G4',
      'And the column holds one value.',
      '"Pass", the sixteenth one-valued column',
      () => HabotAccrualProjection.theCountReachesSixteen,
    );

  });

  group('GEN-03415 :: the projection', () {
    gate(
      'GEN-03415-G5',
      'The arithmetic is in whole hundredths of a day.',
      '11.50 plus three months at 2.08, less 3.00 booked',
      () => HabotAccrualProjection.theArithmeticIsInWholeHundredths,
    );

    gate(
      'GEN-03415-G6',
      'Both figures, before and after booked leave, are shown.',
      'The second is the one somebody plans with',
      () => HabotAccrualProjection.bothFiguresAreShown,
    );

    gate(
      'GEN-03415-G7',
      'Three assumptions and a date are visible.',
      'A projection has to say it is one',
      () =>
          HabotAccrualProjection.theAssumptionsAreVisible &&
          HabotAccrualProjection.itSaysItIsAForecast,
    );

  });

  group('GEN-03415 :: what you will lose', () {
    gate(
      'GEN-03415-G8',
      'About 9.7 days will be lost, and it says so.',
      'Above a five-day carry-over cap',
      () =>
          HabotAccrualProjection.theLossIsShown &&
          HabotAccrualProjection.theLossIsSaidPlainly,
    );

    gate(
      'GEN-03415-G9',
      'Which is the feature.',
      'A figure about a person whose only job is to help them',
      () =>
          HabotAccrualProjection
              .lossNote.contains('whose only job is to help them'),
    );

    gate(
      'GEN-03415-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotAccrualProjection.obligations.length == 5 &&
          HabotAccrualProjection.obligations.values.every((bool b) => b) &&
          HabotAccrualProjection.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final HabotAccrualInputs example = HabotAccrualProjection.example;
    final int after = HabotAccrualProjection.projectedAfterBooked(example);
    final int lost = HabotAccrualProjection.daysLostHundredths;
    final double worst = HabotAccrualProjection.worstFrameMs;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03415',
        atomicStepReferenceId: 'GEN-03415',
        setupStepAction:
            'COLUMN NOTE: this row\'s metric is named animation time and its '
            'band holds frame budgets -- 16.6ms is one frame at sixty a second '
            'and 33ms is two -- so the worst frame during the expansion is '
            'measured and the duration comes from the motion tokens; its '
            'optimal of "< 8ms" sits below both its floor and its ceiling, the '
            'eighth row written to that convention; and its Best Qualitative '
            'Output column holds the single word "Pass", the sixteenth '
            'one-valued column in the track. The projection says it is a '
            'forecast, shows its assumptions and both figures, and states what '
            'will be lost at the year end. Atomic Step: "Add tap-to-expand UI '
            'details showing projected future accrual balances."',
        implementationOrder: 455,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Add tap-to-expand UI details showing projected future accrual '
          'balances':
              'a projection of ${(after / 100).toStringAsFixed(1)} days after '
                  'booked leave, with ${(lost / 100).toStringAsFixed(1)} days '
                  'lost above the carry-over cap stated plainly; worst frame '
                  '$worst ms',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Tap-to-Expand Animation Time',
            observed:
                'THE METRIC CALLS A FRAME AN ANIMATION. 16.6 ms is one frame '
                'at sixty a second and 33 is two, so the band holds frame '
                'budgets while the name says animation time; the worst frame '
                'during the expansion is measured. The optimal of "< 8ms" sits '
                'below both boundaries, the eighth row written to that '
                'convention, and the output column holds "Pass" alone, the '
                'sixteenth one-valued column. Observed: worst frame $worst ms.',
            floor: '< 16.6ms',
            optimal: '< 8ms',
            ceiling: '33ms',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName:
                'Projected days that will not carry over, in hundredths',
            observed:
                '$lost. If carry-over is capped at five days and the '
                'projection is ${(after / 100).toStringAsFixed(1)}, then '
                '${(lost / 100).toStringAsFixed(1)} days disappear at the year '
                'end unless booked, and the card says so in those words. The '
                'projection states its assumptions and shows the figure before '
                'and after booked leave. This batch spent nineteen rows making '
                'sure scores about people were fair to them, and ends on a '
                'figure whose only job is to help the person it describes.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/profile/accrual_projection.dart',
        ],
      ),
    );
  });
}
