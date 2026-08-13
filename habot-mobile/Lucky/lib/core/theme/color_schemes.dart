import 'package:flutter/material.dart';
import 'design_tokens.dart';

// BPTR-0237-A01 — Color scheme definitions.
// Consumes HabotColorTokens exclusively — no hardcoded Color() values allowed.

final ColorScheme habotLightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary:            const Color(HabotColorTokens.lightPrimary),
  onPrimary:          const Color(HabotColorTokens.lightOnPrimary),
  primaryContainer:   const Color(HabotColorTokens.lightPrimaryContainer),
  onPrimaryContainer: const Color(HabotColorTokens.lightOnPrimaryContainer),

  secondary:            const Color(HabotColorTokens.lightSecondary),
  onSecondary:          const Color(HabotColorTokens.lightOnSecondary),
  secondaryContainer:   const Color(HabotColorTokens.lightSecondaryContainer),
  onSecondaryContainer: const Color(HabotColorTokens.lightOnSecondaryContainer),

  tertiary:            const Color(HabotColorTokens.lightTertiary),
  onTertiary:          const Color(HabotColorTokens.lightOnTertiary),
  tertiaryContainer:   const Color(HabotColorTokens.lightTertiaryContainer),
  onTertiaryContainer: const Color(HabotColorTokens.lightOnTertiaryContainer),

  error:            const Color(HabotColorTokens.lightError),
  onError:          const Color(HabotColorTokens.lightOnError),
  errorContainer:   const Color(HabotColorTokens.lightErrorContainer),
  onErrorContainer: const Color(HabotColorTokens.lightOnErrorContainer),

  surface:   const Color(HabotColorTokens.lightSurface),
  onSurface: const Color(HabotColorTokens.lightOnSurface),

  surfaceContainerLowest:  const Color(HabotColorTokens.lightSurfaceContainerLowest),
  surfaceContainerLow:     const Color(HabotColorTokens.lightSurfaceContainerLow),
  surfaceContainer:        const Color(HabotColorTokens.lightSurfaceContainer),
  surfaceContainerHigh:    const Color(HabotColorTokens.lightSurfaceContainerHigh),
  surfaceContainerHighest: const Color(HabotColorTokens.lightSurfaceContainerHighest),

  onSurfaceVariant: const Color(HabotColorTokens.lightOnSurfaceVariant),
  outline:          const Color(HabotColorTokens.lightOutline),
  outlineVariant:   const Color(HabotColorTokens.lightOutlineVariant),
  scrim:            const Color(HabotColorTokens.lightScrim),
  shadow:           const Color(HabotColorTokens.lightShadow),

  inverseSurface:   const Color(HabotColorTokens.lightInverseSurface),
  onInverseSurface: const Color(HabotColorTokens.lightInverseOnSurface),
  inversePrimary:   const Color(HabotColorTokens.lightInversePrimary),
);

final ColorScheme habotDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary:            const Color(HabotColorTokens.darkPrimary),
  onPrimary:          const Color(HabotColorTokens.darkOnPrimary),
  primaryContainer:   const Color(HabotColorTokens.darkPrimaryContainer),
  onPrimaryContainer: const Color(HabotColorTokens.darkOnPrimaryContainer),

  secondary:            const Color(HabotColorTokens.darkSecondary),
  onSecondary:          const Color(HabotColorTokens.darkOnSecondary),
  secondaryContainer:   const Color(HabotColorTokens.darkSecondaryContainer),
  onSecondaryContainer: const Color(HabotColorTokens.darkOnSecondaryContainer),

  tertiary:            const Color(HabotColorTokens.darkTertiary),
  onTertiary:          const Color(HabotColorTokens.darkOnTertiary),
  tertiaryContainer:   const Color(HabotColorTokens.darkTertiaryContainer),
  onTertiaryContainer: const Color(HabotColorTokens.darkOnTertiaryContainer),

  error:            const Color(HabotColorTokens.darkError),
  onError:          const Color(HabotColorTokens.darkOnError),
  errorContainer:   const Color(HabotColorTokens.darkErrorContainer),
  onErrorContainer: const Color(HabotColorTokens.darkOnErrorContainer),

  surface:   const Color(HabotColorTokens.darkSurface),
  onSurface: const Color(HabotColorTokens.darkOnSurface),

  surfaceContainerLowest:  const Color(HabotColorTokens.darkSurfaceContainerLowest),
  surfaceContainerLow:     const Color(HabotColorTokens.darkSurfaceContainerLow),
  surfaceContainer:        const Color(HabotColorTokens.darkSurfaceContainer),
  surfaceContainerHigh:    const Color(HabotColorTokens.darkSurfaceContainerHigh),
  surfaceContainerHighest: const Color(HabotColorTokens.darkSurfaceContainerHighest),

  onSurfaceVariant: const Color(HabotColorTokens.darkOnSurfaceVariant),
  outline:          const Color(HabotColorTokens.darkOutline),
  outlineVariant:   const Color(HabotColorTokens.darkOutlineVariant),
  scrim:            const Color(HabotColorTokens.darkScrim),
  shadow:           const Color(HabotColorTokens.darkShadow),

  inverseSurface:   const Color(HabotColorTokens.darkInverseSurface),
  onInverseSurface: const Color(HabotColorTokens.darkInverseOnSurface),
  inversePrimary:   const Color(HabotColorTokens.darkInversePrimary),
);
