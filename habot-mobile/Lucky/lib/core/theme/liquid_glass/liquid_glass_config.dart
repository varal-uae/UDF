// TTMCS-014-A01 — Liquid Glass Theme Config
// Master theme registry file: habot_design_tokens/themes/liquid_glass_config
// Source: HABOT Design System Reference Guide (AS-160826)
// Reference: HC-DE-0274, HC-INF-0294
//
// Status colors, neutral surfaces, and typography fully populated.
// MD3 primary/secondary brand colors pending Figma seed.
// WCAG contrast verification required before merging brand colors.

import '../design_tokens.dart';

// ─── BRAND COLOR TOKENS ───────────────────────────────────────────────────────

abstract class LiquidGlassColors {

  // — Status colors — fully defined from design system doc —
  static const int success          = HabotColorTokens.success;         // #21B373
  static const int successContainer = HabotColorTokens.successContainer; // #C6E8D9
  static const int onSuccess        = HabotColorTokens.onSuccess;        // #FFFFFF

  static const int error            = HabotColorTokens.error;            // #E31B23
  static const int errorContainer   = HabotColorTokens.errorContainer;   // #F9DEDC
  static const int onError          = HabotColorTokens.onError;          // #FFFFFF

  static const int warning          = HabotColorTokens.warning;          // #FF9800
  static const int warningContainer = HabotColorTokens.warningContainer;  // #FFE0B2
  static const int onWarning        = HabotColorTokens.onWarning;        // #000000

  static const int info             = HabotColorTokens.info;             // #1976D2
  static const int infoContainer    = HabotColorTokens.infoContainer;    // #D1E7F7
  static const int onInfo           = HabotColorTokens.onInfo;           // #FFFFFF

  // — Neutral surfaces — defined —
  static const int surface          = HabotColorTokens.surfacePrimary;   // #FFFBFE
  static const int surfaceVariant   = HabotColorTokens.surfaceVariant;   // #49454E
  static const int outlineColor     = HabotColorTokens.outline;          // #79747E
  static const int background       = HabotColorTokens.background;       // #FFFBFE

  // — Primary CTA — pending Figma seed + WCAG verification —
  static const int actionPrimary       = 0x00000000;
  static const int actionOnPrimary     = 0xFFFFFFFF; // always white on primary
  static const int actionPrimaryHover  = 0x00000000;
  static const int actionPrimaryFocus  = 0x00000000;

  // — Success state (Subtle Green) — pending WCAG verification —
  static const int stateSuccess        = 0x00000000;
  static const int stateOnSuccess      = 0xFFFFFFFF;
  static const int stateSuccessSubtle  = 0x00000000;

  // — Backgrounds — pending WCAG verification —
  static const int backgroundPrimary   = 0x00000000; // #FFFFFF target
  static const int backgroundSecondary = 0x00000000; // #F4F7F9 target
  static const int backgroundOnPrimary = 0x00000000;

  // — Glass surface overlays —
  static const int glassSurface        = 0x00000000;
  static const int glassBorder         = 0x00000000;
  static const int glassBlur           = 0x00000000;
  static const int glassShadow         = 0x00000000;
}

// ─── TYPOGRAPHY SCALE CAPS ────────────────────────────────────────────────────
// Spec: clamp header heights on mobile screens.
// All values in sp — pending design sign-off.

abstract class LiquidGlassTypography {
  // Display caps — max size on mobile to prevent overflow
  static const double displayMaxMobile  = 0; // TODO: e.g. 40sp cap
  static const double headlineMaxMobile = 0; // TODO: e.g. 28sp cap
  static const double titleMaxMobile    = 0; // TODO: e.g. 20sp cap

  // Line height caps
  static const double displayLineHeightCap  = 0; // TODO:
  static const double headlineLineHeightCap = 0; // TODO:
  static const double titleLineHeightCap    = 0; // TODO:

  // Letter spacing (tracking)
  static const double trackingDisplay  = 0; // TODO:
  static const double trackingHeadline = 0; // TODO:
  static const double trackingBody     = 0; // TODO:
  static const double trackingLabel    = 0; // TODO:
}

// ─── TOUCH BOUNDARY TOKENS ────────────────────────────────────────────────────
// Spec: full-width horizontal click metrics on narrow display canvases.
// Button shapes map directly to factors of the 8dp grid.

abstract class LiquidGlassTouchBoundary {
  // Full-width touch — narrow screens (< 600dp)
  static const double buttonWidthNarrow   = double.infinity; // full-width enforced

  // Button height — 8dp grid factors
  static const double buttonHeightSm      = 0; // TODO: 40dp (8×5)
  static const double buttonHeightMd      = 0; // TODO: 48dp (8×6) — min touch target
  static const double buttonHeightLg      = 0; // TODO: 56dp (8×7)

  // Button border radius — 8dp grid factors
  static const double buttonRadiusSm      = 0; // TODO: 8dp
  static const double buttonRadiusMd      = 0; // TODO: 16dp
  static const double buttonRadiusFull    = 0; // TODO: 999dp (pill)

  // Minimum touch target — WCAG 2.5.5 AAA
  static const double touchTargetMin      = 0; // TODO: 48dp
}

// ─── GLASS EFFECT CONFIG ──────────────────────────────────────────────────────
// Liquid glass visual parameters — blur, opacity, border.

abstract class LiquidGlassEffect {
  static const double blurSigma          = 0; // TODO: backdrop blur sigma
  static const double surfaceOpacity     = 0; // TODO: glass surface opacity
  static const double borderOpacity      = 0; // TODO: glass border opacity
  static const double borderWidth        = 0; // TODO: glass border stroke
  static const double shadowBlurRadius   = 0; // TODO: drop shadow blur
  static const double shadowSpreadRadius = 0; // TODO: drop shadow spread
  static const double shadowOpacity      = 0; // TODO: drop shadow opacity
}
