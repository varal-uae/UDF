/// AISS: TTMCS-004-A01 -- substep 4 "Implement explicit accessibility
/// contrast-checking workflows mapping directly to WCAG AA mobile layout rules."
/// AISS: TTMCS-005-A01 -- metric "WCAG Colour Contrast Ratio".
///
/// Implements WCAG 2.1 relative luminance and contrast ratio from the
/// specification directly, rather than leaning on a framework helper, so the
/// gate is self-documenting and independently reviewable.
///
/// Reference: WCAG 2.1, Definitions -- "relative luminance" and "contrast ratio".
library;

import 'dart:math' as math;
import 'dart:ui' show Color;

/// Thresholds copied verbatim from the TTMCS-005 metric row of the step sheet.
class WcagThresholds {
  const WcagThresholds._();

  /// Floor Boundary -- "4.5:1 (WCAG 2.1 Level AA minimum for normal text)".
  static const double textFloor = 4.5;

  /// Optimal Target -- "7:1 (WCAG 2.1 Level AAA target)".
  static const double textOptimal = 7.0;

  /// WCAG 2.1 SC 1.4.11 -- non-text contrast.
  static const double nonTextFloor = 3.0;

  /// WCAG 2.1 SC 1.4.3 -- large text (>=18pt, or >=14pt bold).
  static const double largeTextFloor = 3.0;
  static const double largeTextSizeSp = 18.0;
}

/// Verdict for one foreground/background pair.
enum ContrastGrade {
  /// Below the AA floor for its category. Blocks the build.
  fail,

  /// Meets AA but not AAA.
  aa,

  /// Meets AAA.
  aaa,
}

class ContrastResult {
  const ContrastResult({
    required this.foregroundName,
    required this.backgroundName,
    required this.foreground,
    required this.background,
    required this.ratio,
    required this.floor,
    required this.grade,
    required this.isText,
  });

  final String foregroundName;
  final String backgroundName;
  final Color foreground;
  final Color background;
  final double ratio;
  final double floor;
  final ContrastGrade grade;
  final bool isText;

  bool get passes => grade != ContrastGrade.fail;

  String get ratioLabel => '${ratio.toStringAsFixed(2)}:1';

  @override
  String toString() =>
      '${grade.name.toUpperCase().padRight(4)} $ratioLabel  '
      '$foregroundName on $backgroundName '
      '(floor ${floor.toStringAsFixed(1)}:1)';
}

class Contrast {
  const Contrast._();

  /// WCAG 2.1 linearisation of a single 0..1 sRGB channel.
  static double _linearise(double channel) {
    if (channel <= 0.04045) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  /// WCAG 2.1 relative luminance, 0.0 (black) .. 1.0 (white).
  ///
  /// Deliberately ignores alpha: every token in this design system is opaque,
  /// and [assertOpaque] enforces that.
  static double relativeLuminance(Color color) {
    return 0.2126 * _linearise(color.r) +
        0.7152 * _linearise(color.g) +
        0.0722 * _linearise(color.b);
  }

  /// WCAG 2.1 contrast ratio, 1.0 .. 21.0. Order-independent.
  static double ratio(Color a, Color b) {
    final double la = relativeLuminance(a);
    final double lb = relativeLuminance(b);
    final double lighter = math.max(la, lb);
    final double darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Grade [ratio] against the appropriate floor.
  static ContrastGrade grade(double value, {required bool isText}) {
    final double floor = isText
        ? WcagThresholds.textFloor
        : WcagThresholds.nonTextFloor;
    if (value < floor) {
      return ContrastGrade.fail;
    }
    if (isText && value < WcagThresholds.textOptimal) {
      return ContrastGrade.aa;
    }
    return ContrastGrade.aaa;
  }

  static ContrastResult evaluate({
    required String foregroundName,
    required String backgroundName,
    required Color foreground,
    required Color background,
    bool isText = true,
  }) {
    final double value = ratio(foreground, background);
    return ContrastResult(
      foregroundName: foregroundName,
      backgroundName: backgroundName,
      foreground: foreground,
      background: background,
      ratio: value,
      floor: isText ? WcagThresholds.textFloor : WcagThresholds.nonTextFloor,
      grade: grade(value, isText: isText),
      isText: isText,
    );
  }

  /// Every design token must be fully opaque -- a translucent token would make
  /// the measured ratio depend on whatever happens to sit behind it.
  static bool isOpaque(Color color) => color.a >= 1.0;
}
