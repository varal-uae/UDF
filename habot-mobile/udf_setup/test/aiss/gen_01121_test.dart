/// AISS GATE -- Step 198 of 215
/// Global Reference ID:       GEN-01121
/// Atomic Steps Reference ID: GEN-01121
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build category cards with min 48x48dp touch target
///               dimensions."
/// Metric: Touch Target Size -- Floor ">=44x44dp", Optimal "48x48dp",
///         Ceiling "<=56x56dp". Pass/Fail.
///
/// READ LITERALLY AGAINST STEP 184'S BAND, THIS ROW FAILS ITS OWN METRIC: a
/// category card is three times the ceiling. The band governs controls; a card
/// is an item surface. The exemption is written down and demonstrated rather
/// than left as the absence of a check.
library;

import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/discovery/category_card_target.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';
import 'package:udf_setup/design_system/tokens/touch_target_band.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double compliance = 0;

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

  group('GEN-01121 :: which things the band governs', () {
    gate(
      'GEN-01121-G1',
      'Metric: Touch Target Size, ceiling <=56x56dp. Step 184 built that '
          'ceiling because a target that is too large fires when nothing was '
          'aimed at it.',
      'The card surface is 144x160dp and Step 184 calls it too large -- so the '
          'exemption is load-bearing rather than decorative, and it is '
          'recorded with the reason rather than implied by nobody checking',
      () =>
          HabotCategoryCardTarget.cardSurfaceVerdictWithoutExemption ==
              HabotTouchVerdict.tooLarge &&
          HabotCategoryCardTarget.declaredExemptions.length == 1 &&
          HabotCategoryCardTarget
              .declaredExemptions['Category card surface']!
              .contains('one item and its whole area means the same thing') &&
          HabotCategoryCardTarget.exemptionIsWrittenDownNote
              .contains('indistinguishable from an oversight'),
    );

    gate(
      'GEN-01121-G2',
      'Atomic Step: "min 48x48dp touch target dimensions." The Step 184 floor '
          'is 44dp; the row asks for 48.',
      'The row is stricter than the band and is honoured as written: every '
          'control on this screen reaches the band OPTIMAL rather than merely '
          'clearing its floor',
      () =>
          HabotCategoryCardTarget.controlMinimumDp ==
              HabotTouchBand.optimalDp &&
          HabotCategoryCardTarget.controlMinimumDp >
              HabotTouchBand.floorDp &&
          HabotCategoryCardTarget.controlsMeetRowMinimum &&
          HabotCategoryCardTarget.stricterThanTheBandNote
              .contains('a row that loosens one'),
    );

    gate(
      'GEN-01121-G3',
      'A card is a surface that happens to be tappable; a control is a target.',
      'Every region is classified, the three controls are inside the Step 184 '
          'band, and the classification is what decides -- not the name of the '
          'region',
      () =>
          HabotCategoryCardTarget.regions.length == 4 &&
          HabotCategoryCardTarget.controls.length == 3 &&
          HabotCategoryCardTarget.controlsAreWithinBand &&
          HabotTapRegionKind.values.length == 2 &&
          HabotCategoryCardTarget.bandGovernsControlsNote
              .contains('widen the ceiling until nothing fails'),
    );
  });

  group('GEN-01121 :: the geometry', () {
    gate(
      'GEN-01121-G4',
      'Step 183 measured the 4dp grid at 96.97% and named the one offender. '
          'Nothing added after it should widen the gap.',
      'Both card dimensions come off the spacing ladder rather than being '
          'chosen: 144dp is three times the 48dp rung and 160dp is four times '
          'the 40dp rung, and both are multiples of the 4dp sub-baseline',
      () =>
          HabotCategoryCardTarget.cardWidthDp == HabotSpacing.xxxl * 3 &&
          HabotCategoryCardTarget.cardHeightDp == HabotSpacing.xxl * 4 &&
          HabotCategoryCardTarget.cardWidthDp %
                  HabotSpacing.subBaseline ==
              0 &&
          HabotCategoryCardTarget.cardHeightDp %
                  HabotSpacing.subBaseline ==
              0,
    );

    gate(
      'GEN-01121-G5',
      'Two adjacent cards with no gap between them are one tap region that '
          'opens the wrong category.',
      'The grid gap clears the separation floor, and the gap and the floor are '
          'both spacing tokens rather than numbers at the layout site',
      () =>
          HabotCategoryCardTarget.gridSeparationHolds &&
          HabotCategoryCardTarget.adjacentCardSeparationDp ==
              HabotSpacing.sm &&
          HabotCategoryCardTarget.separationFloorDp == HabotSpacing.xs &&
          HabotCategoryCardTarget.adjacentCardSeparationDp >
              HabotCategoryCardTarget.separationFloorDp,
    );

    gate(
      'GEN-01121-G6',
      'Step 184: "the band applies to the MINOR axis." A wide, short control '
          'passes on width and is missed by a finger on height.',
      'The availability chip is 120x48dp -- wide on one axis and exactly at '
          'the minimum on the other -- and is judged on the axis that decides '
          'whether a finger lands on it',
      () {
        final Size chip = HabotCategoryCardTarget.controls
            .firstWhere(
              (HabotCategoryRegion r) => r.label == 'Availability chip',
            )
            .size;
        return chip.width ==
                HabotCategoryCardTarget.cardWidthDp -
                    HabotCategoryCardTarget.cardPaddingDp * 2 &&
            chip.width == 120 &&
            chip.height == HabotTouchBand.optimalDp &&
            HabotTouchBand.minorOf(chip) == HabotTouchBand.optimalDp &&
            HabotTouchBand.majorOf(chip) == 120 &&
            HabotTouchBand.verdictFor(chip) == HabotTouchVerdict.optimal;
      },
    );

    gate(
      'GEN-01121-G7',
      'Metric: Touch Target Size -- Pass/Fail.',
      'Every declared check holds over the regions the band governs, giving a '
          'compliance rate of 1.0 and a Pass -- computed over controls only, '
          'because including the exempt surface would report a failure that '
          'the exemption already answers',
      () {
        compliance = HabotCategoryCardTarget.complianceRate;
        return compliance == 1.0 &&
            HabotCategoryCardTarget.checks.length == 7 &&
            HabotCategoryCardTarget.checks.values.every((bool b) => b) &&
            HabotCategoryCardTarget.isPass &&
            HabotCategoryCardTarget.qualitativeOutput == 'Pass' &&
            HabotCategoryCardTarget.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01121',
        atomicStepReferenceId: 'GEN-01121',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Build category cards with min 48x48dp touch target '
            'dimensions."',
        implementationOrder: 198,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotCategoryCardTarget',
          'Component Properties':
              'Card ${HabotCategoryCardTarget.cardWidthDp.toStringAsFixed(0)}'
              'x${HabotCategoryCardTarget.cardHeightDp.toStringAsFixed(0)}dp; '
              '${HabotCategoryCardTarget.controls.length} controls at or above '
              '${HabotCategoryCardTarget.controlMinimumDp.toStringAsFixed(0)}'
              'dp on the minor axis; grid gap '
              '${HabotCategoryCardTarget.gridGapDp.toStringAsFixed(0)}dp; one '
              'declared exemption with its rationale',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: read literally against the Step 184 band this row '
              'fails its own metric. A category card is 144x160dp and the '
              'band\'s ceiling is 56dp, so the card is out of band the moment '
              'it exists. The ceiling is not wrong -- it stops an ambiguous '
              'region being called a button -- but it governs CONTROLS, and a '
              'card is an item surface whose whole area means one thing. The '
              'exemption is declared with its rationale and the audit '
              'demonstrates the card would fail without it, so the exemption '
              'is load-bearing rather than the absence of a check. SECOND '
              'READING: the row asks for 48dp where the band floor is 44dp. '
              'That is STRICTER, so it is honoured as written and the '
              'controls on this screen must reach the band optimal. A row that '
              'tightens a standard is followed; a row that loosens one is the '
              'case that needs an argument.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Touch Target Size',
            observed:
                '${(compliance * 100).toStringAsFixed(0)}% -- '
                '${HabotCategoryCardTarget.controls.length} of '
                '${HabotCategoryCardTarget.controls.length} controls at or '
                'above 48dp on the minor axis: favourite toggle 48x48, '
                'availability chip 120x48, overflow 48x48. The card surface is '
                'exempt by kind, and would read as tooLarge if it were not.',
            floor: '>=44x44dp',
            optimal: '48x48dp',
            ceiling: '<=56x56dp',
          ),
          AissMeasurement(
            metricName: 'Adjacent card separation',
            observed:
                '${HabotCategoryCardTarget.gridGapDp.toStringAsFixed(0)}dp '
                'against a floor of '
                '${HabotCategoryCardTarget.separationFloorDp'
                '.toStringAsFixed(0)}dp. Below the floor two cards read as '
                'one surface and the '
                'wrong category opens -- a failure that never appears in a '
                'touch-target audit because each card passes on its own.',
            floor: '8dp',
            optimal: '12dp',
            ceiling: 'n/a',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/discovery/category_card_target.dart',
        ],
      ),
    );
  });
}
