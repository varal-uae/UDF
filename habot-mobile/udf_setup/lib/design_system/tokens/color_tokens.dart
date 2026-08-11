/// AISS: RCGLA-001-A01 (brand palette) + TTMCS-004-A01 (light/dark adaptation
/// tokens) + TTMCS-005-A01 (dark surface elevation ladder).
///
/// Source of truth: `lib/design_system/tokens/tokens.json`.
/// Mirror enforced by `test/guards/token_drift_test.dart`.
///
/// BRAND SIGN-OFF STATUS: PROVISIONAL.
/// RCGLA-001 lists "the exact primary corporate theme colors matching
/// accessibility contrast rules" as a decision required *before* the step.
/// Until Brand signs off, these values stand in. They are fully WCAG-audited,
/// so replacing them is a pure data edit -- the gates re-run unchanged.
library;

import 'dart:ui' show Color;

/// Every semantic colour role the app is allowed to reference.
///
/// Nothing outside this file may construct a `Color` literal -- the poka-yoke
/// guard in `test/guards/poka_yoke_no_hardcoded_values_test.dart` fails the
/// build if a raw hex appears anywhere else under `lib/`.
class HabotColorScheme {
  const HabotColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.outlineVariant,
    required this.inverseSurface,
    required this.onInverseSurface,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color outline;
  final Color outlineVariant;
  final Color inverseSurface;
  final Color onInverseSurface;

  /// Role name -> colour. Drives the contrast audit and the token-drift guard
  /// without any reflection.
  Map<String, Color> get roles => <String, Color>{
    'primary': primary,
    'onPrimary': onPrimary,
    'primaryContainer': primaryContainer,
    'onPrimaryContainer': onPrimaryContainer,
    'secondary': secondary,
    'onSecondary': onSecondary,
    'secondaryContainer': secondaryContainer,
    'onSecondaryContainer': onSecondaryContainer,
    'tertiary': tertiary,
    'onTertiary': onTertiary,
    'tertiaryContainer': tertiaryContainer,
    'onTertiaryContainer': onTertiaryContainer,
    'error': error,
    'onError': onError,
    'errorContainer': errorContainer,
    'onErrorContainer': onErrorContainer,
    'surface': surface,
    'onSurface': onSurface,
    'onSurfaceVariant': onSurfaceVariant,
    'surfaceContainerLowest': surfaceContainerLowest,
    'surfaceContainerLow': surfaceContainerLow,
    'surfaceContainer': surfaceContainer,
    'surfaceContainerHigh': surfaceContainerHigh,
    'surfaceContainerHighest': surfaceContainerHighest,
    'outline': outline,
    'outlineVariant': outlineVariant,
    'inverseSurface': inverseSurface,
    'onInverseSurface': onInverseSurface,
  };
}

class HabotColors {
  const HabotColors._();

  // --- Brand seeds (kept for MD3 tonal generation of any role we do not pin) ---
  static const Color seedPrimary = Color(0xFF00629B);
  static const Color seedSecondary = Color(0xFF00696E);
  static const Color seedTertiary = Color(0xFF6B5778);

  static const HabotColorScheme light = HabotColorScheme(
    primary: Color(0xFF00538A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCDE5FF),
    onPrimaryContainer: Color(0xFF001D33),
    secondary: Color(0xFF00565B),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFB0ECF1),
    onSecondaryContainer: Color(0xFF00201F),
    tertiary: Color(0xFF5A4666),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFF0DBFF),
    onTertiaryContainer: Color(0xFF231531),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFFAFCFF),
    onSurface: Color(0xFF1A1C1E),
    onSurfaceVariant: Color(0xFF41474D),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF2F6FA),
    surfaceContainer: Color(0xFFECF0F5),
    surfaceContainerHigh: Color(0xFFE6EAEF),
    surfaceContainerHighest: Color(0xFFE0E4EA),
    outline: Color(0xFF71787E),
    outlineVariant: Color(0xFFC1C7CE),
    inverseSurface: Color(0xFF2E3133),
    onInverseSurface: Color(0xFFF0F1F4),
  );

  static const HabotColorScheme dark = HabotColorScheme(
    primary: Color(0xFF9BCBFF),
    onPrimary: Color(0xFF003353),
    primaryContainer: Color(0xFF004A76),
    onPrimaryContainer: Color(0xFFCDE5FF),
    secondary: Color(0xFF8ED0D5),
    onSecondary: Color(0xFF00363A),
    secondaryContainer: Color(0xFF004F53),
    onSecondaryContainer: Color(0xFFB0ECF1),
    tertiary: Color(0xFFD6BEE4),
    onTertiary: Color(0xFF3B2948),
    tertiaryContainer: Color(0xFF523F5F),
    onTertiaryContainer: Color(0xFFF0DBFF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF101416),
    onSurface: Color(0xFFE2E2E6),
    onSurfaceVariant: Color(0xFFC1C7CE),
    // Dark surfaces ARE the elevation ladder -- see elevation_tokens.dart.
    surfaceContainerLowest: Color(0xFF101416),
    surfaceContainerLow: Color(0xFF171D22),
    surfaceContainer: Color(0xFF1B2329),
    surfaceContainerHigh: Color(0xFF1F2830),
    surfaceContainerHighest: Color(0xFF212A32),
    outline: Color(0xFF8B9198),
    outlineVariant: Color(0xFF41474D),
    inverseSurface: Color(0xFFE2E2E6),
    onInverseSurface: Color(0xFF2E3133),
  );

  // --- TTMCS-001: page frame gradient, minimises reading strain ---
  static const Color pageFrameLightStart = Color(0xFFF2F6F9);
  static const Color pageFrameLightEnd = Color(0xFFEEF2F6);
}
