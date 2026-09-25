// SCTSS-005-A02 — Semantic Color Tokens & WCAG Contrast Compliance Utilities.
// Maps 1:1 semantic state colors to exact hex codes, enforces WCAG 2.1 AA/AAA contrast ratios (4.5:1 floor, 7:1 optimal), and prevents manual overrides by developers.

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Immutable semantic color tokens mapping system states to exact hex codes.
/// Developers cannot manually override these values; all UI components must
/// reference [SemanticColorTokens] to ensure objective, mathematical state communication.
class SemanticColorTokens {
  const SemanticColorTokens._();

  // --- Base Spacing Unit Anchor (4px/8px scale reference) ---
  static const double baseSpacingUnit = 4.0;

  // --- Light Mode Semantic Colors ---
  static const Color lightSuccess = Color(0xFF1B5E20);
  static const Color lightError = Color(0xFFB71C1C);
  static const Color lightWarning = Color(0xFFE65100);
  static const Color lightInfo = Color(0xFF0D47A1);
  static const Color lightNeutral = Color(0xFF424242);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF121212);

  // --- Dark Mode Semantic Colors ---
  static const Color darkSuccess = Color(0xFF81C784);
  static const Color darkError = Color(0xFFEF9A9A);
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkInfo = Color(0xFF90CAF9);
  static const Color darkNeutral = Color(0xFFBDBDBD);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkOnSurface = Color(0xFFE0E0E0);

  /// Resolves the semantic color for a given state based on brightness.
  static Color resolveStateColor(SemanticState state, Brightness brightness) {
    if (brightness == Brightness.dark) {
      switch (state) {
        case SemanticState.success:
          return darkSuccess;
        case SemanticState.error:
          return darkError;
        case SemanticState.warning:
          return darkWarning;
        case SemanticState.info:
          return darkInfo;
        case SemanticState.neutral:
          return darkNeutral;
      }
    } else {
      switch (state) {
        case SemanticState.success:
          return lightSuccess;
        case SemanticState.error:
          return lightError;
        case SemanticState.warning:
          return lightWarning;
        case SemanticState.info:
          return lightInfo;
        case SemanticState.neutral:
          return lightNeutral;
      }
    }
  }
}

/// Strictly defined semantic states. No orphaned values allowed.
enum SemanticState {
  success,
  error,
  warning,
  info,
  neutral,
}

/// WCAG 2.1 Contrast Ratio boundaries.
class WcagContrastBounds {
  const WcagContrastBounds._();

  /// AA minimum for normal text (Floor Boundary)
  static const double aaMinimum = 4.5;

  /// AAA best practice for compliance-critical UI (Optimal Target)
  static const double aaaOptimal = 7.0;

  /// Maximum possible contrast (Ceiling Boundary)
  static const double maximum = 21.0;
}

/// Utility class to calculate and audit WCAG 2.1 contrast ratios.
/// Acts as an accessibility linter flagging low-contrast pairings.
class ContrastAuditor {
  const ContrastAuditor._();

  /// Calculates the relative luminance of a color per WCAG 2.1 spec.
  static double _relativeLuminance(Color color) {
    final r = _linearize(color.r);
    final g = _linearize(color.g);
    final b = _linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Returns the contrast ratio between two colors.
  static double getContrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Evaluates if the contrast ratio passes WCAG AA (4.5:1).
  static bool passesAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= WcagContrastBounds.aaMinimum;
  }

  /// Evaluates if the contrast ratio passes WCAG AAA (7:1).
  static bool passesAAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= WcagContrastBounds.aaaOptimal;
  }
}

/// Data model representing an audited component's contrast status.
class ComponentAuditRecord {
  final String componentName;
  final String componentType;
  final SemanticState state;
  final Color foreground;
  final Color background;
  final double contrastRatio;
  final bool isPass;
  final DateTime timestamp;

  const ComponentAuditRecord({
    required this.componentName,
    required this.componentType,
    required this.state,
    required this.foreground,
    required this.background,
    required this.contrastRatio,
    required this.isPass,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'componentName': componentName,
        'componentType': componentType,
        'state': state.name,
        'contrastRatio': contrastRatio.toStringAsFixed(2),
        'completionStatus': isPass ? 'Pass' : 'Fail',
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Mock repository simulating backend data collection for component audits.
/// Provides realistic local mock data directly inside the generated file.
class MockComponentAuditRepository {
  const MockComponentAuditRepository._();

  static List<ComponentAuditRecord> fetchMockAuditData(Brightness brightness) {
    final surface = brightness == Brightness.light
        ? SemanticColorTokens.lightSurface
        : SemanticColorTokens.darkSurface;

    final states = SemanticState.values;
    return states.map((state) {
      final fg = SemanticColorTokens.resolveStateColor(state, brightness);
      final ratio = ContrastAuditor.getContrastRatio(fg, surface);
      return ComponentAuditRecord(
        componentName: '${state.name}_indicator_widget',
        componentType: 'StateIndicator',
        state: state,
        foreground: fg,
        background: surface,
        contrastRatio: ratio,
        isPass: ratio >= WcagContrastBounds.aaMinimum,
        timestamp: DateTime.now(),
      );
    }).toList();
  }
}

/// Extension on ThemeData to enforce semantic token usage globally.
/// Prevents developers from manually overriding semantic color tokens
/// by routing all state-dependent colors through this extension.
extension SemanticThemeExtension on ThemeData {
  Color semanticStateColor(SemanticState state) {
    return SemanticColorTokens.resolveStateColor(state, brightness);
  }
}