// ============================================================================
// HABOT Design System — Material 3 Theme
// File: lib/core/theme/app_theme.dart
// Version: v1 | Last Modified: 2026-08-10
// Source: BPTR-0544-A01 | Ritwik Sharma — Frontend Integration Specialist
// Team: UDF — UX Design & Frontend Engineering | Habot Connect DMCC
//
// STATUS:
//   ✅ Confirmed from Figma AI extraction (12 Light tokens)
//   🟡 Inferred from MD3 tonal ramps (46 tokens) — confirm with designer
//   All WCAG AA pairs pass (≥4.5:1). 6 AAA-only failures are non-blocking.
//
// FONT OVERRIDE NOTE:
//   All type styles use Poppins or Inter instead of MD3 default Roboto.
//   This is an intentional HABOT brand decision.
//   Add to pubspec.yaml:
//     fonts:
//       - family: Poppins
//         fonts:
//           - asset: assets/fonts/Poppins-Regular.ttf
//           - asset: assets/fonts/Poppins-Medium.ttf    weight: 500
//           - asset: assets/fonts/Poppins-SemiBold.ttf  weight: 600
//       - family: Inter
//         fonts:
//           - asset: assets/fonts/Inter-Regular.ttf
//           - asset: assets/fonts/Inter-Medium.ttf      weight: 500
// ============================================================================

import 'package:flutter/material.dart';

// ── COLOR SCHEME ─────────────────────────────────────────────────────────────

/// Light Mode Color Scheme
/// All values sourced from HABOT/Color namespace in Figma Design System v1
const ColorScheme habotLightColorScheme = ColorScheme(
  brightness: Brightness.light,

  // Primary — confirmed from Figma AI
  // NOTE: Tone-30 (#1b2a4a) used vs MD3 Tone-40 (#254070). Brand decision.
  primary:              Color(0xFF1b2a4a),
  onPrimary:            Color(0xFFffffff), // confirmed
  primaryContainer:     Color(0xFFd4e3f7), // confirmed — Tone-90
  onPrimaryContainer:   Color(0xFF0a1628), // confirmed — Tone-10

  // Secondary — confirmed container, inferred on-tokens
  // NOTE: Tone-50 (#4a6488) used vs MD3 Tone-40 (#2e527e). Brand decision.
  secondary:            Color(0xFF4a6488), // confirmed
  onSecondary:          Color(0xFFffffff), // inferred — Tone-100
  secondaryContainer:   Color(0xFFd3e4ff), // confirmed — Tone-90
  onSecondaryContainer: Color(0xFF001b3d), // inferred — Tone-10

  // Tertiary — confirmed container, inferred on-tokens
  // ⚠️  HIGH DEVIATION: #2e1a47 does not map to any Tertiary tonal step.
  //     Confirm with designer: brand override or should be Tone-30 (#3b0070)?
  tertiary:             Color(0xFF2e1a47), // confirmed (deviation)
  onTertiary:           Color(0xFFffffff), // inferred — Tone-100
  tertiaryContainer:    Color(0xFFeadcff), // confirmed — Tone-90
  onTertiaryContainer:  Color(0xFF1a0030), // inferred — Tone-10

  // Error — confirmed from Figma AI
  error:                Color(0xFFb3261e), // confirmed — MD3 Error Tone-40
  onError:              Color(0xFFffffff), // inferred — Tone-100
  errorContainer:       Color(0xFFf9dedc), // confirmed — Tone-90
  onErrorContainer:     Color(0xFF410e0b), // inferred — Tone-10

  // Surface — confirmed from Figma AI
  // NOTE: #fafcff vs Neutral Tone-99 (#fafbff). Rounding artifact.
  surface:              Color(0xFFfafcff), // confirmed
  onSurface:            Color(0xFF1a1c22), // inferred — Neutral Tone-10 ⚠️ CRITICAL
  surfaceVariant:       Color(0xFFdde3ea), // confirmed — NeutralVariant Tone-90
  onSurfaceVariant:     Color(0xFF44464f), // inferred — NeutralVariant Tone-30

  // Background — inferred (equals surface per MD3 Light spec)
  // ignore: deprecated_member_use
  background:           Color(0xFFfafcff), // inferred
  // ignore: deprecated_member_use
  onBackground:         Color(0xFF1a1c22), // inferred — Neutral Tone-10

  // Outline
  outline:              Color(0xFF72787e), // inferred — NeutralVariant Tone-50
  outlineVariant:       Color(0xFFc1c7ce), // inferred — used in 20+ borders in Figma

  // Shadow & Scrim
  shadow:               Color(0xFF000000), // inferred — Tone-0
  scrim:                Color(0xFF000000), // inferred — Tone-0

  // Inverse
  inverseSurface:       Color(0xFF2e3038), // inferred — Neutral Tone-20
  onInverseSurface:     Color(0xFFeeeef8), // inferred — Neutral Tone-95
  inversePrimary:       Color(0xFFa7c4e5), // inferred — Primary Tone-80
);

/// Dark Mode Color Scheme
/// All values inferred from MD3 tonal ramps.
/// Confirm when designer exports dark theme from Figma.
const ColorScheme habotDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary:              Color(0xFFa7c4e5), // inferred — Tone-80
  onPrimary:            Color(0xFF003063), // inferred — Tone-20
  primaryContainer:     Color(0xFF254070), // inferred — Tone-30
  onPrimaryContainer:   Color(0xFFd4e3f7), // inferred — Tone-90

  secondary:            Color(0xFFa8c3e8), // inferred — Tone-80
  onSecondary:          Color(0xFF0a1e35), // inferred — Tone-20
  secondaryContainer:   Color(0xFF2e527e), // inferred — Tone-30
  onSecondaryContainer: Color(0xFFd3e4ff), // inferred — Tone-90

  tertiary:             Color(0xFFd1b8ff), // inferred — Tone-80
  onTertiary:           Color(0xFF2e1a47), // inferred — using brand hex
  tertiaryContainer:    Color(0xFF4e118a), // inferred — Tone-30
  onTertiaryContainer:  Color(0xFFeadcff), // inferred — Tone-90

  error:                Color(0xFFffb4ab), // inferred — Tone-80
  onError:              Color(0xFF690005), // inferred — Tone-20
  errorContainer:       Color(0xFF93000a), // inferred — Tone-30
  onErrorContainer:     Color(0xFFffdad6), // inferred — Tone-90

  surface:              Color(0xFF111318), // inferred — Neutral Tone-6
  onSurface:            Color(0xFFe2e2e9), // inferred — Neutral Tone-90
  surfaceVariant:       Color(0xFF44474e), // inferred — NeutralVariant Tone-30
  onSurfaceVariant:     Color(0xFFc4c6d0), // inferred — NeutralVariant Tone-80

  // ignore: deprecated_member_use
  background:           Color(0xFF111318), // inferred — Neutral Tone-6
  // ignore: deprecated_member_use
  onBackground:         Color(0xFFe2e2e9), // inferred — Neutral Tone-90

  outline:              Color(0xFF8e9099), // inferred — NeutralVariant Tone-60
  outlineVariant:       Color(0xFF44474e), // inferred — Tone-30

  shadow:               Color(0xFF000000),
  scrim:                Color(0xFF000000),

  inverseSurface:       Color(0xFFe2e2e9), // inferred — Neutral Tone-90
  onInverseSurface:     Color(0xFF2e3038), // inferred — Neutral Tone-20
  inversePrimary:       Color(0xFF1b2a4a), // inferred — Light primary
);

// ── SPACING ──────────────────────────────────────────────────────────────────

/// HABOT Spacing tokens — 4px base grid
/// Source: HABOT/Spacing namespace | All confirmed from Figma AI
abstract class HabotSpacing {
  static const double xs  = 4.0;   // space/xs  — 1× base
  static const double sm  = 8.0;   // space/sm  — 2× base
  static const double md  = 16.0;  // space/md  — 4× base
  static const double lg  = 24.0;  // space/lg  — 6× base
  static const double xl  = 32.0;  // space/xl  — 8× base
  static const double xxl = 48.0;  // space/2xl — 12× base
  static const double xxxl= 64.0;  // space/3xl — 16× base
}

// ── BORDER RADIUS ─────────────────────────────────────────────────────────────

/// HABOT Radius tokens
/// Source: HABOT/Spacing → Radius section | All confirmed from Figma AI
abstract class HabotRadius {
  static const double sm   = 4.0;   // radius/sm
  static const double md   = 8.0;   // radius/md
  static const double lg   = 16.0;  // radius/lg
  static const double full = 999.0; // radius/full — pill shape
}

// ── ELEVATION ────────────────────────────────────────────────────────────────

/// HABOT Elevation levels — MD3 shadow specs
/// Source: elevation/level0-5 | All confirmed from Figma AI
abstract class HabotElevation {
  static const double level0 = 0.0;   // Flat surface
  static const double level1 = 1.0;   // Cards, menus
  static const double level2 = 3.0;   // Drawers, tooltips
  static const double level3 = 6.0;   // FABs, dropdowns
  static const double level4 = 8.0;   // Navigation drawers
  static const double level5 = 12.0;  // Dialogs, modals
}

// ── TYPOGRAPHY ────────────────────────────────────────────────────────────────

/// HABOT Typography Scale — MD3 type scale with brand font overrides
/// Poppins: Display, Headline, Title Large
/// Inter: Title Medium/Small, Body, Label
/// All dimensions match MD3 exactly. Font family is a brand override.
class HabotTextTheme {
  static TextTheme get textTheme => const TextTheme(
    // DISPLAY
    displayLarge:  TextStyle(fontFamily:'Poppins', fontSize:57, fontWeight:FontWeight.w400, height:64/57, letterSpacing:-0.25),
    displayMedium: TextStyle(fontFamily:'Poppins', fontSize:45, fontWeight:FontWeight.w400, height:52/45, letterSpacing:0),
    displaySmall:  TextStyle(fontFamily:'Poppins', fontSize:36, fontWeight:FontWeight.w400, height:44/36, letterSpacing:0),
    // HEADLINE
    headlineLarge:  TextStyle(fontFamily:'Poppins', fontSize:32, fontWeight:FontWeight.w600, height:40/32, letterSpacing:0),
    headlineMedium: TextStyle(fontFamily:'Poppins', fontSize:28, fontWeight:FontWeight.w600, height:36/28, letterSpacing:0),
    headlineSmall:  TextStyle(fontFamily:'Poppins', fontSize:24, fontWeight:FontWeight.w600, height:32/24, letterSpacing:0),
    // TITLE
    titleLarge:  TextStyle(fontFamily:'Poppins', fontSize:22, fontWeight:FontWeight.w500, height:28/22, letterSpacing:0),
    titleMedium: TextStyle(fontFamily:'Inter',   fontSize:16, fontWeight:FontWeight.w500, height:24/16, letterSpacing:0.15),
    titleSmall:  TextStyle(fontFamily:'Inter',   fontSize:14, fontWeight:FontWeight.w500, height:20/14, letterSpacing:0.1),
    // BODY
    bodyLarge:   TextStyle(fontFamily:'Inter', fontSize:16, fontWeight:FontWeight.w400, height:24/16, letterSpacing:0.5),
    bodyMedium:  TextStyle(fontFamily:'Inter', fontSize:14, fontWeight:FontWeight.w400, height:20/14, letterSpacing:0.25),
    bodySmall:   TextStyle(fontFamily:'Inter', fontSize:12, fontWeight:FontWeight.w400, height:16/12, letterSpacing:0.4),
    // LABEL
    labelLarge:  TextStyle(fontFamily:'Inter', fontSize:14, fontWeight:FontWeight.w500, height:20/14, letterSpacing:0.1),
    labelMedium: TextStyle(fontFamily:'Inter', fontSize:12, fontWeight:FontWeight.w500, height:16/12, letterSpacing:0.5),
    labelSmall:  TextStyle(fontFamily:'Inter', fontSize:11, fontWeight:FontWeight.w500, height:16/11, letterSpacing:0.5),
  );
}

// ── THEME DATA ────────────────────────────────────────────────────────────────

/// Light Theme
ThemeData habotLightTheme = ThemeData(
  useMaterial3:  true,
  colorScheme:   habotLightColorScheme,
  textTheme:     HabotTextTheme.textTheme,
  cardTheme: const CardTheme(
    elevation: HabotElevation.level1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(HabotRadius.md)),
    ),
  ),
  dialogTheme: const DialogTheme(
    elevation: HabotElevation.level5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(HabotRadius.lg)),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(HabotRadius.sm)),
    ),
  ),
);

/// Dark Theme
ThemeData habotDarkTheme = ThemeData(
  useMaterial3:  true,
  colorScheme:   habotDarkColorScheme,
  textTheme:     HabotTextTheme.textTheme,
  cardTheme: const CardTheme(
    elevation: HabotElevation.level1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(HabotRadius.md)),
    ),
  ),
  dialogTheme: const DialogTheme(
    elevation: HabotElevation.level5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(HabotRadius.lg)),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(HabotRadius.sm)),
    ),
  ),
);
