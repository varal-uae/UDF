/// AISS: RCGLA-001-A01 -- substep 3 "Code standardized element elevation levels
/// and background shadow weight variables."
/// AISS: TTMCS-005-A01 -- "Define surface elevation tokens for dark mode" and
/// TTMCS-004 UX decision "Utilize structural elevation overlays instead of deep
/// drop shadows to indicate component layering in dark configurations."
///
/// Source of truth: `lib/design_system/tokens/tokens.json`.
library;

import 'dart:ui' show Color;

import 'color_tokens.dart';

/// Material 3 elevation levels 0-5.
enum HabotElevationLevel { level0, level1, level2, level3, level4, level5 }

class HabotElevation {
  const HabotElevation._();

  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 3;
  static const double level3 = 6;
  static const double level4 = 8;
  static const double level5 = 12;

  static const Map<HabotElevationLevel, double> dp =
      <HabotElevationLevel, double>{
        HabotElevationLevel.level0: level0,
        HabotElevationLevel.level1: level1,
        HabotElevationLevel.level2: level2,
        HabotElevationLevel.level3: level3,
        HabotElevationLevel.level4: level4,
        HabotElevationLevel.level5: level5,
      };

  /// Opacity of the primary tint composited over the dark neutral at each level.
  /// This is what replaces drop shadows in dark mode (TTMCS-004 UX decision).
  static const Map<HabotElevationLevel, double> darkOverlayAlpha =
      <HabotElevationLevel, double>{
        HabotElevationLevel.level0: 0.00,
        HabotElevationLevel.level1: 0.05,
        HabotElevationLevel.level2: 0.08,
        HabotElevationLevel.level3: 0.11,
        HabotElevationLevel.level4: 0.12,
        HabotElevationLevel.level5: 0.14,
      };

  /// Pre-computed, WCAG-audited dark surfaces. These are literal tokens rather
  /// than runtime blends so the contrast audit is deterministic and reviewable.
  static const Map<HabotElevationLevel, Color> darkSurfaceLadder =
      <HabotElevationLevel, Color>{
        HabotElevationLevel.level0: Color(0xFF101416),
        HabotElevationLevel.level1: Color(0xFF171D22),
        HabotElevationLevel.level2: Color(0xFF1B2329),
        HabotElevationLevel.level3: Color(0xFF1F2830),
        HabotElevationLevel.level4: Color(0xFF212A32),
        HabotElevationLevel.level5: Color(0xFF232E37),
      };

  /// In light mode the ladder maps onto the standard MD3 surface containers.
  static const Map<HabotElevationLevel, Color> lightSurfaceLadder =
      <HabotElevationLevel, Color>{
        HabotElevationLevel.level0: Color(0xFFFAFCFF),
        HabotElevationLevel.level1: Color(0xFFFFFFFF),
        HabotElevationLevel.level2: Color(0xFFF2F6FA),
        HabotElevationLevel.level3: Color(0xFFECF0F5),
        HabotElevationLevel.level4: Color(0xFFE6EAEF),
        HabotElevationLevel.level5: Color(0xFFE0E4EA),
      };

  /// Composite [tint] over [base] at [alpha], quantised to 8 bits per channel
  /// so the result is byte-identical to the audited literals above.
  ///
  /// Kept public because the TTMCS-005 gate re-derives [darkSurfaceLadder] with
  /// it and asserts the literals were not hand-edited into drift.
  static Color composite(Color tint, Color base, double alpha) {
    int channel(double t, double b) =>
        (((t * alpha) + (b * (1 - alpha))) * 255.0).round().clamp(0, 255);
    return Color.fromARGB(
      255,
      channel(tint.r, base.r),
      channel(tint.g, base.g),
      channel(tint.b, base.b),
    );
  }

  /// The surface a component at [level] must paint in dark mode.
  static Color darkSurfaceFor(HabotElevationLevel level) =>
      darkSurfaceLadder[level]!;

  /// Re-derives the dark ladder from first principles: primary tint over the
  /// level-0 neutral at the documented alpha. Used only by the gate.
  static Color deriveDarkSurface(HabotElevationLevel level) => composite(
    HabotColors.dark.primary,
    HabotColors.dark.surface,
    darkOverlayAlpha[level]!,
  );
}
