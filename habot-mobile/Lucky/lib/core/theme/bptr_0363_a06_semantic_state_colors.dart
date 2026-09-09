// BPTR-0363-A06 — Semantic state color tokens & WCAG AA contrast validation.
// Maps backend data states to high-contrast color roles and prevents manual overrides via immutable theme data.

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Immutable semantic state color pair. Requires a 4.5:1 contrast ratio between
/// [foreground] and [background] at construction time in debug builds.
@immutable
class SemanticStateColor {
  const SemanticStateColor({
    required this.background,
    required this.foreground,
  }) : assert(
         _WcagContrastChecker.contrastRatio(foreground, background) >= 4.5,
         'Semantic state foreground/background pair must meet WCAG AA (4.5:1).',
       );

  final Color background;
  final Color foreground;
}

/// Theme extension storing mapped backend state colors.
@immutable
class HabotSemanticColors extends ThemeExtension<HabotSemanticColors> {
  const HabotSemanticColors({
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.disabled,
  });

  final SemanticStateColor success;
  final SemanticStateColor error;
  final SemanticStateColor warning;
  final SemanticStateColor info;
  final SemanticStateColor disabled;

  static const HabotSemanticColors light = HabotSemanticColors(
    success: SemanticStateColor(
      background: Color(0xFF1B5E20),
      foreground: Color(0xFFFFFFFF),
    ),
    error: SemanticStateColor(
      background: Color(0xFFB71C1C),
      foreground: Color(0xFFFFFFFF),
    ),
    warning: SemanticStateColor(
      background: Color(0xFFF9A825),
      foreground: Color(0xFF000000),
    ),
    info: SemanticStateColor(
      background: Color(0xFF0D47A1),
      foreground: Color(0xFFFFFFFF),
    ),
    disabled: SemanticStateColor(
      background: Color(0xFF616161),
      foreground: Color(0xFFFFFFFF),
    ),
  );

  static const HabotSemanticColors dark = HabotSemanticColors(
    success: SemanticStateColor(
      background: Color(0xFF1B5E20),
      foreground: Color(0xFFFFFFFF),
    ),
    error: SemanticStateColor(
      background: Color(0xFFB71C1C),
      foreground: Color(0xFFFFFFFF),
    ),
    warning: SemanticStateColor(
      background: Color(0xFFF9A825),
      foreground: Color(0xFF000000),
    ),
    info: SemanticStateColor(
      background: Color(0xFF0D47A1),
      foreground: Color(0xFFFFFFFF),
    ),
    disabled: SemanticStateColor(
      background: Color(0xFF616161),
      foreground: Color(0xFFFFFFFF),
    ),
  );

  @override
  HabotSemanticColors copyWith({
    SemanticStateColor? success,
    SemanticStateColor? error,
    SemanticStateColor? warning,
    SemanticStateColor? info,
    SemanticStateColor? disabled,
  }) {
    return HabotSemanticColors(
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  HabotSemanticColors lerp(covariant HabotSemanticColors? other, double t) {
    if (other == null) return this;
    return HabotSemanticColors(
      success: SemanticStateColor(
        background: Color.lerp(success.background, other.success.background, t)!,
        foreground: Color.lerp(success.foreground, other.success.foreground, t)!,
      ),
      error: SemanticStateColor(
        background: Color.lerp(error.background, other.error.background, t)!,
        foreground: Color.lerp(error.foreground, other.error.foreground, t)!,
      ),
      warning: SemanticStateColor(
        background: Color.lerp(warning.background, other.warning.background, t)!,
        foreground: Color.lerp(warning.foreground, other.warning.foreground, t)!,
      ),
      info: SemanticStateColor(
        background: Color.lerp(info.background, other.info.background, t)!,
        foreground: Color.lerp(info.foreground, other.info.foreground, t)!,
      ),
      disabled: SemanticStateColor(
        background: Color.lerp(disabled.background, other.disabled.background, t)!,
        foreground: Color.lerp(disabled.foreground, other.disabled.foreground, t)!,
      ),
    );
  }
}

/// WCAG 2.x relative luminance and contrast ratio calculations.
class _WcagContrastChecker {
  static double _channelLuminance(double value) {
    final double c = value / 255;
    return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  static double luminance(Color color) {
    final double r = _channelLuminance(color.r * 255);
    final double g = _channelLuminance(color.g * 255);
    final double b = _channelLuminance(color.b * 255);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double contrastRatio(Color a, Color b) {
    final double la = luminance(a);
    final double lb = luminance(b);
    final double lighter = math.max(la, lb);
    final double darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }
}
