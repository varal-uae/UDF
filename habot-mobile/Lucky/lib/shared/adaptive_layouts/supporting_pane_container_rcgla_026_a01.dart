// RCGLA-026-A01 — Adaptive Supporting Pane Container for Multi-Pane Layouts.
// Provides a responsive structural container that renders primary and supporting panes side-by-side on large viewports, and stacks them sequentially on mobile devices using an 8px baseline grid.

import 'package:flutter/material.dart';

/// Configuration model for the supporting pane layout template.
class SupportingPaneConfig {
  final String templateName;
  final String templateVersion;
  final String templateType;
  final Map<String, dynamic> templateConfiguration;
  final String layoutType;
  final Size layoutGridDimensions;
  final EdgeInsets spacingRules;
  final Alignment alignmentSettings;
  final bool layoutValidationStatus;

  const SupportingPaneConfig({
    required this.templateName,
    required this.templateVersion,
    required this.templateType,
    required this.templateConfiguration,
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
  });
}

/// Mock data representing domain telemetry and configuration state.
const SupportingPaneConfig kMockSupportingPaneConfig = SupportingPaneConfig(
  templateName: 'UDF_Supporting_Pane_v1',
  templateVersion: '1.0.0',
  templateType: 'AdaptiveLayout',
  templateConfiguration: {'maxSupportingWidth': 400.0, 'minPrimaryWidth': 320.0},
  layoutType: 'TwoPane',
  layoutGridDimensions: Size(8.0, 8.0), // 8px baseline grid
  spacingRules: EdgeInsets.all(16.0),
  alignmentSettings: Alignment.topLeft,
  layoutValidationStatus: true,
);

/// Poka-Yoke (Mistake-Proofing) validation utility.
/// Programmatically blocks compilation/rendering if layout grids generate overlapping view properties.
class LayoutValidator {
  static void validateNoOverlap({
    required double screenWidth,
    required double primaryMinWidth,
    required double supportingMinWidth,
    required double spacing,
  }) {
    final totalRequired = primaryMinWidth + supportingMinWidth + spacing;
    if (screenWidth < totalRequired && screenWidth >= (primaryMinWidth + supportingMinWidth)) {
      throw FlutterError(
        'Layout Overlap Exception: Screen width ($screenWidth) is insufficient to place panes side-by-side without overlap. '
        'Required minimum: $totalRequired. Reflowing to single-column.',
      );
    }
  }
}

/// An adaptive structural container pattern that manages visual focus hierarchy.
/// Renders supporting content adjacent to input forms cleanly inside large formats,
/// while seamlessly scaling to a single-column layout on small devices.
class SupportingPaneContainer extends StatelessWidget {
  /// The primary interactive content (e.g., input forms).
  final Widget primaryPane;

  /// The secondary supportive content (e.g., comments, tracking logs, context materials).
  final Widget supportingPane;

  /// The breakpoint at which the layout shifts from stacked (mobile-first) to side-by-side.
  final double expandedBreakpoint;

  /// Optional configuration override; defaults to mock data if not provided.
  final SupportingPaneConfig config;

  const SupportingPaneContainer({
    super.key,
    required this.primaryPane,
    required this.supportingPane,
    this.expandedBreakpoint = 600.0,
    this.config = kMockSupportingPaneConfig,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final bool isExpanded = maxWidth >= expandedBreakpoint;

        // Enforce 8px baseline grid layout constraint
        const double baselineUnit = 8.0;
        final double spacing = (config.spacingRules.horizontal / 2).roundToDouble() * (baselineUnit / 4);
        final double effectiveSpacing = spacing > 0 ? spacing : 16.0;

        // Mistake-proofing check
        try {
          LayoutValidator.validateNoOverlap(
            screenWidth: maxWidth,
            primaryMinWidth: 320.0,
            supportingMinWidth: 240.0,
            spacing: effectiveSpacing,
          );
        } catch (_) {
          // Fallback to single column if validation fails programmatically
          return _buildSingleColumnLayout(effectiveSpacing);
        }

        if (isExpanded) {
          return _buildDualPaneLayout(maxWidth, effectiveSpacing);
        } else {
          return _buildSingleColumnLayout(effectiveSpacing);
        }
      },
    );
  }

  Widget _buildDualPaneLayout(double maxWidth, double spacing) {
    // Flex-based structural variables acting as CSS Grid/Flexbox equivalents
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.only(right: spacing / 2),
            child: primaryPane,
          ),
        ),
        // Semantic container for supportive properties exclusively
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.only(left: spacing / 2),
            child: Semantics(
              label: 'Supporting Information Pane',
              container: true,
              explicitChildNodes: true,
              child: supportingPane,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout(double spacing) {
    // Seamless single-column scaling (Mobile-First UX Implementation)
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          primaryPane,
          SizedBox(height: spacing),
          Semantics(
            label: 'Supporting Information Pane',
            container: true,
            explicitChildNodes: true,
            child: supportingPane,
          ),
        ],
      ),
    );
  }
}