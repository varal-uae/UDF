// REF-212-A05 — 4-Column Mobile Grid Setup & Spacing Matrix Implementation.
// Provides a strict responsive grid module and standardized spacing scale based on 4dp multiples for mobile-first layouts.

import 'package:flutter/material.dart';

/// Standardized spacing scale using 4dp base multiples.
class SpacingScale {
  SpacingScale._();

  static const double base = 4.0;
  static const double xxs = base; // 4.0
  static const double xs = base * 2; // 8.0
  static const double sm = base * 3; // 12.0
  static const double md = base * 4; // 16.0
  static const double lg = base * 6; // 24.0
  static const double xl = base * 8; // 32.0
  static const double xxl = base * 12; // 48.0
}

/// Data model representing a spacing matrix entry for telemetry and validation.
class SpacingMatrixEntry {
  final double spacingValue;
  final String unitType;
  final String applicationLevel;
  final double spacingScale;
  final int matrixDimensions;
  final List<double> matrixValues;
  final String matrixType;
  final String matrixStatus;

  const SpacingMatrixEntry({
    required this.spacingValue,
    this.unitType = 'dp',
    this.applicationLevel = 'global',
    required this.spacingScale,
    this.matrixDimensions = 1,
    required this.matrixValues,
    this.matrixType = 'standard',
    this.matrixStatus = 'active',
  });

  Map<String, dynamic> toJson() => {
        'spacingValue': spacingValue,
        'unitType': unitType,
        'applicationLevel': applicationLevel,
        'spacingScale': spacingScale,
        'matrixDimensions': matrixDimensions,
        'matrixValues': matrixValues,
        'matrixType': matrixType,
        'matrixStatus': matrixStatus,
      };
}

/// Mock repository providing the atomic-level data fields required by the specification.
class SpacingMatrixMockRepository {
  static const List<SpacingMatrixEntry> entries = [
    SpacingMatrixEntry(
      spacingValue: 4.0,
      spacingScale: 1.0,
      matrixValues: [4.0],
    ),
    SpacingMatrixEntry(
      spacingValue: 8.0,
      spacingScale: 2.0,
      matrixValues: [8.0],
    ),
    SpacingMatrixEntry(
      spacingValue: 16.0,
      spacingScale: 4.0,
      matrixValues: [16.0],
    ),
    SpacingMatrixEntry(
      spacingValue: 24.0,
      spacingScale: 6.0,
      matrixValues: [24.0],
    ),
    SpacingMatrixEntry(
      spacingValue: 32.0,
      spacingScale: 8.0,
      matrixValues: [32.0],
    ),
  ];
}

/// Poka-Yoke (Mistake-Proofing) utility to enforce grid compliance.
/// Automatically flags code additions that attempt to use absolute pixel positions
/// instead of approved grid columns or spacing multiples.
class GridComplianceChecker {
  GridComplianceChecker._();

  /// Validates if a given value strictly adheres to the 4dp multiple rule.
  static bool isCompliant(double value) {
    return value % SpacingScale.base == 0;
  }

  /// Throws an assertion error in debug mode if non-compliant spacing is used.
  static void assertCompliance(double value, {String context = 'Unknown'}) {
    assert(
      isCompliant(value),
      'Grid Compliance Error [$context]: Value $value is not a multiple of ${SpacingScale.base}dp. '
      'Use SpacingScale constants or approved grid columns.',
    );
  }
}

/// A strict 4-column responsive grid layout widget for mobile interfaces.
/// Restricts element boundaries to structured steps, creating a clean rhythm.
class FourColumnMobileGrid extends StatelessWidget {
  final List<Widget> children;
  final double columnSpacing;
  final double rowSpacing;
  final EdgeInsetsGeometry padding;

  const FourColumnMobileGrid({
    super.key,
    required this.children,
    this.columnSpacing = SpacingScale.md,
    this.rowSpacing = SpacingScale.md,
    this.padding = const EdgeInsets.all(SpacingScale.md),
  })  : assert(columnSpacing >= 0),
        assert(rowSpacing >= 0);

  @override
  Widget build(BuildContext context) {
    // Poka-Yoke enforcement at runtime in debug mode
    GridComplianceChecker.assertCompliance(columnSpacing, context: 'columnSpacing');
    GridComplianceChecker.assertCompliance(rowSpacing, context: 'rowSpacing');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Enforce 4-column structure on mobile displays
        const int crossAxisCount = 4;
        
        return GridView.builder(
          padding: padding,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: columnSpacing,
            mainAxisSpacing: rowSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (BuildContext context, int index) {
            return children[index];
          },
        );
      },
    );
  }
}

/// Standardized spacing wrapper applying the spacing matrix to margins and paddings.
class SpacingMatrixBox extends StatelessWidget {
  final Widget child;
  final double? margin;
  final double? padding;

  const SpacingMatrixBox({
    super.key,
    required this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (margin != null) {
      GridComplianceChecker.assertCompliance(margin!, context: 'Margin');
    }
    if (padding != null) {
      GridComplianceChecker.assertCompliance(padding!, context: 'Padding');
    }

    return Container(
      margin: margin != null ? EdgeInsets.all(margin!) : null,
      padding: padding != null ? EdgeInsets.all(padding!) : null,
      child: child,
    );
  }
}