// BPTR-0237-A01 + TTMCS-013-A01 — Design Token Definitions
// Single source of truth for all Habot design tokens in Flutter.
// Source: HABOT Design System Reference Guide (AS-160826)
// DO NOT hardcode any values outside this file.
// Reference: @habot/design-tokens-mobile | HC-FE-0001

// ─── COLOR TOKENS ────────────────────────────────────────────────────────────

abstract class HabotColorTokens {

  // ── Status Colors — fully defined from HABOT Design System Reference Guide ──

  // Success
  static const int successContainer   = 0xFFC6E8D9;
  static const int success            = 0xFF21B373;
  static const int successDark        = 0xFF086C44;
  static const int onSuccess          = 0xFFFFFFFF;

  // Error
  static const int errorContainer     = 0xFFF9DEDC;
  static const int error              = 0xFFE31B23;
  static const int errorDark          = 0xFF8B0811;
  static const int onError            = 0xFFFFFFFF;

  // Warning
  static const int warningContainer   = 0xFFFFE0B2;
  static const int warning            = 0xFFFF9800;
  static const int warningDark        = 0xFFE65100;
  static const int onWarning          = 0xFF000000;

  // Info
  static const int infoContainer      = 0xFFD1E7F7;
  static const int info               = 0xFF1976D2;
  static const int infoDark           = 0xFF0D47A1;
  static const int onInfo             = 0xFFFFFFFF;

  // ── Neutral Surfaces — defined from HABOT Design System Reference Guide ──
  static const int surfacePrimary     = 0xFFFFFBFE;
  static const int surfaceVariant     = 0xFF49454E;
  static const int outline            = 0xFF79747E;
  static const int background         = 0xFFFFFBFE;

  // ── MD3 Role Colors — pending Figma seed colors ──────────────────────────
  // Light Mode
  static const int lightPrimary              = _pending;
  static const int lightOnPrimary            = 0xFFFFFFFF;
  static const int lightPrimaryContainer     = _pending;
  static const int lightOnPrimaryContainer   = _pending;

  static const int lightSecondary            = _pending;
  static const int lightOnSecondary          = 0xFFFFFFFF;
  static const int lightSecondaryContainer   = _pending;
  static const int lightOnSecondaryContainer = _pending;

  static const int lightTertiary             = _pending;
  static const int lightOnTertiary           = 0xFFFFFFFF;
  static const int lightTertiaryContainer    = _pending;
  static const int lightOnTertiaryContainer  = _pending;

  static const int lightSurface                  = 0xFFFFFBFE;
  static const int lightOnSurface               = _pending;
  static const int lightSurfaceVariant          = 0xFF49454E;
  static const int lightOnSurfaceVariant        = _pending;
  static const int lightSurfaceContainerLowest  = _pending;
  static const int lightSurfaceContainerLow     = _pending;
  static const int lightSurfaceContainer        = _pending;
  static const int lightSurfaceContainerHigh    = _pending;
  static const int lightSurfaceContainerHighest = _pending;

  static const int lightOutline        = 0xFF79747E;
  static const int lightOutlineVariant = _pending;
  static const int lightScrim          = _pending;
  static const int lightShadow         = _pending;

  static const int lightInverseSurface   = _pending;
  static const int lightInverseOnSurface = _pending;
  static const int lightInversePrimary   = _pending;

  // Dark Mode
  static const int darkPrimary              = _pending;
  static const int darkOnPrimary            = _pending;
  static const int darkPrimaryContainer     = _pending;
  static const int darkOnPrimaryContainer   = _pending;

  static const int darkSecondary            = _pending;
  static const int darkOnSecondary          = _pending;
  static const int darkSecondaryContainer   = _pending;
  static const int darkOnSecondaryContainer = _pending;

  static const int darkTertiary             = _pending;
  static const int darkOnTertiary           = _pending;
  static const int darkTertiaryContainer    = _pending;
  static const int darkOnTertiaryContainer  = _pending;

  static const int darkSurface                  = _pending;
  static const int darkOnSurface               = _pending;
  static const int darkSurfaceVariant          = _pending;
  static const int darkOnSurfaceVariant        = _pending;
  static const int darkSurfaceContainerLowest  = _pending;
  static const int darkSurfaceContainerLow     = _pending;
  static const int darkSurfaceContainer        = _pending;
  static const int darkSurfaceContainerHigh    = _pending;
  static const int darkSurfaceContainerHighest = _pending;

  static const int darkOutline        = _pending;
  static const int darkOutlineVariant = _pending;
  static const int darkScrim          = _pending;
  static const int darkShadow         = _pending;

  static const int darkInverseSurface   = _pending;
  static const int darkInverseOnSurface = _pending;
  static const int darkInversePrimary   = _pending;

  // ── Jurisdiction Accents — pending brand/legal sign-off ──────────────────
  static const int dubaiAccentPrimary     = _pending;
  static const int dubaiAccentSecondary   = _pending;
  static const int dubaiOnAccentPrimary   = _pending;
  static const int dubaiOnAccentSecondary = _pending;

  static const int indiaAccentPrimary     = _pending;
  static const int indiaAccentSecondary   = _pending;
  static const int indiaOnAccentPrimary   = _pending;
  static const int indiaOnAccentSecondary = _pending;

  // ── AI Confidence Colors ─────────────────────────────────────────────────
  // Three-tier AI confidence colour coding — HABOT Design System Ch.5.8
  static const int aiConfidenceHigh   = 0xFF21B373; // ≥90% — auto-approve
  static const int aiConfidenceMedium = 0xFFFF9800; // 70–90% — proceed with caution
  static const int aiConfidenceLow    = 0xFFE31B23; // <70% — human review required

  // Sentinel — replace 0x00000000 with actual value when Figma seed is received
  static const int _pending = 0x00000000;
}

// ─── SPACING TOKENS — 8pt BASE GRID ─────────────────────────────────────────
// Source: HABOT Design System Reference Guide Ch.2.2
// Six approved spacing sizes — all values in dp.
// Extra small=4 · Small=8 · Medium=16 · Large=24 · Extra large=32 · 2XL=48

abstract class HabotSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double x2l = 48.0;
  static const double x3l = 64.0;

  // Semantic aliases
  static const double cardPadding        = md;
  static const double cardBorderWidth    = 1.0;
  static const double itemPadding        = sm;
  static const double itemGap            = sm;
  static const double textGapTight       = xs;
  static const double textGapNormal      = sm;
  static const double textGapLoose       = md;
  static const double formFieldGap       = md;
  static const double formSectionGap     = xl;
  static const double screenPaddingH     = md;
  static const double screenPaddingV     = lg;

  // Touch boundary tokens — WCAG 2.2 SC 2.5.8
  static const double touchTargetMin     = 44.0; // WCAG floor
  static const double touchTargetOptimal = 48.0; // iOS/MD3 standard
  static const double touchTargetSpacious = 56.0; // key actions

  // Page margins per breakpoint
  static const double mobileMargin  = 16.0;
  static const double tabletMargin  = 24.0;
  static const double desktopMargin = 32.0;

  // Grid gutters per breakpoint
  static const double mobileGutter  = 8.0;
  static const double tabletGutter  = 16.0;
  static const double desktopGutter = 24.0;
}

// ─── RADIUS TOKENS ───────────────────────────────────────────────────────────
// Source: HABOT Design System Reference Guide Ch.2.5

abstract class HabotRadius {
  static const double none = 0.0;    // Square, sharp corners
  static const double xs   = 4.0;   // Slight softening
  static const double sm   = 8.0;   // Chips, small buttons
  static const double md   = 12.0;  // Cards, text input fields
  static const double lg   = 16.0;  // Bottom sheets, large modals
  static const double xl   = 24.0;  // Extra-large feature components
  static const double full = 999.0; // Pill-shaped and circular elements
}

// ─── ELEVATION TOKENS ────────────────────────────────────────────────────────
// Source: HABOT Design System Reference Guide Ch.2.4

abstract class HabotElevation {
  static const double level0 = 0.0;  // Flat — resting on page
  static const double level1 = 1.0;  // Slightly raised — cards, resting buttons
  static const double level2 = 3.0;  // Noticeably raised — elements about to open modal
  static const double level3 = 6.0;  // Clearly floating — primary modal windows
  static const double level4 = 8.0;  // Strongly floating — important overlays
  static const double level5 = 12.0; // Highest — urgent attention content
}

// ─── TYPOGRAPHY TOKENS ───────────────────────────────────────────────────────
// Source: HABOT Design System Reference Guide Ch.2.3 & Ch.4
// Primary: Poppins / Inter. Fallback: San Francisco, Segoe UI, sans-serif.
// Weights: Regular (400), Medium (500), Bold (700).

abstract class HabotFontFamily {
  static const String display  = 'Poppins';
  static const String headline = 'Poppins';
  static const String title    = 'Poppins';
  static const String body     = 'Inter';
  static const String label    = 'Inter';
  static const String monospace = 'monospace'; // account numbers, IDs, codes
}

abstract class HabotFontSize {
  // Display — hero titles on landing/splash
  static const double displayLarge   = 57.0;
  static const double displayMedium  = 45.0;
  static const double displaySmall   = 36.0;

  // Headline — major/minor section titles
  static const double headlineLarge  = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall  = 24.0;

  // Title — card titles, modal headers, form section labels
  static const double titleLarge     = 22.0;
  static const double titleMedium    = 16.0;
  static const double titleSmall     = 14.0;

  // Body — everyday reading text, helper text, timestamps
  static const double bodyLarge      = 16.0;
  static const double bodyMedium     = 14.0;
  static const double bodySmall      = 12.0;

  // Label — button text, chips/tags, small badges
  static const double labelLarge     = 14.0;
  static const double labelMedium    = 12.0;
  static const double labelSmall     = 11.0;

  // Monospace — account numbers, transaction IDs, codes
  static const double monoDefault    = 14.0;
}

abstract class HabotFontWeight {
  static const int regular  = 400; // everyday reading text
  static const int medium   = 500; // titles and labels
  static const int bold     = 700; // strong emphasis
}

// ─── Z-INDEX LAYERING SCALE — BPTR-0377-A01 ─────────────────────────────────

abstract class HabotZIndex {
  static const int base         = 0;
  static const int stickyHeader = 10;
  static const int overlay      = 20;
  static const int modal        = 30;
  static const int shaktiAlert  = 40;
}

// ─── VIEWPORT SCALE TOKENS ───────────────────────────────────────────────────
// Source: HABOT Design System Reference Guide Ch.9

abstract class HabotViewportScale {
  static const double mobile  = 1.0;  // 360px+ — 4 columns
  static const double tablet  = 1.05; // 600px+ — 8 columns
  static const double desktop = 1.1;  // 1200px+ — 12 columns
}

// ─── GRID BREAKPOINTS ────────────────────────────────────────────────────────
// Source: HABOT Design System Reference Guide Ch.3

abstract class HabotBreakpoint {
  static const double mobile      = 360.0;
  static const double tablet      = 600.0;
  static const double tabletLarge = 840.0;
  static const double desktop     = 1200.0;
}

// ─── MOTION TOKENS ───────────────────────────────────────────────────────────
// Source: HABOT Design System Reference Guide Ch.8

abstract class HabotMotion {
  // Durations in milliseconds
  static const int durationShort1  = 50;
  static const int durationShort2  = 100;
  static const int durationShort3  = 150;
  static const int durationShort4  = 200;
  static const int durationMedium1 = 250;
  static const int durationMedium2 = 300;
  static const int durationLong1   = 350;
  static const int durationLong2   = 400;

  // Press scale for cards/buttons
  static const double pressScale    = 0.98;
  static const int    pressDuration = 150;

  // Stepper blocked opacity
  static const double blockedOpacity  = 0.4;
  static const double disabledOpacity = 0.38;
}

// ─── AI CONFIDENCE THRESHOLDS ────────────────────────────────────────────────
// Source: HABOT Design System Reference Guide Ch.5.8

abstract class HabotAiConfidence {
  static const double high   = 0.90; // ≥90% — auto-approve enabled
  static const double medium = 0.70; // 70–90% — proceed with caution
  static const double low    = 0.00; // <70% — human review required
}
