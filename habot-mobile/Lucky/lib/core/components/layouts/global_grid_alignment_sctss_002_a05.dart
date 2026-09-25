// SCTSS-002-A05 — Global Grid Alignment Rules and 4-Column Mobile Layout System.
// Defines strict 8dp baseline grid tokens, 4-column mobile spacing, and a reusable layout widget that snaps all atomic components into a predictable data flow rhythm.

import 'package:flutter/material.dart';

/// Design tokens for the global 4-column mobile grid alignment rules.
/// Uses an 8dp baseline grid as per world's best practice selection guidance.
class GlobalGridTokens {
  GlobalGridTokens._();

  /// The base unit for the 8dp baseline grid.
  static const double baselineUnit = 8.0;

  /// Unit type used across the system (px equivalent in Flutter logical pixels).
  static const String unitType = 'px';

  /// Application level for these tokens.
  static const String applicationLevel = 'global_mobile';

  /// Number of columns in the mobile grid template.
  static const int mobileColumnCount = 4;

  /// Gutter spacing between columns (16px = 2 * 8dp baseline).
  static const double gutterSpacing = 16.0;

  /// Outer margin spacing for the screen edges (16px = 2 * 8dp baseline).
  static const double outerMargin = 16.0;

  /// Vertical spacing scale for stacking elements (8px, 16px, 24px, 32px).
  static const List<double> verticalSpacingScale = [8.0, 16.0, 24.0, 32.0];

  /// Minimum touch target size to ensure thumb-tapping accessibility (48x48).
  static const double minTouchTargetSize = 48.0;
}

/// Mock data representing the specification documentation completeness metrics.
/// Satisfies the requirement for local mock data without backend dependency.
class GridSpecificationMockData {
  static const Map<String, dynamic> specificationMetrics = {
    'atomic_id': 'SCTSS-002-A05',
    'metric_name': 'Specification Documentation Completeness (%)',
    'spacing_value': 16.0,
    'unit_type': 'px',
    'application_level': 'global_mobile',
    'spacing_scale': [8.0, 16.0, 24.0, 32.0],
    'completion_status': 'Complete',
    'floor_boundary': 0.9,
    'optimal_target': 1.0,
    'ceiling_boundary': 1.0,
    'iso_standard': 'ISO/IEC/IEEE 29148',
  };
}

/// A responsive 4-column grid layout widget that enforces strict alignment rules.
/// All child widgets snap seamlessly to predefined mobile grid zones.
/// Implements Flexbox wrapping logic defined via Flutter's [Wrap] or [GridView].
class GlobalGridAlignmentLayout extends StatelessWidget {
  const GlobalGridAlignmentLayout({
    super.key,
    required this.children,
    this.verticalSpacing = GlobalGridTokens.baselineUnit * 2,
  });

  /// The atomic components to be snapped into the grid.
  final List<Widget> children;

  /// Vertical spacing between rows, defaulting to 16px (2x baseline).
  final double verticalSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GlobalGridTokens.outerMargin,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: GlobalGridTokens.mobileColumnCount,
          crossAxisSpacing: GlobalGridTokens.gutterSpacing,
          mainAxisSpacing: verticalSpacing,
          // Allow flexible height so elements stack vertically without overflow
          childAspectRatio: 1.0,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          return _GridSnappedChild(child: children[index]);
        },
      ),
    );
  }
}

/// Internal wrapper ensuring each child respects minimum touch targets
/// and alignment constraints (Poka-Yoke mistake-proofing).
class _GridSnappedChild extends StatelessWidget {
  const _GridSnappedChild({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: GlobalGridTokens.minTouchTargetSize,
        minWidth: GlobalGridTokens.minTouchTargetSize,
      ),
      child: Align(
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

/// A layout component specifically for high-speed MTO data entry rows.
/// Prioritizes limited screen real estate by stacking elements vertically
/// while maintaining the 4-column underlying grid structure.
class DataFlowVerticalStack extends StatelessWidget {
  const DataFlowVerticalStack({
    super.key,
    required this.items,
  });

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GlobalGridTokens.outerMargin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              SizedBox(height: GlobalGridTokens.verticalSpacingScale[1]),
          ],
        ],
      ),
    );
  }
}

/// Segmented button layout implementing Material 3 standards for effortless binary selection.
/// Snaps to the 4-column grid spanning full width.
class GridSegmentedSelector extends StatelessWidget {
  const GridSegmentedSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelectionChanged,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GlobalGridTokens.outerMargin,
      ),
      child: SegmentedButton<int>(
        segments: List.generate(
          options.length,
          (index) => ButtonSegment<int>(
            value: index,
            label: Text(options[index]),
          ),
        ),
        selected: {selectedIndex},
        onSelectionChanged: (Set<int> newSelection) {
          if (newSelection.isNotEmpty) {
            onSelectionChanged(newSelection.first);
          }
        },
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.standard,
        ),
      ),
    );
  }
}

/// Responsive touch feedback treatment for row item selection elements.
/// Ensures frustration-free touch interfaces maintain user momentum.
class TouchFeedbackWrapper extends StatelessWidget {
  const TouchFeedbackWrapper({
    super.key,
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GlobalGridTokens.baselineUnit),
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: GlobalGridTokens.minTouchTargetSize,
        ),
        child: child,
      ),
    );
  }
}