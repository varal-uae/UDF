// SCTAS-013-A10 — DCYN Semantic Color Tokens and Theme Configuration.
// Establishes strict Material 3 semantic color tokens for system states, enforcing high-contrast accessibility and preventing hardcoded color usage across the UDF mobile application.

import 'package:flutter/material.dart';

/// Central Design System Tokens Vault for DCYN Semantic Colors.
/// All background, text, and border status fills must map exclusively to these boolean semantic token aliases.
/// Hardcoded hex values are strictly prohibited in component implementations.
class DcynSemanticColorTokens {
  const DcynSemanticColorTokens._();

  // --- Semantic State Definitions ---
  // Error / Quarantined / Blocked Pipeline
  static const Color errorContainerLight = Color(0xFFFFDAD6);
  static const Color onErrorContainerLight = Color(0xFF410002);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  // Success / Healthy Pipeline
  static const Color successContainerLight = Color(0xFFC4EED0);
  static const Color onSuccessContainerLight = Color(0xFF002106);
  static const Color successContainerDark = Color(0xFF005320);
  static const Color onSuccessContainerDark = Color(0xFFC4EED0);

  // Warning / Degraded Pipeline
  static const Color warningContainerLight = Color(0xFFFFE0B2);
  static const Color onWarningContainerLight = Color(0xFF3E2723);
  static const Color warningContainerDark = Color(0xFFF57C00);
  static const Color onWarningContainerDark = Color(0xFFFFE0B2);

  // Info / System Notification
  static const Color infoContainerLight = Color(0xFFBBDEFB);
  static const Color onInfoContainerLight = Color(0xFF0D47A1);
  static const Color infoContainerDark = Color(0xFF1976D2);
  static const Color onInfoContainerDark = Color(0xFFBBDEFB);

  /// Generates a strict M3 [ThemeData] using only pre-defined semantic tokens.
  /// Theme provider strictly accepts only pre-defined color variable tokens linked to verified data states.
  static ThemeData buildTheme({required Brightness brightness}) {
    final bool isLight = brightness == Brightness.light;

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF005320),
      brightness: brightness,
      errorContainer: isLight ? errorContainerLight : errorContainerDark,
      onErrorContainer: isLight ? onErrorContainerLight : onErrorContainerDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[
        DcynSemanticColorsExtension(
          successContainer: isLight ? successContainerLight : successContainerDark,
          onSuccessContainer: isLight ? onSuccessContainerLight : onSuccessContainerDark,
          warningContainer: isLight ? warningContainerLight : warningContainerDark,
          onWarningContainer: isLight ? onWarningContainerLight : onWarningContainerDark,
          infoContainer: isLight ? infoContainerLight : infoContainerDark,
          onInfoContainer: isLight ? onInfoContainerLight : onInfoContainerDark,
        ),
      ],
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        disabledColor: colorScheme.surfaceContainerHighest.withOpacity(0.38),
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.error,
        textColor: colorScheme.onError,
        padding: const EdgeInsets.all(4.0),
      ),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: isLight ? errorContainerLight : errorContainerDark,
        contentTextStyle: TextStyle(
          color: isLight ? onErrorContainerLight : onErrorContainerDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Custom Theme Extension to hold non-standard M3 semantic colors (Success, Warning, Info).
/// Enforces canonical naming conventions globally across components.
class DcynSemanticColorsExtension extends ThemeExtension<DcynSemanticColorsExtension> {
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color infoContainer;
  final Color onInfoContainer;

  const DcynSemanticColorsExtension({
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  @override
  DcynSemanticColorsExtension copyWith({
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return DcynSemanticColorsExtension(
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  DcynSemanticColorsExtension lerp(ThemeExtension<DcynSemanticColorsExtension>? other, double t) {
    if (other is! DcynSemanticColorsExtension) {
      return this;
    }
    return DcynSemanticColorsExtension(
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
    );
  }

  /// Helper to retrieve the extension from BuildContext safely.
  static DcynSemanticColorsExtension of(BuildContext context) {
    final extension = Theme.of(context).extension<DcynSemanticColorsExtension>();
    assert(extension != null, 'DcynSemanticColorsExtension is missing from ThemeData.');
    return extension!;
  }
}

/// Mock Data representing backend serverless DCYN evaluation responses.
/// Visual token states shift instantly based on these evaluated states.
class DcynMockEvaluationResponse {
  final String configurationParameter;
  final bool isHealthy;
  final bool isQuarantined;
  final bool isDegraded;
  final String currentSetting;
  final String previousSetting;
  final DateTime configurationTimestamp;

  const DcynMockEvaluationResponse({
    required this.configurationParameter,
    required this.isHealthy,
    required this.isQuarantined,
    required this.isDegraded,
    required this.currentSetting,
    required this.previousSetting,
    required this.configurationTimestamp,
  });
}

/// Static mock repository providing realistic local data for UI testing.
class DcynMockRepository {
  const DcynMockRepository._();

  static const List<DcynMockEvaluationResponse> pipelineStatuses = [
    DcynMockEvaluationResponse(
      configurationParameter: 'udf_pipeline_ingestion_rate',
      isHealthy: true,
      isQuarantined: false,
      isDegraded: false,
      currentSetting: '1000 req/s',
      previousSetting: '800 req/s',
      configurationTimestamp: DateTime(2026, 9, 25, 10, 0),
    ),
    DcynMockEvaluationResponse(
      configurationParameter: 'udf_pipeline_quarantine_block_alpha',
      isHealthy: false,
      isQuarantined: true,
      isDegraded: false,
      currentSetting: 'BLOCKED',
      previousSetting: 'ACTIVE',
      configurationTimestamp: DateTime(2026, 9, 25, 10, 5),
    ),
    DcynMockEvaluationResponse(
      configurationParameter: 'udf_pipeline_latency_threshold',
      isHealthy: false,
      isQuarantined: false,
      isDegraded: true,
      currentSetting: '450ms',
      previousSetting: '120ms',
      configurationTimestamp: DateTime(2026, 9, 25, 10, 12),
    ),
  ];
}

/// A sample widget demonstrating the strict application of semantic tokens.
/// Workers instantly spot quarantined data blocks without wading through text lists.
class DcynStatusChip extends StatelessWidget {
  final DcynMockEvaluationResponse status;

  const DcynStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = DcynSemanticColorsExtension.of(context);

    Color backgroundColor;
    Color foregroundColor;
    String label;

    // Strict indirection: mapping boolean states to semantic tokens, never hex codes directly.
    if (status.isQuarantined) {
      backgroundColor = theme.colorScheme.errorContainer;
      foregroundColor = theme.colorScheme.onErrorContainer;
      label = 'QUARANTINED';
    } else if (status.isDegraded) {
      backgroundColor = semanticColors.warningContainer;
      foregroundColor = semanticColors.onWarningContainer;
      label = 'DEGRADED';
    } else if (status.isHealthy) {
      backgroundColor = semanticColors.successContainer;
      foregroundColor = semanticColors.onSuccessContainer;
      label = 'HEALTHY';
    } else {
      backgroundColor = semanticColors.infoContainer;
      foregroundColor = semanticColors.onInfoContainer;
      label = 'UNKNOWN';
    }

    // Flexbox button containers equivalent; crisp action points, scannable without wrapping.
    return Chip(
      avatar: Icon(
        status.isQuarantined ? Icons.block : (status.isHealthy ? Icons.check_circle : Icons.warning),
        color: foregroundColor,
        size: 18.0,
      ),
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }
}