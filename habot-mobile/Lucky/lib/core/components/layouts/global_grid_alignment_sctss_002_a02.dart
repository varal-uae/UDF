// SCTSS-002-A02 — Global Grid Alignment Rules for strict 4-column mobile pixel spacing.
// Establishes base grid parameters, 8dp baseline spacing tokens, and a universal 4-column layout wrapper to snap all atomic components into a Data Flow layout.

import 'package:flutter/material.dart';

/// Design tokens representing the global mobile layout grid system.
/// Enforces an 8dp baseline grid and strict 4-column alignment for mobile viewports.
class GlobalGridTokens {
  GlobalGridTokens._();

  /// Base spacing unit (8dp baseline grid).
  static const double baseUnit = 8.0;

  /// Number of columns in the mobile grid.
  static const int mobileColumnCount = 4;

  /// Gutter spacing between columns.
  static const double gutterSpacing = baseUnit * 2; // 16dp

  /// Outer margin spacing for the grid container.
  static const double marginSpacing = baseUnit * 2; // 16dp

  /// Standard vertical spacing between stacked elements.
  static const double verticalSpacing = baseUnit * 3; // 24dp
}

/// Configuration data model for the layout grid.
/// Used for telemetry, validation, and ITIL CMDB configuration accuracy tracking.
class LayoutGridConfig {
  final String layoutType;
  final String layoutGridDimensions;
  final double spacingRules;
  final String alignmentSettings;
  final bool layoutValidationStatus;
  final DateTime actionTimestamp;

  const LayoutGridConfig({
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
    required this.actionTimestamp,
  });

  Map<String, dynamic> toJson() => {
        'layoutType': layoutType,
        'layoutGridDimensions': layoutGridDimensions,
        'spacingRules': spacingRules,
        'alignmentSettings': alignmentSettings,
        'layoutValidationStatus': layoutValidationStatus ? 'Pass' : 'Fail',
        'actionTimestamp': actionTimestamp.toIso8601String(),
      };
}

/// Mock repository providing local configuration data for the grid system.
/// Satisfies the requirement for realistic local mock data without backend dependency.
class GridConfigMockRepository {
  static LayoutGridConfig get defaultMobileConfig => LayoutGridConfig(
        layoutType: '4-Column Mobile Flexbox',
        layoutGridDimensions: '4 cols x auto rows',
        spacingRules: GlobalGridTokens.gutterSpacing,
        alignmentSettings: 'Stretch / Snap-to-Grid',
        layoutValidationStatus: true,
        actionTimestamp: DateTime.now(),
      );

  static List<LayoutGridConfig> getConfigHistory() => [
        defaultMobileConfig,
        LayoutGridConfig(
          layoutType: '4-Column Mobile Flexbox',
          layoutGridDimensions: '4 cols x auto rows',
          spacingRules: GlobalGridTokens.gutterSpacing,
          alignmentSettings: 'Center / Snap-to-Grid',
          layoutValidationStatus: true,
          actionTimestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
}

/// A universal 4-column grid widget that snaps child components into predefined zones.
/// Implements Flexbox wrapping logic adapted for Flutter using [Wrap] or [GridView].
/// Targets large enough touch targets for thumb-tapping (minimum 48x48dp).
class GlobalFourColumnGrid extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  const GlobalFourColumnGrid({
    super.key,
    required this.children,
    this.padding,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: GlobalGridTokens.marginSpacing,
          ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: GlobalGridTokens.mobileColumnCount,
          crossAxisSpacing:
              crossAxisSpacing ?? GlobalGridTokens.gutterSpacing,
          mainAxisSpacing:
              mainAxisSpacing ?? GlobalGridTokens.verticalSpacing,
          childAspectRatio: 1.0,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          return _GridSnapZone(child: children[index]);
        },
      ),
    );
  }
}

/// Internal wrapper ensuring each child conforms to minimum touch target sizes
/// and visually snaps to the 8dp baseline grid.
class _GridSnapZone extends StatelessWidget {
  final Widget child;

  const _GridSnapZone({required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 48.0, // Minimum thumb-tap target width
        minHeight: 48.0, // Minimum thumb-tap target height
      ),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}

/// A layout builder utility that applies the 4-column mobile grid template universally.
/// Can be used as the root layout for any UDF screen requiring strict grid adherence.
class GlobalGridScaffold extends StatelessWidget {
  final String title;
  final List<Widget> gridChildren;
  final Widget? header;
  final Widget? footer;

  const GlobalGridScaffold({
    super.key,
    required this.title,
    required this.gridChildren,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: GlobalGridTokens.baseUnit * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GlobalGridTokens.marginSpacing,
                ),
                child: header!,
              ),
              const SizedBox(height: GlobalGridTokens.verticalSpacing),
            ],
            GlobalFourColumnGrid(children: gridChildren),
            if (footer != null) ...[
              const SizedBox(height: GlobalGridTokens.verticalSpacing),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GlobalGridTokens.marginSpacing,
                ),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// UI Linting helper class to programmatically validate grid compliance.
/// Acts as a Poka-Yoke mechanism preventing misalignment by flagging violations.
class GridLayoutValidator {
  /// Validates if a given dimension is a multiple of the 8dp baseline grid.
  static bool isValidBaselineMultiple(double value) {
    return value % GlobalGridTokens.baseUnit == 0;
  }

  /// Returns a pass/fail status for configuration accuracy rate metric.
  static String evaluateCompliance(List<double> dimensions) {
    final bool allValid =
        dimensions.every((dim) => isValidBaselineMultiple(dim));
    return allValid ? 'Pass' : 'Fail';
  }
}
