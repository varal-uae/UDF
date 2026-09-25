// SCTSS-002-A03 — Global Grid Alignment Rules for 4-column mobile pixel spacing.
// Defines strict 8dp baseline grid tokens, column constraints, and layout validation for snapping atomic components into a Data Flow layout.

import 'package:flutter/material.dart';

/// Design tokens for the global 4-column mobile grid system.
/// Enforces an 8dp baseline grid with precise pixel dimension constraints.
class GridTokens {
  GridTokens._();

  /// Base unit for the 8dp baseline grid.
  static const double baseUnit = 8.0;

  /// Number of columns in the mobile grid template.
  static const int columnCount = 4;

  /// Gutter spacing between columns (16px).
  static const double gutterSpacing = baseUnit * 2;

  /// Outer margin/padding for the screen edges (16px).
  static const double outerMargin = baseUnit * 2;

  /// Vertical rhythm spacing (8px).
  static const double verticalSpacing = baseUnit;

  /// Minimum touch target size for thumb-tapping (48px).
  static const double minTouchTargetSize = baseUnit * 6;
}

/// Configuration model for the 4-column mobile grid.
class MobileGridConfig {
  final String layoutType;
  final int columnCount;
  final double gutterSpacing;
  final double outerMargin;
  final bool isValidationPassed;

  const MobileGridConfig({
    required this.layoutType,
    required this.columnCount,
    required this.gutterSpacing,
    required this.outerMargin,
    required this.isValidationPassed,
  });

  /// Calculates the exact width of a single column given the total available width.
  double calculateColumnWidth(double totalAvailableWidth) {
    final totalGutters = (columnCount - 1) * gutterSpacing;
    final totalMargins = outerMargin * 2;
    final usableWidth = totalAvailableWidth - totalGutters - totalMargins;
    return usableWidth / columnCount;
  }

  /// Calculates the width spanning [span] number of columns.
  double calculateSpanWidth(double totalAvailableWidth, int span) {
    assert(span > 0 && span <= columnCount, 'Span must be between 1 and $columnCount');
    final singleColumnWidth = calculateColumnWidth(totalAvailableWidth);
    return (singleColumnWidth * span) + (gutterSpacing * (span - 1));
  }
}

/// Mock data representing the validated grid configuration.
/// In production, this would be fetched from a design token service or local config.
const MobileGridConfig mockGlobalGridConfig = MobileGridConfig(
  layoutType: '4-Column-Mobile-Data-Flow',
  columnCount: GridTokens.columnCount,
  gutterSpacing: GridTokens.gutterSpacing,
  outerMargin: GridTokens.outerMargin,
  isValidationPassed: true,
);

/// A layout widget that enforces the 4-column mobile grid alignment rules.
/// All child widgets snap to predefined mobile grid zones using Flexbox wrapping logic.
class GlobalGridLayout extends StatelessWidget {
  final List<Widget> children;
  final MobileGridConfig config;
  final EdgeInsetsGeometry? padding;

  const GlobalGridLayout({
    super.key,
    required this.children,
    this.config = mockGlobalGridConfig,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final double columnWidth = config.calculateColumnWidth(screenWidth);

        return Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: config.outerMargin),
          child: Wrap(
            spacing: config.gutterSpacing,
            runSpacing: GridTokens.verticalSpacing,
            children: children.map((child) {
              // Default behavior: each child takes 1 column width unless wrapped in GridSpan
              if (child is GridSpan) {
                return SizedBox(
                  width: config.calculateSpanWidth(screenWidth, child.span),
                  child: child.child,
                );
              }
              return SizedBox(
                width: columnWidth,
                child: child,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Wrapper widget to define how many grid columns a child should span.
class GridSpan extends StatelessWidget {
  final int span;
  final Widget child;

  const GridSpan({
    super.key,
    required this.span,
    required this.child,
  }) : assert(span >= 1 && span <= GridTokens.columnCount, 'Span must be within grid column count');

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Poka-Yoke (Mistake-Proofing): Validates that layout dimensions strictly adhere to the 8dp baseline grid.
/// Used in tests and runtime assertions to prevent misalignment.
class GridLayoutValidator {
  GridLayoutValidator._();

  /// Returns true if the provided dimension is a perfect multiple of the 8dp base unit.
  static bool isValidGridDimension(double dimension) {
    final double remainder = dimension % GridTokens.baseUnit;
    // Allow for minor floating-point precision errors
    return remainder < 0.001 || (GridTokens.baseUnit - remainder) < 0.001;
  }

  /// Validates all spacing rules against the threshold/boundary definition precision.
  /// Floor boundary: 0.95 (95% of values must pass)
  static bool validateLayoutPrecision(List<double> dimensions) {
    if (dimensions.isEmpty) return false;
    final int validCount = dimensions.where(isValidGridDimension).length;
    final double precision = validCount / dimensions.length;
    return precision >= 0.95; // Floor Boundary
  }

  /// Unit test helper: validates token-mapping transformations.
  static void assertGridCompliance(double dimension, {String debugLabel = 'Dimension'}) {
    assert(
      isValidGridDimension(dimension),
      '[UI Linting Violation] $debugLabel ($dimension) does not snap to the ${GridTokens.baseUnit}dp baseline grid.',
    );
  }
}
