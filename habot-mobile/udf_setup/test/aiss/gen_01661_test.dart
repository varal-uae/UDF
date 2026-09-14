/// AISS GATE -- Step 183 of 195
/// Global Reference ID:       GEN-01661
/// Atomic Steps Reference ID: GEN-01661
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Map spacing and layout tokens directly to the 4px base grid."
/// Metric: Spacing Grid Consistency (%) -- Floor 95, Optimal 100,
///         Ceiling 100. Pass / Fail.
///
/// ASSERTED AT STEP 2, MEASURED HERE, AND THE MEASUREMENT FINDS SOMETHING. The
/// spacing scale is clean; the density figures derived from it are not. The
/// rate is reported as it comes out rather than engineered to a clean hundred
/// by excluding the one value that spoils it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tokens/grid_alignment.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';
import 'package:udf_setup/design_system/tokens/shape_tokens.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double consistency = 0;

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

  group('GEN-01661 :: the measurement', () {
    gate(
      'GEN-01661-G1',
      'Atomic Step: "Map spacing and layout tokens directly to the 4px base '
          'grid." The row says px; a Flutter surface measures in logical '
          'pixels.',
      'The grid unit is read from the Step 2 sub-baseline rather than restated '
          'as a literal, and the px/dp distinction is recorded -- a grid '
          'measured in physical pixels on a 3x device would be a third of the '
          'intended size',
      () =>
          HabotGridAlignment.baseDp == HabotGrid.subBaselineDp &&
          HabotGridAlignment.baseDp == 4 &&
          HabotGridAlignment.isOnGrid(16) &&
          HabotGridAlignment.isOnGrid(0) &&
          !HabotGridAlignment.isOnGrid(6) &&
          !HabotGridAlignment.isOnGrid(14) &&
          HabotGridAlignment.pxVersusDpNote.contains('logical pixel'),
    );

    gate(
      'GEN-01661-G2',
      '"Spacing and layout tokens" means the values that position or size '
          'content, across every family that declares one.',
      'The measurement covers the spacing scale, the density figures derived '
          'from it, the corner radii and the grid\'s own layout metrics -- '
          'thirty-three values, not just the nine everybody remembers',
      () {
        final Set<String> families = HabotGridAlignment.gridBearing
            .map((HabotGridMeasurement m) => m.family)
            .toSet();
        return HabotGridAlignment.measured == 33 &&
            families.length == 4 &&
            families.containsAll(
              <String>{'spacing', 'density', 'shape', 'grid'},
            ) &&
            HabotGridAlignment.gridBearing
                    .where((HabotGridMeasurement m) => m.family == 'spacing')
                    .length ==
                HabotSpacing.all.length + 2 &&
            HabotGridAlignment.gridBearing
                    .where((HabotGridMeasurement m) => m.family == 'shape')
                    .length ==
                HabotShape.allRadii.length;
      },
    );

    gate(
      'GEN-01661-G3',
      'Metric: Spacing Grid Consistency (%) -- floor 95, optimal 100.',
      'The rate is 96.97%: above the row\'s floor, below its optimal, with one '
          'value off the grid -- reported as measured rather than rounded to '
          'the answer the row would prefer',
      () {
        consistency = HabotGridAlignment.consistencyPercent;
        return HabotGridAlignment.aligned == 32 &&
            HabotGridAlignment.offGrid.length == 1 &&
            (consistency - (32 / 33) * 100).abs() < 0.0001 &&
            consistency > 96.9 &&
            consistency < 97.0 &&
            HabotGridAlignment.meetsFloor &&
            !HabotGridAlignment.meetsOptimal &&
            HabotGridAlignment.qualitativeOutput == 'Pass';
      },
    );

    gate(
      'GEN-01661-G4',
      '"A number with no information in it" is what excluding the offender '
          'would produce.',
      'The off-grid value is NAMED with its family, its value and how far off '
          'it is -- the comfortable-padding lower bound at 6dp, two from the '
          'nearest grid step, off-grid since Step 2 and unnoticed because it '
          'is a real MD3 density figure rather than a typo',
      () {
        final HabotGridMeasurement offender =
            HabotGridAlignment.offGrid.single;
        return offender.family == 'density' &&
            offender.name == 'optimalPaddingMin' &&
            offender.valueDp == HabotDensity.optimalPaddingMin &&
            offender.valueDp == 6 &&
            offender.offsetDp == 2 &&
            !offender.isOnGrid &&
            HabotGridAlignment.findings.single.contains('6dp') &&
            HabotGridAlignment.findings.single.contains('2dp off') &&
            HabotGridAlignment.notEngineeredNote
                .contains('no information in it');
      },
    );
  });

  group('GEN-01661 :: exclusions, by declaration', () {
    gate(
      'GEN-01661-G5',
      '"A 1dp hairline snapped to a 4dp grid becomes a 4dp bar -- four times '
          'the weight, on every bordered component."',
      'Every excluded value is a different KIND of quantity rather than an '
          'inconvenient spacing value, each with its reason, and the offending '
          '6dp padding is deliberately NOT among them',
      () {
        final String flattened = HabotGridAlignment.excluded.keys.join(' ');
        return HabotGridAlignment.excluded.length == 6 &&
            HabotGridAlignment.excluded.values
                .every((String r) => r.length > 40) &&
            flattened.contains('shape.borderWidth') &&
            flattened.contains('shape.full') &&
            flattened.contains('breakpointSm') &&
            flattened.contains('maxHeaderTitleChars') &&
            !flattened.contains('optimalPaddingMin') &&
            HabotGridAlignment.excluded['shape.borderWidth']!
                .contains('4dp bar') &&
            HabotGridAlignment.exclusionKindNote
                .contains('different act from excluding an inconvenient '
                    'value');
      },
    );

    gate(
      'GEN-01661-G6',
      'An exclusion list is only honest if the things on it would genuinely '
          'distort the measurement.',
      'The sentinel radius and the stroke widths are indeed off-grid -- so '
          'including them would have dropped the rate by three more values '
          'for reasons that say nothing about spacing discipline',
      () =>
          !HabotGridAlignment.isOnGrid(HabotShape.full) &&
          !HabotGridAlignment.isOnGrid(HabotShape.borderWidth) &&
          !HabotGridAlignment.isOnGrid(HabotShape.focusBorderWidth) &&
          // ...and the breakpoints happen to align anyway, which is a property
          // of the Material spec rather than evidence about this token set.
          HabotGridAlignment.isOnGrid(HabotGrid.breakpointSm) &&
          HabotGridAlignment.isOnGrid(HabotGrid.breakpointMd) &&
          HabotGridAlignment.isOnGrid(HabotGrid.minSupportedWidth),
    );

    gate(
      'GEN-01661-G7',
      'The spacing scale itself was the part that was asserted.',
      'Every value in the declared spacing scale and both baselines are on the '
          'grid, which is the half that was already true -- so the finding is '
          'in the derived density figures rather than in the scale',
      () =>
          HabotSpacing.all.every(HabotGridAlignment.isOnGrid) &&
          HabotGridAlignment.isOnGrid(HabotSpacing.baseline) &&
          HabotGridAlignment.isOnGrid(HabotSpacing.subBaseline) &&
          HabotGridAlignment.gridBearing
              .where((HabotGridMeasurement m) => m.family == 'spacing')
              .every((HabotGridMeasurement m) => m.isOnGrid) &&
          HabotGridAlignment.gridBearing
              .where((HabotGridMeasurement m) => m.family == 'grid')
              .every((HabotGridMeasurement m) => m.isOnGrid) &&
          HabotGridAlignment.assertedNeverMeasuredNote
              .contains('looks like it belongs'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01661',
        atomicStepReferenceId: 'GEN-01661',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Map spacing and layout tokens directly to the 4px base '
            'grid."',
        implementationOrder: 183,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotGridAlignment / HabotGridMeasurement',
          'Component Properties':
              '${HabotGridAlignment.measured} grid-bearing values measured '
              'across 4 families against a '
              '${HabotGridAlignment.baseDp.toStringAsFixed(0)}dp base grid; '
              '${HabotGridAlignment.excluded.length} declared exclusions, each '
              'a different kind of quantity with its reason',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the 4dp grid was asserted at Step 2 and never '
              'measured. The spacing scale is clean; HabotDensity.'
              'optimalPaddingMin is 6dp, off-grid since Step 2 and unnoticed '
              'because it is a real MD3 density figure rather than a typo -- '
              'it looks like it belongs. REPORTED AS MEASURED: adding 6dp to '
              'an exclusion list would produce a clean hundred with no '
              'information in it. The exclusions that ARE declared are '
              'different kinds of quantity -- a stroke width, a sentinel '
              'radius, a Material window size class, a character count -- and '
              'three of them are themselves off-grid, so including them would '
              'have moved the rate for reasons that say nothing about spacing '
              'discipline.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Spacing Grid Consistency (%)',
            observed:
                '${consistency.toStringAsFixed(2)}% -- '
                '${HabotGridAlignment.aligned} of '
                '${HabotGridAlignment.measured} grid-bearing values on the '
                '4dp grid. Above the floor of 95, below the optimal of 100. '
                'One offender: ${HabotGridAlignment.findings.join("; ")}',
            floor: '95',
            optimal: '100',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Families measured',
            observed:
                '4 -- spacing, density, shape and grid. The spacing scale and '
                'the grid metrics are fully aligned, which is the half that '
                'was already true; the finding is in the density figures '
                'derived from the scale, which nothing had ever checked.',
            floor: 'all declaring families',
            optimal: 'all declaring families',
            ceiling: 'all declaring families',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/grid_alignment.dart',
        ],
      ),
    );
  });
}
