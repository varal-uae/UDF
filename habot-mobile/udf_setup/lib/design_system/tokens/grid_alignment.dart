/// AISS Step 183 -- GEN-01661
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Map spacing and layout tokens directly to the 4px base grid."
/// Metric: Spacing Grid Consistency (%) -- Floor 95, Optimal 100, Ceiling 100.
///         Pass / Fail.
///
/// **THIS WAS ASSERTED AT STEP 2 AND NEVER MEASURED, AND MEASURING IT FINDS
/// SOMETHING.** The spacing scale is clean — every value in `HabotSpacing` is
/// a multiple of four. The *density* figures derived from it are not: the
/// lower bound of the comfortable-padding range is 6dp, which is off-grid and
/// has been since Step 2. It is a real MD3 density figure rather than a typo,
/// which is why nobody noticed: it looks like it belongs.
///
/// **THE RATE IS REPORTED AS IT IS, NOT ENGINEERED TO 100%.** The tempting
/// move is to add 6dp to an exclusion list and report a clean hundred. That
/// produces a number with no information in it. The value is counted, the rate
/// comes out at 96.97%, and the offender is named — which is above the row's
/// floor of 95 and below its optimal of 100, and is the truthful position.
///
/// **NOT EVERY NUMBER IN A TOKEN FILE IS A SPACING MEASURE, AND TREATING THEM
/// ALIKE IS THE OTHER WAY TO GET A MEANINGLESS FIGURE.** A 1dp hairline border
/// snapped to the grid becomes a 4dp bar. A corner radius of 999 is a sentinel
/// meaning "fully rounded", not a measurement. A 600dp breakpoint is a device
/// width class from the Material window-size specification, not a decision this
/// grid makes. Each of those is excluded **by declaration, with a reason**,
/// which is a different act from excluding an inconvenient value.
library;

import 'grid_tokens.dart';
import 'shape_tokens.dart';
import 'spacing_tokens.dart';

/// One token measured against the grid.
class HabotGridMeasurement {
  const HabotGridMeasurement({
    required this.name,
    required this.valueDp,
    required this.family,
  });

  final String name;
  final double valueDp;
  final String family;

  bool get isOnGrid => HabotGridAlignment.isOnGrid(valueDp);

  /// How far off, for a finding that says how bad rather than only that it is
  /// bad. A 6dp value is 2dp from the nearest grid step; a 7dp value is 1dp
  /// from one and would be a different conversation.
  double get offsetDp {
    final double m = valueDp % HabotGridAlignment.baseDp;
    return m == 0 ? 0 : (m < HabotGridAlignment.baseDp / 2
        ? m
        : HabotGridAlignment.baseDp - m);
  }

  @override
  String toString() => '$family.$name = ${valueDp.toStringAsFixed(0)}dp '
      '(${offsetDp.toStringAsFixed(0)}dp off the '
      '${HabotGridAlignment.baseDp.toStringAsFixed(0)}dp grid)';
}

/// Measures the token set against the 4dp base grid.
class HabotGridAlignment {
  const HabotGridAlignment._();

  /// The row says 4px. On a Flutter surface the unit is the logical pixel,
  /// which is what dp means here -- the same number, and the distinction is
  /// worth keeping because a "px" on a 3x device is not what the row means.
  static double get baseDp => HabotGrid.subBaselineDp;

  static bool isOnGrid(double dp) => dp % baseDp == 0;

  /// Every token that positions or sizes content. These are what "spacing and
  /// layout tokens" means.
  static List<HabotGridMeasurement> get gridBearing => <HabotGridMeasurement>[
        // The spacing scale.
        for (final double v in HabotSpacing.all)
          HabotGridMeasurement(
            name: 'scale[${v.toStringAsFixed(0)}]',
            valueDp: v,
            family: 'spacing',
          ),
        const HabotGridMeasurement(
          name: 'baseline',
          valueDp: HabotSpacing.baseline,
          family: 'spacing',
        ),
        const HabotGridMeasurement(
          name: 'subBaseline',
          valueDp: HabotSpacing.subBaseline,
          family: 'spacing',
        ),
        // The density figures derived from it.
        const HabotGridMeasurement(
          name: 'floorPadding',
          valueDp: HabotDensity.floorPadding,
          family: 'density',
        ),
        const HabotGridMeasurement(
          name: 'optimalPaddingMin',
          valueDp: HabotDensity.optimalPaddingMin,
          family: 'density',
        ),
        const HabotGridMeasurement(
          name: 'optimalPaddingMax',
          valueDp: HabotDensity.optimalPaddingMax,
          family: 'density',
        ),
        const HabotGridMeasurement(
          name: 'ceilingPadding',
          valueDp: HabotDensity.ceilingPadding,
          family: 'density',
        ),
        const HabotGridMeasurement(
          name: 'optimalRowHeightMin',
          valueDp: HabotDensity.optimalRowHeightMin,
          family: 'density',
        ),
        const HabotGridMeasurement(
          name: 'optimalRowHeightMax',
          valueDp: HabotDensity.optimalRowHeightMax,
          family: 'density',
        ),
        const HabotGridMeasurement(
          name: 'denseRowPadding',
          valueDp: HabotDensity.denseRowPadding,
          family: 'density',
        ),
        const HabotGridMeasurement(
          name: 'denseRowHeight',
          valueDp: HabotDensity.denseRowHeight,
          family: 'density',
        ),
        const HabotGridMeasurement(
          name: 'minTouchTarget',
          valueDp: HabotDensity.minTouchTarget,
          family: 'density',
        ),
        const HabotGridMeasurement(
          name: 'touchSafetyMargin',
          valueDp: HabotDensity.touchSafetyMargin,
          family: 'density',
        ),
        const HabotGridMeasurement(
          name: 'appBarHeight',
          valueDp: HabotDensity.appBarHeight,
          family: 'density',
        ),
        // Corner radii. A radius sizes the shape of a container, so it is a
        // layout measure; the "full" sentinel is excluded below.
        for (final double v in HabotShape.allRadii)
          HabotGridMeasurement(
            name: 'radius[${v.toStringAsFixed(0)}]',
            valueDp: v,
            family: 'shape',
          ),
        // The grid's own layout metrics.
        const HabotGridMeasurement(
          name: 'outerMargin',
          valueDp: HabotGrid.outerMargin,
          family: 'grid',
        ),
        const HabotGridMeasurement(
          name: 'gutter',
          valueDp: HabotGrid.gutter,
          family: 'grid',
        ),
        const HabotGridMeasurement(
          name: 'verticalRhythm',
          valueDp: HabotGrid.verticalRhythm,
          family: 'grid',
        ),
        const HabotGridMeasurement(
          name: 'baselineDp',
          valueDp: HabotGrid.baselineDp,
          family: 'grid',
        ),
        const HabotGridMeasurement(
          name: 'subBaselineDp',
          valueDp: HabotGrid.subBaselineDp,
          family: 'grid',
        ),
      ];

  /// Values in the token files that are NOT spacing measures, and why.
  ///
  /// **Declared exclusions, not convenient ones.** Every entry here is a
  /// different KIND of quantity, not a spacing value someone would rather not
  /// count. The offending 6dp padding is deliberately absent from this list.
  static const Map<String, String> excluded = <String, String>{
    'shape.full':
        'A sentinel meaning "fully rounded", not a measurement. 999dp is '
            'larger than any surface it is applied to; snapping it to the grid '
            'would change nothing and would imply it is a length.',
    'shape.borderWidth':
        'A stroke, not a space. A 1dp hairline snapped to a 4dp grid is a 4dp '
            'bar -- four times the intended weight, on every bordered '
            'component in the product.',
    'shape.focusBorderWidth':
        'As borderWidth. The 2dp focus ring is WCAG 2.4.11 territory and is '
            'sized against the thing it surrounds rather than against the '
            'grid.',
    'grid.breakpointSm / breakpointMd / breakpointXs':
        'Device width classes from the Material window-size specification. '
            'They are thresholds this grid is measured within, not decisions '
            'it makes. They happen to be multiples of four, which is a '
            'property of the Material spec rather than evidence about this '
            'token set.',
    'grid.minSupportedWidth / navigationCollapse / '
            'maxHardcodedWrapperWidth':
        'Viewport thresholds for the same reason.',
    'density.maxHeaderTitleChars':
        'A character count. Not a length at all.',
  };

  // ---- the row's metric ---------------------------------------------------

  static List<HabotGridMeasurement> get offGrid =>
      gridBearing.where((HabotGridMeasurement m) => !m.isOnGrid).toList();

  static int get measured => gridBearing.length;
  static int get aligned => measured - offGrid.length;

  /// Spacing Grid Consistency, as a percentage. Reported as measured.
  static double get consistencyPercent =>
      measured == 0 ? 100 : (aligned / measured) * 100;

  static const double floor = 95;
  static const double optimal = 100;
  static const double ceiling = 100;

  static bool get meetsFloor => consistencyPercent >= floor;
  static bool get meetsOptimal => consistencyPercent >= optimal;

  static String get qualitativeOutput => meetsFloor ? 'Pass' : 'Fail';

  /// The finding, named. Reported alongside the rate so the number is
  /// actionable rather than merely true.
  static List<String> get findings =>
      offGrid.map((HabotGridMeasurement m) => m.toString()).toList();

  static const String assertedNeverMeasuredNote =
      'The 4dp grid was asserted at Step 2 and never measured. The spacing '
      'scale is clean; the density figures derived from it are not. The lower '
      'bound of the comfortable-padding range is 6dp, off-grid since Step 2 '
      'and unnoticed because it is a real MD3 density figure rather than a '
      'typo -- it looks like it belongs.';

  static const String notEngineeredNote =
      'The tempting move is to add 6dp to an exclusion list and report a clean '
      'hundred, which produces a number with no information in it. The value '
      'is counted, the rate is what it is, and the offender is named.';

  static const String exclusionKindNote =
      'Not every number in a token file is a spacing measure. A 1dp hairline '
      'snapped to a 4dp grid becomes a 4dp bar -- four times the weight, on '
      'every bordered component. A radius of 999 is a sentinel meaning fully '
      'rounded. A 600dp breakpoint is a Material window size class. Each is '
      'excluded by declaration with a reason, which is a different act from '
      'excluding an inconvenient value.';

  static const String pxVersusDpNote =
      'The row says 4px. On a Flutter surface the unit is the logical pixel, '
      'which is what dp means here. The distinction is kept because a physical '
      'pixel on a 3x device is not what the row means, and a grid measured in '
      'those would be a third of the intended size.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
