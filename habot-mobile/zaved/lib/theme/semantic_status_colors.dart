import 'package:flutter/material.dart';

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
    success: Color(0xFF0E9F6E), // High-contrast green
    error: Color(0xFFE02424),   // Intense red
  );

  /// Target Adaptation Dark Theme instance
  static const dark = SemanticStatusColors(
    success: Color(0xFF31C48D), // Adapted dark mode green
    error: Color(0xFFF87171),   // Adapted dark mode red
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
