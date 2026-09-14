/// Step 228 (GEN-03259) -- touch targets on navigation tabs.
///
/// The row: "Set minimum touch targets for navigation tabs to 48x48dp."
/// Metric: Navigation Tab Touch Target -- floor 48x48dp, optimal 48x48dp,
/// **ceiling 64x64dp**. Pass.
///
/// **The drawn thing and the tappable thing are different sizes, and the drawn
/// one is smaller than the floor.** MD3's navigation bar is 80dp tall; each
/// destination is 64dp tall; the active indicator behind the icon is 64x32dp.
/// Thirty-two is below the 48dp floor -- so a designer measuring the indicator
/// reports a failure that does not exist, and a developer sizing the target to
/// the indicator creates one that does. Same shape as Step 206's 24dp Apply
/// glyph inside a 56dp field.
///
/// **This row's ceiling is 64, where Step 227's and Step 229's are 56.** The
/// disagreement is resolved at Step 227 in this row's favour, for this control
/// class only: a navigation destination's whole cell means one thing, so the
/// reason the band has a ceiling does not apply to it.
///
/// **The destination count is a touch-target constraint and nothing says so.**
/// A navigation bar divides its width equally, so on the narrowest supported
/// screen the per-destination width is 320dp divided by however many
/// destinations there are. Five gives 64dp. Seven gives 45.7dp, which clears
/// the WCAG floor and fails the MD3 optimal. Eight gives 40dp, which fails
/// both. MD3 caps destinations at five for reasons about attention; the
/// geometry caps them at six. The tighter cap is the one that gets quoted and
/// the looser one is the one that bites.
library;

import 'dart:ui' show Size;

import '../interaction/touch_guideline.dart';
import '../tokens/grid_tokens.dart';
import '../tokens/touch_target_band.dart';

/// One measured part of a navigation destination.
class HabotNavPart {
  const HabotNavPart({
    required this.label,
    required this.size,
    required this.isTappable,
  });

  final String label;
  final Size size;

  /// Whether a finger landing here activates the destination. The active
  /// indicator is drawn, not tappable in its own right.
  final bool isTappable;

  double get minorAxisDp => HabotTouchBand.minorOf(size);
}

/// The navigation bar.
class HabotNavTabTargets {
  const HabotNavTabTargets._();

  /// MD3 figures.
  static const double barHeightDp = 80;
  static const double destinationHeightDp = 64;
  static const double indicatorWidthDp = 64;
  static const double indicatorHeightDp = 32;
  static const double iconSizeDp = 24;

  /// MD3's own cap on destinations, set for attention rather than geometry.
  static const int md3MaxDestinations = 5;
  static const int md3MinDestinations = 3;

  /// The ceiling this control class gets, resolved at Step 227.
  static double get ceilingDp => HabotTouchTargetGuideline
      .ceilingForControlClass('navigation destination');

  static double get floorDp => HabotTouchTargetGuideline.floorDp;
  static double get optimalDp => HabotTouchTargetGuideline.optimalDp;

  /// Width one destination gets on a bar of the given width.
  static double destinationWidthDp(double barWidthDp, int destinations) =>
      destinations == 0 ? 0 : barWidthDp / destinations;

  /// The target, which is the whole destination cell.
  static Size targetSizeFor(double barWidthDp, int destinations) => Size(
        destinationWidthDp(barWidthDp, destinations),
        destinationHeightDp,
      );

  /// The parts of a destination, drawn and tappable, at the narrowest
  /// supported width with the MD3 maximum number of destinations.
  static List<HabotNavPart> get parts => <HabotNavPart>[
        HabotNavPart(
          label: 'destination cell',
          size: targetSizeFor(
            HabotGrid.minSupportedWidth,
            md3MaxDestinations,
          ),
          isTappable: true,
        ),
        const HabotNavPart(
          label: 'active indicator',
          size: Size(indicatorWidthDp, indicatorHeightDp),
          isTappable: false,
        ),
        const HabotNavPart(
          label: 'icon',
          size: Size(iconSizeDp, iconSizeDp),
          isTappable: false,
        ),
      ];

  static HabotNavPart partNamed(String label) =>
      parts.firstWhere((HabotNavPart p) => p.label == label);

  /// Only the tappable part is measured against the band. The drawn parts are
  /// measured too, and reported as drawn.
  static List<HabotNavPart> get tappableParts =>
      parts.where((HabotNavPart p) => p.isTappable).toList();

  static List<HabotNavPart> get drawnPartsBelowTheFloor => parts
      .where(
        (HabotNavPart p) => !p.isTappable && p.minorAxisDp < floorDp,
      )
      .toList();

  static bool get targetClearsTheFloor => tappableParts.every(
        (HabotNavPart p) => p.minorAxisDp >= optimalDp,
      );

  static bool get targetIsWithinTheResolvedCeiling => tappableParts.every(
        (HabotNavPart p) => p.minorAxisDp <= ceilingDp,
      );

  static const String drawnVersusTappableNote =
      'The active indicator is 64x32dp. Thirty-two is below the 48dp floor, '
      'and the indicator is not the target -- the whole 64dp destination cell '
      'is. A designer measuring the indicator reports a failure that does not '
      'exist; a developer sizing the target to the indicator creates one that '
      'does. Same shape as the 24dp Apply glyph inside a 56dp field at Step '
      '206.';

  // -----------------------------------------------------------------------
  // The destination count as a geometric constraint.
  // -----------------------------------------------------------------------

  /// The verdict for a bar with this many destinations, at the narrowest
  /// supported width.
  static HabotTouchVerdict verdictForCount(int destinations) =>
      HabotTouchBand.verdictFor(
        targetSizeFor(HabotGrid.minSupportedWidth, destinations),
      );

  /// The largest number of destinations whose cell still reaches the optimal
  /// on the narrowest supported screen.
  static int get geometricMaxDestinations {
    int best = md3MinDestinations;
    for (int n = md3MinDestinations; n <= 10; n++) {
      if (destinationWidthDp(HabotGrid.minSupportedWidth, n) >= optimalDp) {
        best = n;
      }
    }
    return best;
  }

  /// And the largest that clears the WCAG floor rather than the MD3 optimal.
  static int get floorMaxDestinations {
    int best = md3MinDestinations;
    for (int n = md3MinDestinations; n <= 10; n++) {
      if (destinationWidthDp(HabotGrid.minSupportedWidth, n) >= floorDp) {
        best = n;
      }
    }
    return best;
  }

  /// MD3's cap is tighter than the geometry, which is the useful direction:
  /// following the design system keeps the fingers safe as a side effect.
  static bool get md3CapIsTighterThanGeometry =>
      md3MaxDestinations < geometricMaxDestinations;

  static const String countIsAConstraintNote =
      'A navigation bar divides its width equally, so the per-destination '
      'width on the narrowest supported screen is 320dp over the destination '
      'count. Five gives 64dp; seven gives 45.7dp, which clears the WCAG floor '
      'and fails the MD3 optimal; eight gives 40dp and fails both. Nothing in '
      'the sheet says the destination count is a touch-target constraint, and '
      'it is.';

  // -----------------------------------------------------------------------
  // Metric: Navigation Tab Touch Target. 48 / 48 / 64. Pass.
  // -----------------------------------------------------------------------

  static const double rowFloorDp = 48;
  static const double rowOptimalDp = 48;
  static const double rowCeilingDp = 64;

  /// The row sets its floor and its optimal to the same number, so there is
  /// no band between them -- a target either is or is not compliant, which is
  /// why the qualitative output on this row is the single word "Pass".
  static bool get rowHasNoBandBetweenFloorAndOptimal =>
      rowFloorDp == rowOptimalDp;

  static Map<String, bool> get checks => <String, bool>{
        'the tappable target is the destination cell, not the indicator':
            partNamed('destination cell').isTappable &&
                !partNamed('active indicator').isTappable,
        'the target clears the row\'s 48dp minimum on its minor axis':
            targetClearsTheFloor,
        'and sits inside the 64dp ceiling this row asks for':
            targetIsWithinTheResolvedCeiling && ceilingDp == rowCeilingDp,
        'the drawn indicator is below the floor and is reported as drawn':
            drawnPartsBelowTheFloor.length == 2,
        'the resolved ceiling for this control class is 64, not 56':
            ceilingDp > HabotTouchTargetGuideline.ceilingDp,
        'five destinations give a 64dp cell on the narrowest screen':
            destinationWidthDp(HabotGrid.minSupportedWidth, 5) == 64,
        'the geometry admits six at the optimal and the MD3 cap is five':
            geometricMaxDestinations == 6 &&
                md3CapIsTighterThanGeometry,
        'seven destinations clear the floor and fail the optimal':
            verdictForCount(7) == HabotTouchVerdict.withinFloor,
        'eight destinations fail the floor':
            verdictForCount(8) == HabotTouchVerdict.tooSmall,
        'the row leaves no band between its floor and its optimal':
            rowHasNoBandBetweenFloorAndOptimal,
      };

  static bool get isPass => checks.values.every((bool b) => b);

  static String get qualitativeOutput => isPass ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Set minimum touch targets for navigation tabs to 48x48dp."';
}
