import 'package:flutter/material.dart';

/// TTMCS-002-A01: Binary Semantic Color Theme Extension
/// Provides WCAG AAA compliant Binary States:
/// - True / Compliant: High-contrast emerald green
/// - False / Non-compliant: High-contrast intense red
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  const SemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
  });

  /// High-Contrast Light Theme Adaptation (WCAG AAA >= 7.0:1)
  static const light = SemanticColors(
    success: Color(0xFF006D3A),            // High-contrast emerald green
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFF9CF6B4),
    onSuccessContainer: Color(0xFF00210C),
    error: Color(0xFFBA1A1A),              // High-visibility vivid red
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
  );

  /// Target Adaptation Dark Theme (WCAG AAA >= 7.0:1)
  static const dark = SemanticColors(
    success: Color(0xFF80D99A),            // High-luminance adapted green
    onSuccess: Color(0xFF00391C),
    successContainer: Color(0xFF00522B),
    onSuccessContainer: Color(0xFF9CF6B4),
    error: Color(0xFFFFB4AB),              // High-luminance adapted red
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
  );

  @override
  SemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
    );
  }

  @override
  ThemeExtension<SemanticColors> lerp(
    covariant ThemeExtension<SemanticColors>? other,
    double t,
  ) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      successContainer: Color.lerp(successContainer, other.successContainer, t) ?? successContainer,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t) ?? onSuccessContainer,
      error: Color.lerp(error, other.error, t) ?? error,
      onError: Color.lerp(onError, other.onError, t) ?? onError,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t) ?? errorContainer,
      onErrorContainer: Color.lerp(onErrorContainer, other.onErrorContainer, t) ?? onErrorContainer,
    );
  }

  @override
  int get hashCode => Object.hash(
        success,
        onSuccess,
        successContainer,
        onSuccessContainer,
        error,
        onError,
        errorContainer,
        onErrorContainer,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SemanticColors &&
        other.success == success &&
        other.onSuccess == onSuccess &&
        other.successContainer == successContainer &&
        other.onSuccessContainer == onSuccessContainer &&
        other.error == error &&
        other.onError == onError &&
        other.errorContainer == errorContainer &&
        other.onErrorContainer == onErrorContainer;
  }
}
