import 'package:flutter/material.dart';

/// Phase 1: Design Tokens & Theme Infrastructure
/// Central token registry for Material Design 3 Principles
class AppDesignTokens {
  AppDesignTokens._();

  // ==========================================================================
  // 1.1 Color Tokens
  // ==========================================================================
  
  // Primary & Accent Tokens
  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);

  // Status Tokens (Success, Error, Warning, Info)
  // Success Status Token Set
  static const Color successContainer = Color(0xFFC6E8D9);
  static const Color successMain = Color(0xFF21B373);
  static const Color successDark = Color(0xFF086C44);
  static const Color successText = Color(0xFFFFFFFF);

  // Error Status Token Set
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color errorMain = Color(0xFFE31B23);
  static const Color errorDark = Color(0xFF8B0811);
  static const Color errorText = Color(0xFFFFFFFF);

  // Warning Status Token Set
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color warningMain = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFE65100);
  static const Color warningText = Color(0xFF000000);

  // Info Status Token Set
  static const Color infoContainer = Color(0xFFD1E7F7);
  static const Color infoMain = Color(0xFF1976D2);
  static const Color infoDark = Color(0xFF0D47A1);
  static const Color infoText = Color(0xFFFFFFFF);

  // Neutral Surface Tokens
  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceVariant = Color(0xFF49454E);
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  static const Color darkOutlineVariant = Color(0xFF49454F);
  static const Color background = Color(0xFFFFFBFE);

  // Light Theme Tokens
  static const Color lightPrimary = Color(0xFF6750A4);
  static const Color lightSecondary = Color(0xFF625B71);
  static const Color lightTertiary = Color(0xFF7D5260);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightSurface = Color(0xFFFEF7FF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color lightOnSecondaryContainer = Color(0xFF1D192B);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFFD8E4);
  static const Color lightOnTertiaryContainer = Color(0xFF31111D);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFF9DEDC);
  static const Color lightOnErrorContainer = Color(0xFF410E0B);
  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightSurfaceContainer = Color(0xFFF3EDF7);
  static const Color lightSurfaceContainerHigh = Color(0xFFECE6F0);

  // Dark Theme Tokens
  static const Color darkPrimary = Color(0xFFD0BCFF);
  static const Color darkSecondary = Color(0xFFCCC2DC);
  static const Color darkTertiary = Color(0xFFEFB8C8);
  static const Color darkError = Color(0xFFF2B8B5);
  static const Color darkSurface = Color(0xFF141218);
  static const Color darkOnPrimary = Color(0xFF381E72);
  static const Color darkPrimaryContainer = Color(0xFF4F378B);
  static const Color darkOnPrimaryContainer = Color(0xFFEADDFF);
  static const Color darkOnSecondary = Color(0xFF332D41);
  static const Color darkSecondaryContainer = Color(0xFF4A4458);
  static const Color darkOnSecondaryContainer = Color(0xFFE8DEF8);
  static const Color darkOnTertiary = Color(0xFF492532);
  static const Color darkTertiaryContainer = Color(0xFF633B48);
  static const Color darkOnTertiaryContainer = Color(0xFFFFD8E4);
  static const Color darkOnError = Color(0xFF601410);
  static const Color darkErrorContainer = Color(0xFF8C1D18);
  static const Color darkOnErrorContainer = Color(0xFFF9DEDC);
  static const Color darkOnSurface = Color(0xFFE6E0E9);
  static const Color darkSurfaceContainer = Color(0xFF211F26);
  static const Color darkSurfaceContainerHigh = Color(0xFF2B2930);

  // Semantic Status Colors
  static const Color semanticSuccessLight = Color(0xFF0E9F6E);
  static const Color semanticErrorLight = Color(0xFFE02424);
  static const Color semanticSuccessDark = Color(0xFF31C48D);
  static const Color semanticErrorDark = Color(0xFFF87171);

  // Payment Status Tokens (SCTAS-013)
  static const Color paymentStatusErrorContainer = Color(0xFFFDE8E8);
  static const Color paymentStatusOnErrorContainer = Color(0xFF9B1C1C);
  static const Color paymentStatusSuccessContainer = Color(0xFFDEF7EC);
  static const Color paymentStatusOnSuccessContainer = Color(0xFF03543F);

  // ==========================================================================
  // 1.2 Spacing System (Six Fixed Tokens)
  // ==========================================================================
  static const double spaceXs = 4.0;   // tight gaps, icon padding
  static const double spaceS = 8.0;    // closely related items, mobile grid gutter
  static const double spaceM = 16.0;   // standard component padding, compact page margins
  static const double spaceL = 24.0;   // section spacing, tablet/desktop page margins
  static const double spaceXl = 32.0;  // generous desktop spacing
  static const double space2xl = 48.0; // major section breaks

  // ==========================================================================
  // 1.3 Typography Scale Tokens
  // ==========================================================================
  static const String fontFamilyPrimary = 'Inter';
  static const String fontFamilyFallback = 'Roboto';
  static const String fontFamilyMonospace = 'monospace';

  // Scale Tokens
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45.0,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36.0,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
  );

  /// Monospace Token for Entity IDs, currency fields, transaction IDs, hashes, account numbers
  static const TextStyle monospaceToken = TextStyle(
    fontFamily: fontFamilyMonospace,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ==========================================================================
  // 1.4 Elevation & Corner Radius Scale
  // ==========================================================================
  static const double elevation0 = 0.0;  // Flat
  static const double elevation1 = 2.0;  // Cards/resting buttons
  static const double elevation2 = 4.0;  // Raised elements
  static const double elevation3 = 8.0;  // Primary modals
  static const double elevation4 = 12.0; // Floating overlays
  static const double elevation5 = 16.0; // Urgent overlays

  static const double radiusNone = 0.0;
  static const double radiusXs = 4.0;
  static const double radiusSmall = 8.0;   // Chips, small buttons
  static const double radiusMedium = 12.0; // Cards, text inputs
  static const double radiusLarge = 16.0;  // Bottom sheets, modals
  static const double radiusXl = 24.0;     // Large feature components
  static const double radiusFull = 999.0;  // Pill-shaped elements
}
