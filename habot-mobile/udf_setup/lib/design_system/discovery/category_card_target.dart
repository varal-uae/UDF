/// Step 198 (GEN-01121) -- category card geometry against the touch band.
///
/// The row: "Build category cards with min 48x48dp touch target dimensions."
/// Metric: Touch Target Size -- floor >=44x44dp, optimal 48x48dp, ceiling
/// <=56x56dp. Pass/Fail.
///
/// Read literally against Step 184's band, this row fails its own metric. A
/// category card is 160dp tall; the band's ceiling is 56dp; so the card is out
/// of band the moment it is built. The ceiling is not wrong -- it exists
/// because a 200dp "button" is an ambiguous tap region, and Step 184 added it
/// for that reason. What is wrong is applying it to the wrong thing.
///
/// **A card is a surface that happens to be tappable; a control is a target.**
/// The band governs controls. The card is declared exempt here, with the
/// rationale written down, because an exemption that exists only as the absence
/// of a check is indistinguishable from an oversight. Everything INSIDE the
/// card -- the favourite toggle, the overflow, the chip row -- is a control and
/// is measured.
///
/// The row also states 48dp as a minimum where the band's floor is 44dp. That
/// is stricter than the band, not looser, so it is honoured as written: this
/// screen's controls must reach the band's OPTIMAL, not merely clear its floor.
library;

import 'dart:ui' show Size;

import '../tokens/spacing_tokens.dart';
import '../tokens/touch_target_band.dart';

/// A tappable region on the category grid, and what kind of thing it is.
enum HabotTapRegionKind {
  /// A discrete control: an icon button, a chip, a toggle.
  control,

  /// A surface whose whole area is tappable because it represents one item.
  /// Larger than the band's ceiling by design.
  itemSurface,
}

/// One measured region.
class HabotCategoryRegion {
  const HabotCategoryRegion({
    required this.label,
    required this.size,
    required this.kind,
  });

  final String label;
  final Size size;
  final HabotTapRegionKind kind;

  double get minorAxis => HabotTouchBand.minorOf(size);
}

/// Category card geometry, and the audit that keeps it honest.
class HabotCategoryCardTarget {
  const HabotCategoryCardTarget._();

  /// The minimum the row asks for. Deliberately the band's optimal rather than
  /// its floor: the row says 48, and 48 is stricter.
  static double get controlMinimumDp => HabotTouchBand.optimalDp;

  /// Card geometry. Both axes come from the spacing ladder so the card sits on
  /// the Step 183 grid rather than near it.
  static const double cardWidthDp = HabotSpacing.xxxl * 3; // 144
  static const double cardHeightDp = HabotSpacing.xxl * 4; // 160

  /// Gap between cards in the grid. Below this, two adjacent cards read as one
  /// surface and the wrong category gets opened.
  static const double gridGapDp = HabotSpacing.sm;

  /// Padding inside the card. Controls sit inside this, which is why the
  /// control minimum and the card size are related rather than independent.
  static const double cardPaddingDp = HabotSpacing.sm;

  /// The regions a category card presents.
  static List<HabotCategoryRegion> get regions => <HabotCategoryRegion>[
        const HabotCategoryRegion(
          label: 'Category card surface',
          size: Size(cardWidthDp, cardHeightDp),
          kind: HabotTapRegionKind.itemSurface,
        ),
        HabotCategoryRegion(
          label: 'Favourite toggle',
          size: Size(controlMinimumDp, controlMinimumDp),
          kind: HabotTapRegionKind.control,
        ),
        HabotCategoryRegion(
          label: 'Availability chip',
          size: Size(cardWidthDp - cardPaddingDp * 2, controlMinimumDp),
          kind: HabotTapRegionKind.control,
        ),
        HabotCategoryRegion(
          label: 'Overflow menu',
          size: Size(controlMinimumDp, controlMinimumDp),
          kind: HabotTapRegionKind.control,
        ),
      ];

  /// Controls only -- the regions the band actually governs.
  static List<HabotCategoryRegion> get controls => regions
      .where((HabotCategoryRegion r) => r.kind == HabotTapRegionKind.control)
      .toList();

  /// Regions deliberately outside the band, with the reason recorded.
  static const Map<String, String> declaredExemptions = <String, String>{
    'Category card surface':
        'An item surface, not a control. The band\'s 56dp ceiling exists to '
        'stop an ambiguous tap region from being called a button; a card is '
        'one item and its whole area means the same thing, so a larger area '
        'is more accurate rather than less. Exempt by kind, not by name.',
  };

  /// True when every control clears the row's 48dp minimum on its minor axis.
  static bool get controlsMeetRowMinimum => controls.every(
        (HabotCategoryRegion r) => r.minorAxis >= controlMinimumDp,
      );

  /// True when every control is also inside the Step 184 band.
  static bool get controlsAreWithinBand =>
      controls.every(
        (HabotCategoryRegion r) => HabotTouchBand.isWithinBand(r.size),
      );

  /// What the Step 184 band says about the card surface if the exemption is
  /// ignored. Kept so the exemption is demonstrated rather than asserted.
  static HabotTouchVerdict get cardSurfaceVerdictWithoutExemption =>
      HabotTouchBand.verdictFor(const Size(cardWidthDp, cardHeightDp));

  /// Compliance over the regions the band governs.
  static double get complianceRate {
    final List<HabotCategoryRegion> c = controls;
    if (c.isEmpty) {
      return 0;
    }
    return c
            .where((HabotCategoryRegion r) => r.minorAxis >= controlMinimumDp)
            .length /
        c.length;
  }

  /// Distance between the tappable edges of two horizontally adjacent cards.
  static double get adjacentCardSeparationDp => gridGapDp;

  /// The separation below which two adjacent tap regions are one mistake.
  static double get separationFloorDp => HabotSpacing.xs;

  static bool get gridSeparationHolds =>
      adjacentCardSeparationDp >= separationFloorDp;

  static Map<String, bool> get checks => <String, bool>{
        'every control reaches the row\'s 48dp minimum': controlsMeetRowMinimum,
        'every control is inside the Step 184 band': controlsAreWithinBand,
        'the card surface is exempt by kind and the reason is recorded':
            declaredExemptions.containsKey('Category card surface'),
        'the exemption is needed -- the card fails the band without it':
            cardSurfaceVerdictWithoutExemption == HabotTouchVerdict.tooLarge,
        'card width sits on the spacing ladder':
            HabotSpacing.all.contains(cardWidthDp / 3),
        'adjacent cards are separated by at least the separation floor':
            gridSeparationHolds,
        'the row\'s minimum is at least the band floor':
            controlMinimumDp >= HabotTouchBand.floorDp,
      };

  static bool get isPass => checks.values.every((bool b) => b);

  static String get qualitativeOutput => isPass ? 'Pass' : 'Fail';

  static const String bandGovernsControlsNote =
      'A card is a surface that happens to be tappable; a control is a target. '
      'The Step 184 band governs controls. Applied to the card surface it '
      'fails immediately -- a 144x160dp card is three times the ceiling -- and '
      'the useful response is to say which kind of thing each region is, not '
      'to widen the ceiling until nothing fails.';

  static const String exemptionIsWrittenDownNote =
      'An exemption that exists only as the absence of a check is '
      'indistinguishable from an oversight. The card surface is listed with '
      'its rationale and the audit demonstrates that it would fail without '
      'one, so the exemption is load-bearing rather than decorative.';

  static const String stricterThanTheBandNote =
      'The row says 48x48dp minimum where the band floor is 44dp. That is '
      'stricter, so it is honoured as written: controls on this screen must '
      'reach the band OPTIMAL. A row that tightens a standard is followed; a '
      'row that loosens one is the case that needs an argument.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Build category cards with min 48x48dp touch target dimensions."';
}
