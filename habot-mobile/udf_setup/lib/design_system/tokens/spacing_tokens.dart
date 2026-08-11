/// AISS: RCGLA-001-A01 -- substep 1 "Map semantic spacing constants
/// (margins, paddings, column gaps) inside theme configurations."
///
/// Source of truth: `lib/design_system/tokens/tokens.json`.
/// The values below are mirrored from that file and the mirror is enforced by
/// `test/guards/token_drift_test.dart`. Never edit one without the other.
library;

/// Semantic spacing ladder, locked to the 8dp baseline grid with a single
/// 4dp sub-baseline step (the Material accessibility floor named in TTMCS-004).
class HabotSpacing {
  const HabotSpacing._();

  static const double none = 0;
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 48;

  /// Every spacing value the design system exposes. The poka-yoke guard test
  /// walks this list; anything not divisible by [subBaseline] fails the build.
  static const List<double> all = <double>[
    none,
    xxs,
    xs,
    sm,
    md,
    lg,
    xl,
    xxl,
    xxxl,
  ];

  static const double baseline = 8;
  static const double subBaseline = 4;
}

/// Density constraints taken verbatim from the TTMCS-004 metric row
/// ("Material Design Density Compliance (dp)"): Floor / Optimal / Ceiling.
class HabotDensity {
  const HabotDensity._();

  /// Floor Boundary -- "4dp minimum spacing (Material Design accessibility floor)".
  static const double floorPadding = 4;

  /// Optimal Target -- "6-8dp padding".
  static const double optimalPaddingMin = 6;
  static const double optimalPaddingMax = 8;

  /// Ceiling Boundary -- "12dp (maximum density before readability/touch-target risk)".
  static const double ceilingPadding = 12;

  /// Optimal Target -- "32-48dp row height".
  static const double optimalRowHeightMin = 32;
  static const double optimalRowHeightMax = 48;

  /// The values this app actually ships for dense data rows. Both sit inside
  /// the optimal band above, which `test/aiss/ttmcs_004_test.dart` asserts.
  static const double denseRowPadding = 8;
  static const double denseRowHeight = 40;

  /// Minimum interactive target -- TTMAC-011 substep 1
  /// ("absolute minimum touch-target boundaries >= 48 x 48 dp").
  static const double minTouchTarget = 48;

  /// TTMAC-011 substep 3: "preserve an 8 dp safety spacing margin" between
  /// adjacent interactive elements.
  static const double touchSafetyMargin = 8;

  /// ANSA-012 UI implementation: "Secure the top app container height to an
  /// unyielding 64dp profile line."
  static const double appBarHeight = 64;

  /// ANSA-012 substep 1: "Cap maximum string titles to protect horizontal grid
  /// boundaries." 28 characters fits titleLarge (22sp) inside the content width
  /// of the narrowest supported device without eliding.
  static const int maxHeaderTitleChars = 28;
}
