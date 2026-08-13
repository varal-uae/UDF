// TTMCS-014-A01 — Liquid Glass Theme Config
// Master theme registry file: habot_design_tokens/themes/liquid_glass_config
// Reference: HC-DE-0274, HC-INF-0294
// Domain: UI/UX Design System Design
//
// All values are EMPTY — pending WCAG 4.5:1 contrast verification
// and design sign-off from the UI/UX Design System team.
//
// DO NOT hardcode any values outside this file.
// CI linter (lint_design_tokens.js) will block merges with raw hex overrides.

// ─── BRAND COLOR TOKENS ───────────────────────────────────────────────────────

abstract class LiquidGlassColors {

  // — Primary CTA — Habot Blue —
  // Spec: #2E86C1 — pending WCAG contrast verification
  static const int actionPrimary       = 0x00000000; // TODO: #2E86C1
  static const int actionOnPrimary     = 0x00000000; // TODO: contrast pair
  static const int actionPrimaryHover  = 0x00000000; // TODO: tonal variant
  static const int actionPrimaryFocus  = 0x00000000; // TODO: focus ring color

  // — Positive / Validation / Completion — Subtle Green —
  // Spec: #2ECC71 — pending WCAG contrast verification
  static const int stateSuccess        = 0x00000000; // TODO: #2ECC71
  static const int stateOnSuccess      = 0x00000000; // TODO: contrast pair
  static const int stateSuccessSubtle  = 0x00000000; // TODO: tonal container

  // — Background Containers —
  // Spec: white (#FFFFFF) or neutral off-white (#F4F7F9) only
  static const int backgroundPrimary   = 0x00000000; // TODO: #FFFFFF
  static const int backgroundSecondary = 0x00000000; // TODO: #F4F7F9
  static const int backgroundOnPrimary = 0x00000000; // TODO: contrast pair

  // — Surface overlays — Liquid Glass effect —
  static const int glassSurface        = 0x00000000; // TODO: semi-transparent white
  static const int glassBorder         = 0x00000000; // TODO: subtle border tint
  static const int glassBlur           = 0x00000000; // TODO: backdrop blur color
  static const int glassShadow         = 0x00000000; // TODO: drop shadow color
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
