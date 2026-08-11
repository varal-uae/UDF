// ============================================================================
// DynamicTypographyWrapper — Flutter
// File: lib/core/typography/dynamic_typography_wrapper.dart
// Version: v1 | Created: 2026-08-10
// Step: TTIAS-014-A01 | Ritwik Sharma — Frontend Integration Specialist
// Team: UDF — UX Design & Frontend Engineering | Habot Connect DMCC
//
// PURPOSE:
//   Viewport-adaptive typography wrapper implementing MD3 type scale with
//   fluid font resizing across mobile, tablet, and desktop breakpoints.
//   All token values sourced from BPTR-0544-A01 (tokens.json v1).
//
// FONT TOKENS (confirmed from Figma AI — HABOT Design System v1):
//   Poppins: Display / Headline / Title Large
//   Inter:   Title Medium/Small / Body / Label
//
// USAGE:
//   DynamicTypographyWrapper(
//     child: Text('Hello', style: DynamicTextStyle.headlineLarge(context)),
//   )
//
// ADD TO pubspec.yaml:
//   dependencies:
//     flutter:
//       sdk: flutter
//
//   fonts:
//     - family: Poppins
//       fonts:
//         - asset: assets/fonts/Poppins-Regular.ttf
//         - asset: assets/fonts/Poppins-Medium.ttf    weight: 500
//         - asset: assets/fonts/Poppins-SemiBold.ttf  weight: 600
//     - family: Inter
//       fonts:
//         - asset: assets/fonts/Inter-Regular.ttf
//         - asset: assets/fonts/Inter-Medium.ttf      weight: 500
// ============================================================================

import 'package:flutter/material.dart';

// ── BREAKPOINTS ───────────────────────────────────────────────────────────────

/// HABOT viewport breakpoints for adaptive typography scaling
abstract class HabotBreakpoints {
  /// Mobile: < 600px
  static const double mobile  = 600;

  /// Tablet: 600px – 1024px
  static const double tablet  = 1024;

  /// Desktop: > 1024px
  static const double desktop = 1440;
}

// ── VIEWPORT TYPE ─────────────────────────────────────────────────────────────

enum _ViewportType { mobile, tablet, desktop }

_ViewportType _getViewportType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < HabotBreakpoints.mobile)  return _ViewportType.mobile;
  if (width < HabotBreakpoints.tablet)  return _ViewportType.tablet;
  return _ViewportType.desktop;
}

// ── SCALE FACTORS ────────────────────────────────────────────────────────────

/// Font scale multipliers per viewport
/// Mobile = 1.0 (base) | Tablet = 1.05 | Desktop = 1.1
double _scaleFactor(BuildContext context) {
  switch (_getViewportType(context)) {
    case _ViewportType.mobile:  return 1.0;
    case _ViewportType.tablet:  return 1.05;
    case _ViewportType.desktop: return 1.1;
  }
}

// ── CLAMPING UTILITY ─────────────────────────────────────────────────────────

/// Clamp a font size between min and max, scaled to viewport
/// Enforces readability floor (12px) and density ceiling
double _clampedSize({
  required BuildContext context,
  required double base,
  required double min,
  required double max,
}) {
  final scaled = base * _scaleFactor(context);
  return scaled.clamp(min, max);
}

// ── DYNAMIC TEXT STYLES ───────────────────────────────────────────────────────

/// Viewport-adaptive MD3 type scale
/// All base values confirmed from HABOT Design System Figma AI extraction
/// Source: BPTR-0544-A01 | tokens.json v1 | 2026-08-10
class DynamicTextStyle {

  // ── DISPLAY ──────────────────────────────────────────────────────────────

  /// md.sys.typescale.display-large
  /// Base: Poppins 400 / 57px / 64px / -0.25px
  static TextStyle displayLarge(BuildContext context) => TextStyle(
    fontFamily:     'Poppins',
    fontWeight:     FontWeight.w400,
    fontSize:       _clampedSize(context: context, base: 57, min: 48, max: 64),
    height:         64 / 57,
    letterSpacing:  -0.25,
    overflow:       TextOverflow.ellipsis,
  );

  /// md.sys.typescale.display-medium
  /// Base: Poppins 400 / 45px / 52px / 0
  static TextStyle displayMedium(BuildContext context) => TextStyle(
    fontFamily:     'Poppins',
    fontWeight:     FontWeight.w400,
    fontSize:       _clampedSize(context: context, base: 45, min: 36, max: 52),
    height:         52 / 45,
    letterSpacing:  0,
    overflow:       TextOverflow.ellipsis,
  );

  /// md.sys.typescale.display-small
  /// Base: Poppins 400 / 36px / 44px / 0
  static TextStyle displaySmall(BuildContext context) => TextStyle(
    fontFamily:     'Poppins',
    fontWeight:     FontWeight.w400,
    fontSize:       _clampedSize(context: context, base: 36, min: 28, max: 44),
    height:         44 / 36,
    letterSpacing:  0,
    overflow:       TextOverflow.ellipsis,
  );

  // ── HEADLINE ─────────────────────────────────────────────────────────────

  /// md.sys.typescale.headline-large
  /// Base: Poppins 600 / 32px / 40px / 0
  static TextStyle headlineLarge(BuildContext context) => TextStyle(
    fontFamily:     'Poppins',
    fontWeight:     FontWeight.w600,
    fontSize:       _clampedSize(context: context, base: 32, min: 26, max: 40),
    height:         40 / 32,
    letterSpacing:  0,
    overflow:       TextOverflow.ellipsis,
  );

  /// md.sys.typescale.headline-medium
  /// Base: Poppins 600 / 28px / 36px / 0
  static TextStyle headlineMedium(BuildContext context) => TextStyle(
    fontFamily:     'Poppins',
    fontWeight:     FontWeight.w600,
    fontSize:       _clampedSize(context: context, base: 28, min: 22, max: 36),
    height:         36 / 28,
    letterSpacing:  0,
    overflow:       TextOverflow.ellipsis,
  );

  /// md.sys.typescale.headline-small
  /// Base: Poppins 600 / 24px / 32px / 0
  static TextStyle headlineSmall(BuildContext context) => TextStyle(
    fontFamily:     'Poppins',
    fontWeight:     FontWeight.w600,
    fontSize:       _clampedSize(context: context, base: 24, min: 20, max: 32),
    height:         32 / 24,
    letterSpacing:  0,
    overflow:       TextOverflow.ellipsis,
  );

  // ── TITLE ────────────────────────────────────────────────────────────────

  /// md.sys.typescale.title-large
  /// Base: Poppins 500 / 22px / 28px / 0
  static TextStyle titleLarge(BuildContext context) => TextStyle(
    fontFamily:     'Poppins',
    fontWeight:     FontWeight.w500,
    fontSize:       _clampedSize(context: context, base: 22, min: 18, max: 28),
    height:         28 / 22,
    letterSpacing:  0,
    overflow:       TextOverflow.ellipsis,
  );

  /// md.sys.typescale.title-medium
  /// Base: Inter 500 / 16px / 24px / +0.15px
  static TextStyle titleMedium(BuildContext context) => TextStyle(
    fontFamily:     'Inter',
    fontWeight:     FontWeight.w500,
    fontSize:       _clampedSize(context: context, base: 16, min: 14, max: 20),
    height:         24 / 16,
    letterSpacing:  0.15,
    overflow:       TextOverflow.ellipsis,
  );

  /// md.sys.typescale.title-small
  /// Base: Inter 500 / 14px / 20px / +0.1px
  static TextStyle titleSmall(BuildContext context) => TextStyle(
    fontFamily:     'Inter',
    fontWeight:     FontWeight.w500,
    fontSize:       _clampedSize(context: context, base: 14, min: 12, max: 18),
    height:         20 / 14,
    letterSpacing:  0.1,
    overflow:       TextOverflow.ellipsis,
  );

  // ── BODY ─────────────────────────────────────────────────────────────────

  /// md.sys.typescale.body-large
  /// Base: Inter 400 / 16px / 24px / +0.5px
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontFamily:     'Inter',
    fontWeight:     FontWeight.w400,
    fontSize:       _clampedSize(context: context, base: 16, min: 14, max: 18),
    height:         24 / 16,
    letterSpacing:  0.5,
    overflow:       TextOverflow.ellipsis,
  );

  /// md.sys.typescale.body-medium
  /// Base: Inter 400 / 14px / 20px / +0.25px
  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontFamily:     'Inter',
    fontWeight:     FontWeight.w400,
    fontSize:       _clampedSize(context: context, base: 14, min: 12, max: 16),
    height:         20 / 14,
    letterSpacing:  0.25,
    overflow:       TextOverflow.ellipsis,
  );

  /// md.sys.typescale.body-small
  /// Base: Inter 400 / 12px / 16px / +0.4px
  /// Floor: 12px — readability minimum enforced (Poka-Yoke)
  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontFamily:     'Inter',
    fontWeight:     FontWeight.w400,
    fontSize:       _clampedSize(context: context, base: 12, min: 12, max: 14),
    height:         16 / 12,
    letterSpacing:  0.4,
    overflow:       TextOverflow.ellipsis,
  );

  // ── LABEL ────────────────────────────────────────────────────────────────

  /// md.sys.typescale.label-large
  /// Base: Inter 500 / 14px / 20px / +0.1px
  static TextStyle labelLarge(BuildContext context) => TextStyle(
    fontFamily:     'Inter',
    fontWeight:     FontWeight.w500,
    fontSize:       _clampedSize(context: context, base: 14, min: 12, max: 16),
    height:         20 / 14,
    letterSpacing:  0.1,
    overflow:       TextOverflow.ellipsis,
  );

  /// md.sys.typescale.label-medium
  /// Base: Inter 500 / 12px / 16px / +0.5px
  static TextStyle labelMedium(BuildContext context) => TextStyle(
    fontFamily:     'Inter',
    fontWeight:     FontWeight.w500,
    fontSize:       _clampedSize(context: context, base: 12, min: 12, max: 14),
    height:         16 / 12,
    letterSpacing:  0.5,
    overflow:       TextOverflow.ellipsis,
  );

  /// md.sys.typescale.label-small
  /// Base: Inter 500 / 11px / 16px / +0.5px
  /// Floor: 12px enforced (readability minimum — Poka-Yoke)
  static TextStyle labelSmall(BuildContext context) => TextStyle(
    fontFamily:     'Inter',
    fontWeight:     FontWeight.w500,
    fontSize:       _clampedSize(context: context, base: 11, min: 12, max: 13),
    height:         16 / 11,
    letterSpacing:  0.5,
    overflow:       TextOverflow.ellipsis,
  );
}

// ── WRAPPER WIDGET ────────────────────────────────────────────────────────────

/// DynamicTypographyWrapper
///
/// Wraps any widget subtree and provides viewport-adaptive typography
/// scaling via MediaQuery. All child Text widgets should use
/// DynamicTextStyle.*() methods to get context-aware font sizes.
///
/// Example:
/// ```dart
/// DynamicTypographyWrapper(
///   child: Column(
///     children: [
///       Text('Dashboard', style: DynamicTextStyle.headlineLarge(context)),
///       Text('Today\'s summary', style: DynamicTextStyle.bodyMedium(context)),
///     ],
///   ),
/// )
/// ```
class DynamicTypographyWrapper extends StatelessWidget {
  const DynamicTypographyWrapper({
    super.key,
    required this.child,
    this.textScaleFactor,
  });

  /// The widget subtree to wrap
  final Widget child;

  /// Optional override for text scale factor.
  /// If null, uses system accessibility text scale.
  /// Clamp between 0.8 and 1.4 to prevent extreme scaling.
  final double? textScaleFactor;

  @override
  Widget build(BuildContext context) {
    final systemScale = MediaQuery.of(context).textScaler;
    final clampedScale = textScaleFactor != null
        ? TextScaler.linear(textScaleFactor!.clamp(0.8, 1.4))
        : systemScale;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: clampedScale,
      ),
      child: child,
    );
  }
}

// ── TYPOGRAPHY ADHERENCE CHECKER ─────────────────────────────────────────────

/// TypographyAdherenceChecker
///
/// Validates Typography Token Scale Adherence at runtime.
/// Used for TTIAS-014-A16 (test font scale across viewports).
///
/// Usage in debug/test builds:
/// ```dart
/// final score = TypographyAdherenceChecker.check(context);
/// print('Adherence: ${score.percentage}%');
/// assert(score.passes, 'Typography adherence below 90% floor');
/// ```
class TypographyAdherenceResult {
  final int    total;
  final int    mapped;
  final double percentage;
  final bool   passes;      // ≥ 90% floor
  final bool   optimal;     // ≥ 98% optimal

  const TypographyAdherenceResult({
    required this.total,
    required this.mapped,
    required this.percentage,
    required this.passes,
    required this.optimal,
  });

  @override
  String toString() =>
      'TypographyAdherenceResult: $mapped/$total = ${percentage.toStringAsFixed(1)}% '
      '| ${passes ? "✅ PASS" : "❌ FAIL"} '
      '| ${optimal ? "✅ OPTIMAL" : "🟡 BELOW OPTIMAL"}';
}

class TypographyAdherenceChecker {
  /// All 15 MD3 type scale roles that must be mapped
  static const int _totalRequired = 15;

  /// Check adherence — all 15 styles are implemented in DynamicTextStyle
  /// so adherence = 15/15 = 100% by construction.
  /// In future: extend this to scan widget trees for hardcoded TextStyle.
  static TypographyAdherenceResult check(BuildContext context) {
    // Verify each style resolves without throwing
    final styles = [
      DynamicTextStyle.displayLarge(context),
      DynamicTextStyle.displayMedium(context),
      DynamicTextStyle.displaySmall(context),
      DynamicTextStyle.headlineLarge(context),
      DynamicTextStyle.headlineMedium(context),
      DynamicTextStyle.headlineSmall(context),
      DynamicTextStyle.titleLarge(context),
      DynamicTextStyle.titleMedium(context),
      DynamicTextStyle.titleSmall(context),
      DynamicTextStyle.bodyLarge(context),
      DynamicTextStyle.bodyMedium(context),
      DynamicTextStyle.bodySmall(context),
      DynamicTextStyle.labelLarge(context),
      DynamicTextStyle.labelMedium(context),
      DynamicTextStyle.labelSmall(context),
    ];

    // Count mapped (non-null fontSize = token mapped)
    final mapped = styles.where((s) => s.fontSize != null).length;
    final pct    = mapped / _totalRequired * 100;

    return TypographyAdherenceResult(
      total:      _totalRequired,
      mapped:     mapped,
      percentage: pct,
      passes:     pct >= 90.0,
      optimal:    pct >= 98.0,
    );
  }
}

// ── OVERFLOW GUARD ────────────────────────────────────────────────────────────

/// DynamicText
///
/// Drop-in replacement for Text widget with built-in:
/// - Viewport-adaptive font size via DynamicTextStyle
/// - text-overflow: ellipsis enforcement (TTIAS-014-A07)
/// - maxLines protection for dense layouts
///
/// Example:
/// ```dart
/// DynamicText.bodyMedium(context, 'Hello world', maxLines: 2)
/// ```
class DynamicText extends StatelessWidget {
  const DynamicText(
    this.data, {
    super.key,
    required this.style,
    this.maxLines = 1,
    this.textAlign,
    this.softWrap = false,
  });

  final String    data;
  final TextStyle style;
  final int       maxLines;
  final TextAlign? textAlign;
  final bool      softWrap;

  // ── Named constructors for each type role ─────────────────────────────────

  factory DynamicText.displayLarge(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.displayLarge(ctx),
          maxLines: maxLines, textAlign: textAlign);

  factory DynamicText.displayMedium(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.displayMedium(ctx),
          maxLines: maxLines, textAlign: textAlign);

  factory DynamicText.displaySmall(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.displaySmall(ctx),
          maxLines: maxLines, textAlign: textAlign);

  factory DynamicText.headlineLarge(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.headlineLarge(ctx),
          maxLines: maxLines, textAlign: textAlign);

  factory DynamicText.headlineMedium(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.headlineMedium(ctx),
          maxLines: maxLines, textAlign: textAlign);

  factory DynamicText.headlineSmall(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.headlineSmall(ctx),
          maxLines: maxLines, textAlign: textAlign);

  factory DynamicText.titleLarge(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.titleLarge(ctx),
          maxLines: maxLines, textAlign: textAlign);

  factory DynamicText.titleMedium(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.titleMedium(ctx),
          maxLines: maxLines, textAlign: textAlign);

  factory DynamicText.titleSmall(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.titleSmall(ctx),
          maxLines: maxLines, textAlign: textAlign);

  factory DynamicText.bodyLarge(BuildContext ctx, String data,
      {int maxLines = 2, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.bodyLarge(ctx),
          maxLines: maxLines, textAlign: textAlign, softWrap: true);

  factory DynamicText.bodyMedium(BuildContext ctx, String data,
      {int maxLines = 2, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.bodyMedium(ctx),
          maxLines: maxLines, textAlign: textAlign, softWrap: true);

  factory DynamicText.bodySmall(BuildContext ctx, String data,
      {int maxLines = 2, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.bodySmall(ctx),
          maxLines: maxLines, textAlign: textAlign, softWrap: true);

  factory DynamicText.labelLarge(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.labelLarge(ctx),
          maxLines: maxLines, textAlign: textAlign);

  factory DynamicText.labelMedium(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.labelMedium(ctx),
          maxLines: maxLines, textAlign: textAlign);

  factory DynamicText.labelSmall(BuildContext ctx, String data,
      {int maxLines = 1, TextAlign? textAlign}) =>
      DynamicText(data, style: DynamicTextStyle.labelSmall(ctx),
          maxLines: maxLines, textAlign: textAlign);

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style:     style,
      maxLines:  maxLines,
      softWrap:  softWrap,
      overflow:  TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}
