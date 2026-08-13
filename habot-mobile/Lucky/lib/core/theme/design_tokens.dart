// BPTR-0237-A01 — Design Token Definitions
// Single source of truth for all Habot design tokens in Flutter.
// All values are populated from tokens.json (Figma export).
// DO NOT hardcode any values outside this file.
// Reference: @habot/design-tokens-mobile | HC-FE-0001

// ─── COLOR TOKENS ────────────────────────────────────────────────────────────

abstract class HabotColorTokens {
  // — Light Mode —
  static const lightPrimary              = _empty;
  static const lightOnPrimary            = _empty;
  static const lightPrimaryContainer     = _empty;
  static const lightOnPrimaryContainer   = _empty;

  static const lightSecondary            = _empty;
  static const lightOnSecondary          = _empty;
  static const lightSecondaryContainer   = _empty;
  static const lightOnSecondaryContainer = _empty;

  static const lightTertiary             = _empty;
  static const lightOnTertiary           = _empty;
  static const lightTertiaryContainer    = _empty;
  static const lightOnTertiaryContainer  = _empty;

  static const lightError                = _empty;
  static const lightOnError              = _empty;
  static const lightErrorContainer       = _empty;
  static const lightOnErrorContainer     = _empty;

  static const lightSurface                  = _empty;
  static const lightOnSurface               = _empty;
  static const lightSurfaceVariant          = _empty;
  static const lightOnSurfaceVariant        = _empty;
  static const lightSurfaceContainerLowest  = _empty;
  static const lightSurfaceContainerLow     = _empty;
  static const lightSurfaceContainer        = _empty;
  static const lightSurfaceContainerHigh    = _empty;
  static const lightSurfaceContainerHighest = _empty;

  static const lightOutline        = _empty;
  static const lightOutlineVariant = _empty;
  static const lightScrim          = _empty;
  static const lightShadow         = _empty;

  static const lightInverseSurface   = _empty;
  static const lightInverseOnSurface = _empty;
  static const lightInversePrimary   = _empty;

  // — Dark Mode —
  static const darkPrimary              = _empty;
  static const darkOnPrimary            = _empty;
  static const darkPrimaryContainer     = _empty;
  static const darkOnPrimaryContainer   = _empty;

  static const darkSecondary            = _empty;
  static const darkOnSecondary          = _empty;
  static const darkSecondaryContainer   = _empty;
  static const darkOnSecondaryContainer = _empty;

  static const darkTertiary             = _empty;
  static const darkOnTertiary           = _empty;
  static const darkTertiaryContainer    = _empty;
  static const darkOnTertiaryContainer  = _empty;

  static const darkError                = _empty;
  static const darkOnError              = _empty;
  static const darkErrorContainer       = _empty;
  static const darkOnErrorContainer     = _empty;

  static const darkSurface                  = _empty;
  static const darkOnSurface               = _empty;
  static const darkSurfaceVariant          = _empty;
  static const darkOnSurfaceVariant        = _empty;
  static const darkSurfaceContainerLowest  = _empty;
  static const darkSurfaceContainerLow     = _empty;
  static const darkSurfaceContainer        = _empty;
  static const darkSurfaceContainerHigh    = _empty;
  static const darkSurfaceContainerHighest = _empty;

  static const darkOutline        = _empty;
  static const darkOutlineVariant = _empty;
  static const darkScrim          = _empty;
  static const darkShadow         = _empty;

  static const darkInverseSurface   = _empty;
  static const darkInverseOnSurface = _empty;
  static const darkInversePrimary   = _empty;

  // — Jurisdiction Accents —
  static const dubaiAccentPrimary     = _empty;
  static const dubaiAccentSecondary   = _empty;
  static const dubaiOnAccentPrimary   = _empty;
  static const dubaiOnAccentSecondary = _empty;

  static const indiaAccentPrimary     = _empty;
  static const indiaAccentSecondary   = _empty;
  static const indiaOnAccentPrimary   = _empty;
  static const indiaOnAccentSecondary = _empty;

  // — Warning Colors —
  // TTMCS-013-A01: unified warning color variables
  static const int lightWarning            = _empty;
  static const int lightOnWarning          = _empty;
  static const int lightWarningContainer   = _empty;
  static const int lightOnWarningContainer = _empty;

  static const int darkWarning             = _empty;
  static const int darkOnWarning           = _empty;
  static const int darkWarningContainer    = _empty;
  static const int darkOnWarningContainer  = _empty;

  // — Neutral Colors —
  // TTMCS-013-A01: unified neutral color variables
  static const int lightNeutral            = _empty;
  static const int lightOnNeutral          = _empty;
  static const int lightNeutralContainer   = _empty;
  static const int lightOnNeutralContainer = _empty;

  static const int darkNeutral             = _empty;
  static const int darkOnNeutral           = _empty;
  static const int darkNeutralContainer    = _empty;
  static const int darkOnNeutralContainer  = _empty;

  // — Success Colors —
  static const int lightSuccess            = _empty;
  static const int lightOnSuccess          = _empty;
  static const int lightSuccessContainer   = _empty;
  static const int lightOnSuccessContainer = _empty;

  static const int darkSuccess             = _empty;
  static const int darkOnSuccess           = _empty;
  static const int darkSuccessContainer    = _empty;
  static const int darkOnSuccessContainer  = _empty;

  // Sentinel — replace with actual 0xFFRRGGBB value from tokens.json
  static const int _empty = 0x00000000;
}

// ─── SPACING TOKENS — 8pt BASE GRID — TTMCS-013-A01 ─────────────────────────
// Strict 8pt base grid. All values must be multiples of 8.
// Used for: card borders, item padding, text gaps, form spacing.
// NO hardcoded numeric values allowed outside this class.

abstract class HabotSpacing {
  // — Base scale —
  static const double xs  = 0; // 4pt  (half-step, use sparingly)
  static const double sm  = 0; // 8pt
  static const double md  = 0; // 16pt
  static const double lg  = 0; // 24pt
  static const double xl  = 0; // 32pt
  static const double x2l = 0; // 48pt
  static const double x3l = 0; // 64pt

  // — Semantic aliases — card, item, text gap, form —
  static const double cardPadding        = md;  // internal card padding
  static const double cardBorderWidth    = 0;   // card border stroke width
  static const double itemPadding        = sm;  // list item internal padding
  static const double itemGap            = sm;  // gap between list items
  static const double textGapTight       = xs;  // gap between label + value
  static const double textGapNormal      = sm;  // gap between body paragraphs
  static const double textGapLoose       = md;  // gap between sections
  static const double formFieldGap       = md;  // vertical gap between form fields
  static const double formSectionGap     = xl;  // gap between form sections
  static const double screenPaddingH     = md;  // horizontal screen edge padding
  static const double screenPaddingV     = lg;  // vertical screen edge padding

  // — Touch boundary tokens — WCAG 2.5.5 AAA —
  static const double touchTargetMin     = 0;   // 48pt minimum touch target
  static const double touchTargetOptimal = 0;   // 56pt optimal touch target
}

// ─── RADIUS TOKENS ───────────────────────────────────────────────────────────

abstract class HabotRadius {
  static const double none = 0;
  static const double xs   = 0; // 2dp
  static const double sm   = 0; // 4dp
  static const double md   = 0; // 8dp
  static const double lg   = 0; // 16dp
  static const double xl   = 0; // 28dp
  static const double full = 0; // 999dp
}

// ─── ELEVATION TOKENS ────────────────────────────────────────────────────────

abstract class HabotElevation {
  static const double level0 = 0;
  static const double level1 = 0;
  static const double level2 = 0;
  static const double level3 = 0;
  static const double level4 = 0;
  static const double level5 = 0;
}

// ─── TYPOGRAPHY TOKENS ───────────────────────────────────────────────────────

abstract class HabotFontFamily {
  static const String display  = ''; // Poppins
  static const String headline = ''; // Poppins
  static const String title    = ''; // Poppins / Inter
  static const String body     = ''; // Inter
  static const String label    = ''; // Inter
}

abstract class HabotFontSize {
  static const double displayLarge   = 0; // 57sp
  static const double displayMedium  = 0; // 45sp
  static const double displaySmall   = 0; // 36sp
  static const double headlineLarge  = 0; // 32sp
  static const double headlineMedium = 0; // 28sp
  static const double headlineSmall  = 0; // 24sp
  static const double titleLarge     = 0; // 22sp
  static const double titleMedium    = 0; // 16sp
  static const double titleSmall     = 0; // 14sp
  static const double bodyLarge      = 0; // 16sp
  static const double bodyMedium     = 0; // 14sp
  static const double bodySmall      = 0; // 12sp
  static const double labelLarge     = 0; // 14sp
  static const double labelMedium    = 0; // 12sp
  static const double labelSmall     = 0; // 11sp
}

abstract class HabotFontWeight {
  static const int regular  = 0; // 400
  static const int medium   = 0; // 500
  static const int semiBold = 0; // 600
}

// ─── Z-INDEX LAYERING SCALE — BPTR-0377-A01 ─────────────────────────────────
// Fixed 5-level elevation scale. Hard-coded constants prevent arbitrary numbers.
// Shakti Alert is always the topmost layer — never obscured by any other element.
// Reference: Material Design elevation · Layout & Elevation Tokens

abstract class HabotZIndex {
  /// Level 1 — Base content: body, lists, cards, data tables.
  static const int base          = 0;

  /// Level 2 — Sticky headers: app bars, pinned column headers, tab bars.
  static const int stickyHeader  = 10;

  /// Level 3 — Overlays: dropdowns, tooltips, menus, bottom sheets, drawers.
  static const int overlay       = 20;

  /// Level 4 — Modals: dialogs, full-screen takeovers, side sheets.
  static const int modal         = 30;

  /// Level 5 — Shakti Alert: critical system alerts, force-upgrade banners.
  /// Always renders on top of everything. Must never be obscured.
  static const int shaktiAlert   = 40;
}

// ─── VIEWPORT SCALE TOKENS ───────────────────────────────────────────────────

abstract class HabotViewportScale {
  /// Applied to all font sizes on mobile (< 600dp)
  static const double mobile  = 0.0; // 1.0x

  /// Applied to all font sizes on tablet (600–1024dp)
  static const double tablet  = 0.0; // 1.05x

  /// Applied to all font sizes on desktop (> 1024dp)
  static const double desktop = 0.0; // 1.1x
}
