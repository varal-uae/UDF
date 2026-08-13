// TTMCS-013-A01 — Tiered Alias Token Layer.
// Tier 1: Primitive tokens  → HabotColorTokens, HabotSpacing, HabotRadius (design_tokens.dart)
// Tier 2: Semantic aliases  → this file — maps primitives to intent-based names
// Tier 3: Component tokens  → app_theme.dart consumes aliases
//
// Rule: widgets reference aliases, never primitives directly.
// Dark mode propagates automatically — zero code reworks needed.

import 'package:flutter/material.dart';

// ─── COLOR ALIASES ────────────────────────────────────────────────────────────

abstract class HabotColorAlias {
  // — Interactive —
  static Color actionPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static Color actionOnPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;
  static Color actionSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;
  static Color actionOnSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondary;

  // — Feedback states —
  static Color stateError(BuildContext context) =>
      Theme.of(context).colorScheme.error;
  static Color stateOnError(BuildContext context) =>
      Theme.of(context).colorScheme.onError;
  static Color stateErrorContainer(BuildContext context) =>
      Theme.of(context).colorScheme.errorContainer;
  static Color stateOnErrorContainer(BuildContext context) =>
      Theme.of(context).colorScheme.onErrorContainer;

  // — Surface —
  static Color surfaceDefault(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color surfaceOnDefault(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color surfaceSubtle(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLow;
  static Color surfaceElevated(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHigh;

  // — Text —
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  static Color textDisabled(BuildContext context) =>
      Theme.of(context).colorScheme.outline;
  static Color textOnAction(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  // — Border —
  static Color borderDefault(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;
  static Color borderStrong(BuildContext context) =>
      Theme.of(context).colorScheme.outline;
  static Color borderFocused(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static Color borderError(BuildContext context) =>
      Theme.of(context).colorScheme.error;
}

// ─── SPACING ALIASES ─────────────────────────────────────────────────────────

abstract class HabotSpacingAlias {
  // Display — large hero sections
  static const double displayGap     = 0; // x3l
  static const double displayPadding = 0; // x2l

  // Body — standard content areas
  static const double bodyGap        = 0; // md
  static const double bodyPadding    = 0; // md

  // Action labels — buttons, chips, tags
  static const double actionPaddingH = 0; // lg
  static const double actionPaddingV = 0; // sm
  static const double actionGap      = 0; // xs

  // Tracking — letter-spacing mapped values (in sp)
  static const double trackingTight  = 0; // -0.5sp
  static const double trackingNormal = 0; //  0sp
  static const double trackingWide   = 0; //  1.5sp
}

// ─── TYPOGRAPHY ALIASES ───────────────────────────────────────────────────────

abstract class HabotTypographyAlias {
  // Display roles
  static TextStyle? displayHero(BuildContext context) =>
      Theme.of(context).textTheme.displayLarge;
  static TextStyle? displaySection(BuildContext context) =>
      Theme.of(context).textTheme.displayMedium;

  // Headline roles
  static TextStyle? headingPage(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge;
  static TextStyle? headingCard(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall;

  // Body roles
  static TextStyle? bodyDefault(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;
  static TextStyle? bodySmall(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall;

  // Action label roles
  static TextStyle? labelButton(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge;
  static TextStyle? labelCaption(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall;
}
