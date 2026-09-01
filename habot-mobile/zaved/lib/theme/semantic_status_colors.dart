import 'package:flutter/material.dart';
import 'app_design_tokens.dart';

/// SemanticStatusColors ThemeExtension for DCYN Binary Semantic Color Gate system.
class SemanticStatusColors extends ThemeExtension<SemanticStatusColors> {
  const SemanticStatusColors({
    required this.success,
    required this.error,
  });

  final Color success;
  final Color error;

  /// High-contrast Light Theme instance
  static const light = SemanticStatusColors(
    success: AppDesignTokens.semanticSuccessLight, // High-contrast green
    error: AppDesignTokens.semanticErrorLight,   // Intense red
  );

  /// Target Adaptation Dark Theme instance
  static const dark = SemanticStatusColors(
    success: AppDesignTokens.semanticSuccessDark, // Adapted dark mode green
    error: AppDesignTokens.semanticErrorDark,   // Adapted dark mode red
  );

  @override
  SemanticStatusColors copyWith({
    Color? success,
    Color? error,
  }) {
    return SemanticStatusColors(
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  @override
  SemanticStatusColors lerp(
    ThemeExtension<SemanticStatusColors>? other,
    double t,
  ) {
    if (other is! SemanticStatusColors) {
      return this;
    }

    return SemanticStatusColors(
      success: Color.lerp(success, other.success, t) ?? success,
      error: Color.lerp(error, other.error, t) ?? error,
    );
  }

  @override
  int get hashCode => Object.hash(success, error);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SemanticStatusColors &&
            other.success == success &&
            other.error == error;
  }
}
