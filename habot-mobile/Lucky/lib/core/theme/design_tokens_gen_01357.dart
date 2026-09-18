// GEN-01357 — Design Token Registry and M3 Base Layout Configuration.
// Imports and configures Material Design 3 design tokens (equivalent to @habot/ui-tokens) into the mobile client base layout, including responsive breakpoints, elevation, touch targets, and polling intervals.

import 'package:flutter/material.dart';

/// Mock data representing the imported `@habot/ui-tokens` registry.
/// In production, these values would be generated from a Figma/Style Dictionary pipeline.
class HabotUiTokens {
  HabotUiTokens._();

  // Color Tokens (Material You dynamic color fallbacks)
  static const Color primaryLight = Color(0xFF0061A4);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFD1E4FF);
  static const Color secondaryLight = Color(0xFF535F70);
  static const Color surfaceLight = Color(0xFFFDFCFF);
  static const Color backgroundLight = Color(0xFFFDFCFF);
  static const Color errorLight = Color(0xFFBA1A1A);

  static const Color primaryDark = Color(0xFF9ECAFF);
  static const Color onPrimaryDark = Color(0xFF003258);
  static const Color primaryContainerDark = Color(0xFF00497D);
  static const Color secondaryDark = Color(0xFFBBC7DB);
  static const Color surfaceDark = Color(0xFF1A1C1E);
  static const Color backgroundDark = Color(0xFF1A1C1E);
  static const Color errorDark = Color(0xFFFFB4AB);

  // Typography Tokens
  static const String fontFamily = 'Roboto';

  // Spacing & Sizing Tokens
  static const double touchTargetMinSize = 48.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Elevation Tokens (M3 Elevated Cards Level 2)
  static const double elevationLevel2 = 3.0;

  // Responsive Breakpoints
  static const double breakpointMobileMax = 599.0;
  static const double breakpointTabletMin = 600.0;
  static const double breakpointDesktopMin = 840.0;

  // Telemetry & Polling Configurations
  static const Duration livenessHandshakeInterval = Duration(seconds: 30);
  static const Duration backgroundPollingInterval = Duration(seconds: 30);
}

/// Metric configuration for Design Token Registry Adoption Rate.
class DesignTokenMetrics {
  DesignTokenMetrics._();

  static const String metricName = 'Design Token Registry Adoption Rate';
  static const double floorBoundary = 0.9;
  static const double optimalTarget = 1.0;
  static const double ceilingBoundary = 1.0;
  static const String referenceStandard = 'Material Design 3 Token Specification';
}

/// Status enum for qualitative output capture.
enum StepCompletionStatus {
  complete,
  partial,
  notComplete;

  String get label {
    switch (this) {
      case StepCompletionStatus.complete:
        return 'Complete';
      case StepCompletionStatus.partial:
        return 'Partial';
      case StepCompletionStatus.notComplete:
        return 'Not Complete';
    }
  }
}

/// Applies the imported UI tokens to generate the M3 ThemeData.
/// This serves as the baseline configuration for the mobile client layouts.
class HabotThemeConfig {
  HabotThemeConfig._();

  static ThemeData lightTheme(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: HabotUiTokens.primaryLight,
      brightness: Brightness.light,
      primary: HabotUiTokens.primaryLight,
      onPrimary: HabotUiTokens.onPrimaryLight,
      primaryContainer: HabotUiTokens.primaryContainerLight,
      secondary: HabotUiTokens.secondaryLight,
      surface: HabotUiTokens.surfaceLight,
      error: HabotUiTokens.errorLight,
    );

    return _buildThemeData(colorScheme);
  }

  static ThemeData darkTheme(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: HabotUiTokens.primaryDark,
      brightness: Brightness.dark,
      primary: HabotUiTokens.primaryDark,
      onPrimary: HabotUiTokens.onPrimaryDark,
      primaryContainer: HabotUiTokens.primaryContainerDark,
      secondary: HabotUiTokens.secondaryDark,
      surface: HabotUiTokens.surfaceDark,
      error: HabotUiTokens.errorDark,
    );

    return _buildThemeData(colorScheme);
  }

  static ThemeData _buildThemeData(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: HabotUiTokens.fontFamily,
      elevatedCardTheme: ElevatedCardThemeData(
        elevation: HabotUiTokens.elevationLevel2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(
          horizontal: HabotUiTokens.spacingSm,
          vertical: HabotUiTokens.spacingXs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

/// A reusable widget that enforces the 48x48dp minimum touch target requirement.
class AccessibleTouchTarget extends StatelessWidget {
  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: HabotUiTokens.touchTargetMinSize,
          minHeight: HabotUiTokens.touchTargetMinSize,
        ),
        child: Center(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: child,
        ),
      ),
    );
  }
}

/// Mock repository simulating telemetry event streaming to BigQuery.
class TelemetryMockRepository {
  Future<void> logStepExecutionEvent({
    required String atomicId,
    required StepCompletionStatus status,
    required String userId,
  }) async {
    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 80));
    debugPrint(
      '[BigQuery Mock] Stream Event -> '
      'atomic_id: $atomicId, '
      'status: ${status.label}, '
      'user_id: $userId, '
      'timestamp: ${DateTime.now().toIso8601String()}, '
      'partition: event_date, '
      'cluster: trace_id',
    );
  }
}