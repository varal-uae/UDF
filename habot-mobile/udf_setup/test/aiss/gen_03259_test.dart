/// AISS GATE -- Step 228 of 235
/// Global Reference ID:       GEN-03259
/// Atomic Steps Reference ID: GEN-03259
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Set minimum touch targets for navigation tabs to 48x48dp."
/// Metric: Navigation Tab Touch Target -- Floor 48x48dp, Optimal 48x48dp,
///         Ceiling 64x64dp. Pass.
///
/// THE DRAWN THING AND THE TAPPABLE THING ARE DIFFERENT SIZES, AND THE DRAWN
/// ONE IS BELOW THE FLOOR. MD3's active indicator is 64x32dp; the target is the
/// whole 64dp destination cell. And the destination COUNT is a touch-target
/// constraint that nothing in the sheet mentions.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/interaction/touch_guideline.dart';
import 'package:udf_setup/design_system/navigation/nav_tab_targets.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';
import 'package:udf_setup/design_system/tokens/touch_target_band.dart';

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

  group('GEN-03259 :: drawn versus tappable', () {
    gate(
      'GEN-03259-G1',
      'Atomic Step: "Set minimum touch targets for navigation tabs to '
          '48x48dp." MD3 draws the active indicator at 64x32dp.',
      'The tappable part is the destination cell and the indicator is not '
          'tappable in its own right, so a designer measuring the indicator '
          'would report a failure that does not exist -- the same shape as the '
          '24dp Apply glyph inside a 56dp field at Step 206',
      () =>
          HabotNavTabTargets.partNamed('destination cell').isTappable &&
          !HabotNavTabTargets.partNamed('active indicator').isTappable &&
          !HabotNavTabTargets.partNamed('icon').isTappable &&
          HabotNavTabTargets.tappableParts.length == 1 &&
          HabotNavTabTargets.drawnPartsBelowTheFloor.length == 2 &&
          HabotNavTabTargets.partNamed('active indicator').minorAxisDp == 32 &&
          HabotNavTabTargets.drawnVersusTappableNote.contains('Step 206'),
    );

    gate(
      'GEN-03259-G2',
      'MD3 figures: an 80dp bar, a 64dp destination, a 24dp icon.',
      'The declared geometry matches MD3 and the target clears the row\'s 48dp '
          'minimum on its minor axis at the MD3 maximum of five destinations '
          'on the narrowest supported screen',
      () =>
          HabotNavTabTargets.barHeightDp == 80 &&
          HabotNavTabTargets.destinationHeightDp == 64 &&
          HabotNavTabTargets.iconSizeDp == 24 &&
          HabotNavTabTargets.indicatorWidthDp == 64 &&
          HabotNavTabTargets.indicatorHeightDp == 32 &&
          HabotNavTabTargets.targetClearsTheFloor &&
          HabotNavTabTargets.destinationWidthDp(
                HabotGrid.minSupportedWidth,
                HabotNavTabTargets.md3MaxDestinations,
              ) ==
              64,
    );

    gate(
      'GEN-03259-G3',
      'This row\'s ceiling is 64dp where Steps 227 and 229 say 56dp.',
      'The ceiling for this control class is resolved at Step 227 in this '
          'row\'s favour, so the target sits inside a 64dp ceiling that is '
          'above the general one rather than being forced down to it',
      () =>
          HabotNavTabTargets.ceilingDp == 64 &&
          HabotNavTabTargets.ceilingDp == HabotNavTabTargets.rowCeilingDp &&
          HabotNavTabTargets.ceilingDp >
              HabotTouchTargetGuideline.ceilingDp &&
          HabotNavTabTargets.targetIsWithinTheResolvedCeiling &&
          HabotTouchTargetGuideline.ceilingForControlClass(
                'navigation destination',
              ) ==
              64,
    );

    gate(
      'GEN-03259-G4',
      'Floor 48x48dp and optimal 48x48dp are the same number.',
      'The row leaves no band between its floor and its optimal, which is why '
          'its qualitative output is the single word "Pass" rather than a '
          'three-way grade -- recorded, because a band with no interior is a '
          'different kind of metric from the rest of the sheet',
      () =>
          HabotNavTabTargets.rowFloorDp == HabotNavTabTargets.rowOptimalDp &&
          HabotNavTabTargets.rowHasNoBandBetweenFloorAndOptimal &&
          HabotNavTabTargets.rowFloorDp == HabotNavTabTargets.optimalDp,
    );
  });

  group('GEN-03259 :: the destination count nobody called a constraint', () {
    gate(
      'GEN-03259-G5',
      '"A navigation bar divides its width equally."',
      'Seven destinations on the narrowest supported screen give a 45.7dp cell '
          '-- clearing the WCAG floor and failing the MD3 optimal -- and eight '
          'give 40dp, which fails both. The destination count is a '
          'touch-target constraint and nothing in the sheet says so',
      () =>
          HabotNavTabTargets.destinationWidthDp(
                HabotGrid.minSupportedWidth,
                7,
              ) <
              HabotNavTabTargets.optimalDp &&
          HabotNavTabTargets.verdictForCount(7) ==
              HabotTouchVerdict.withinFloor &&
          HabotNavTabTargets.verdictForCount(8) ==
              HabotTouchVerdict.tooSmall &&
          // And at five the GENERIC band calls the cell too large, which is
          // precisely the disagreement Step 227 resolves per control class.
          HabotNavTabTargets.verdictForCount(5) ==
              HabotTouchVerdict.tooLarge &&
          HabotNavTabTargets.targetIsWithinTheResolvedCeiling &&
          HabotNavTabTargets.countIsAConstraintNote
              .contains('nothing in the sheet says'),
    );

    gate(
      'GEN-03259-G6',
      'MD3 caps destinations at five, for reasons about attention rather than '
          'about fingers.',
      'The geometry admits six at the optimal and the MD3 cap is five, so the '
          'design system\'s cap is the tighter one -- which is the useful '
          'direction: following it keeps the fingers safe as a side effect',
      () =>
          HabotNavTabTargets.geometricMaxDestinations == 6 &&
          HabotNavTabTargets.md3MaxDestinations == 5 &&
          HabotNavTabTargets.md3MinDestinations == 3 &&
          HabotNavTabTargets.md3CapIsTighterThanGeometry &&
          HabotNavTabTargets.floorMaxDestinations == 7,
    );

    gate(
      'GEN-03259-G7',
      'Metric: Navigation Tab Touch Target -- 48 / 48 / 64. Pass.',
      'All ten checks hold and the step reports Pass, with the drawn parts '
          'below the floor reported as drawn rather than counted as failures',
      () =>
          HabotNavTabTargets.checks.length == 10 &&
          HabotNavTabTargets.checks.values.every((bool b) => b) &&
          HabotNavTabTargets.isPass &&
          HabotNavTabTargets.qualitativeOutput == 'Pass' &&
          HabotNavTabTargets.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03259',
        atomicStepReferenceId: 'GEN-03259',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Set minimum touch targets for navigation tabs to 48x48dp."',
        implementationOrder: 228,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotNavTabTargets',
          'Component Properties':
              'MD3 bar ${HabotNavTabTargets.barHeightDp.toStringAsFixed(0)}dp, '
              'destination '
              '${HabotNavTabTargets.destinationHeightDp.toStringAsFixed(0)}dp, '
              'active indicator '
              '${HabotNavTabTargets.indicatorWidthDp.toStringAsFixed(0)}x'
              '${HabotNavTabTargets.indicatorHeightDp.toStringAsFixed(0)}dp; '
              'ceiling ${HabotNavTabTargets.ceilingDp.toStringAsFixed(0)}dp '
              'resolved at Step 227 for this control class; destination count '
              'bounded by geometry at '
              '${HabotNavTabTargets.geometricMaxDestinations} and by MD3 at '
              '${HabotNavTabTargets.md3MaxDestinations}',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the drawn thing and the tappable thing are different '
              'sizes, and the drawn one is below the floor. MD3\'s active '
              'indicator is 64x32dp -- 32 is below the 48dp floor -- and the '
              'indicator is not the target; the whole 64dp destination cell '
              'is. A designer measuring the indicator reports a failure that '
              'does not exist; a developer sizing the target to the indicator '
              'creates one that does. Same shape as the 24dp Apply glyph '
              'inside a 56dp field at Step 206. SECOND FINDING: the '
              'destination COUNT is a touch-target constraint and nothing in '
              'the sheet says so. A navigation bar divides its width equally, '
              'so on the 320dp narrowest supported screen five destinations '
              'give 64dp, seven give 45.7dp -- clearing the WCAG floor and '
              'failing the MD3 optimal -- and eight give 40dp, failing both. '
              'The geometry admits six at the optimal; MD3 caps at five for '
              'reasons about attention. The design system\'s cap is the '
              'tighter one, which is the useful direction. THIRD: this row\'s '
              'ceiling is 64 where Steps 227 and 229 say 56, resolved at Step '
              '227 per control class in this row\'s favour. FOURTH: floor and '
              'optimal are the same number, so the band has no interior, which '
              'is why the qualitative output is the single word "Pass".',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Navigation Tab Touch Target',
            observed:
                'PASS. The destination cell is 64x64dp at the MD3 maximum of '
                'five destinations on the 320dp narrowest supported screen -- '
                'clearing the 48dp minimum and sitting exactly at the 64dp '
                'ceiling this row asks for. The two drawn parts below the '
                'floor, the 32dp indicator and the 24dp icon, are reported as '
                'drawn rather than counted as failures.',
            floor: '48x48dp',
            optimal: '48x48dp',
            ceiling: '64x64dp',
          ),
          AissMeasurement(
            metricName: 'Destinations the narrowest screen can carry',
            observed:
                '${HabotNavTabTargets.geometricMaxDestinations} at the 48dp '
                'optimal and ${HabotNavTabTargets.floorMaxDestinations} at the '
                '44dp floor, against an MD3 cap of '
                '${HabotNavTabTargets.md3MaxDestinations}. Following the '
                'design system keeps the fingers safe as a side effect, which '
                'is only true because the cap is tighter than the geometry.',
            floor: '<=7',
            optimal: '<=5',
            ceiling: '<=6',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/navigation/nav_tab_targets.dart',
        ],
      ),
    );
  });
}
