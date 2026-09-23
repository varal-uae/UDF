// RCGLA-034-A07 — DataFlowLayout standardized layout container with 8dp baseline grid alignment.
// Enforces global mobile grid rules, vertical stacking, Material 3 status banners, and outline error boxes.

import 'package:flutter/material.dart';

/// Design tokens for the 8dp baseline grid system.
class GridTokens {
  GridTokens._();

  static const double baseUnit = 8.0;
  static const double spacingXs = baseUnit * 0.5; // 4.0
  static const double spacingSm = baseUnit; // 8.0
  static const double spacingMd = baseUnit * 2; // 16.0
  static const double spacingLg = baseUnit * 3; // 24.0
  static const double spacingXl = baseUnit * 4; // 32.0

  static const int mobileColumns = 4;
  static const double mobileGutter = spacingMd;
}

/// Layout validation status mapped to Material 3 color tokens.
enum LayoutValidationStatus { valid, warning, error }

/// Standardized layout container enforcing global grid alignment rules.
/// Prioritizes limited screen real estate by stacking elements vertically.
class DataFlowLayout extends StatelessWidget {
  final List<Widget> children;
  final LayoutValidationStatus validationStatus;
  final String? errorMessage;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;

  const DataFlowLayout({
    super.key,
    required this.children,
    this.validationStatus = LayoutValidationStatus.valid,
    this.errorMessage,
    this.isLoading = false,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusBanner(context, colorScheme),
        if (isLoading) _buildLoadingIndicator(colorScheme),
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: GridTokens.mobileGutter,
            vertical: GridTokens.spacingMd,
          ),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: _applyGridSpacing(children),
          ),
        ),
        if (errorMessage != null && validationStatus == LayoutValidationStatus.error)
          _buildErrorOutlineBox(context, colorScheme),
      ],
    );
  }

  /// High-visibility green/red layout status banners providing immediate processing feedback.
  Widget _buildStatusBanner(BuildContext context, ColorScheme colorScheme) {
    final Color bannerColor;
    final IconData icon;
    final String label;

    switch (validationStatus) {
      case LayoutValidationStatus.valid:
        bannerColor = colorScheme.primaryContainer;
        icon = Icons.check_circle_outline;
        label = 'Layout Valid';
        break;
      case LayoutValidationStatus.warning:
        // Compliance status highlights utilize explicit Material warning color tokens.
        bannerColor = colorScheme.tertiaryContainer;
        icon = Icons.warning_amber_rounded;
        label = 'Layout Warning';
        break;
      case LayoutValidationStatus.error:
        bannerColor = colorScheme.errorContainer;
        icon = Icons.error_outline;
        label = 'Layout Error';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: GridTokens.mobileGutter,
        vertical: GridTokens.spacingSm,
      ),
      color: bannerColor,
      child: Row(
        children: [
          Icon(icon, size: GridTokens.spacingLg, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: GridTokens.spacingSm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Dynamic loading animations during document validation processing.
  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GridTokens.spacingMd),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      ),
    );
  }

  /// Format error detail messages inside prominent outline boxes.
  Widget _buildErrorOutlineBox(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GridTokens.mobileGutter,
        vertical: GridTokens.spacingSm,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(GridTokens.spacingMd),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.error,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(GridTokens.spacingSm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: GridTokens.spacingLg),
            const SizedBox(width: GridTokens.spacingSm),
            Expanded(
              child: Text(
                errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Applies 8dp baseline grid spacing between children.
  List<Widget> _applyGridSpacing(List<Widget> items) {
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < items.length; i++) {
      spacedChildren.add(items[i]);
      if (i < items.length - 1) {
        spacedChildren.add(const SizedBox(height: GridTokens.spacingMd));
      }
    }
    return spacedChildren;
  }
}

/// Helper widget to snap content into a specific column span of the 4-column mobile grid.
class GridSnap extends StatelessWidget {
  final int columnSpan;
  final Widget child;

  const GridSnap({
    super.key,
    this.columnSpan = 4,
    required this.child,
  }) : assert(columnSpan >= 1 && columnSpan <= 4, 'Column span must be between 1 and 4');

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: columnSpan / GridTokens.mobileColumns,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

/// Mock data representing atomic-level data fields for layout configuration.
class LayoutConfigMock {
  static const Map<String, dynamic> defaultConfig = {
    'layoutType': 'DataFlowLayout',
    'layoutGridDimensions': {'columns': 4, 'baseline': 8.0},
    'spacingRules': {'xs': 4.0, 'sm': 8.0, 'md': 16.0, 'lg': 24.0, 'xl': 32.0},
    'alignmentSettings': {'crossAxis': 'stretch', 'mainAxis': 'start'},
    'layoutValidationStatus': 'valid',
  };
}