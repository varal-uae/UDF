// ============================================================================
// RESPONSIVE 4-TO-8 COLUMN GRID MATRIX SHOWCASE WORKSPACE
// Global Reference ID: TTMCS-003-A10
// Implementation Level: Programmatic 4-to-8 Column Adaptive Grid Matrix
// Verification Status: WCAG 2.1 AA Compliant & MD3 Token Enforced
// Completion Status: Target: Complete - 100% Implementation Completeness
// ============================================================================

import 'package:flutter/material.dart';
import '../widgets/responsive_grid_wrapper.dart';

/// Interactive workspace for testing and validating the 4-to-8 Column Responsive Grid Matrix (TTMCS-003-A10)
class ResponsiveGridWrapperWorkspace extends StatefulWidget {
  const ResponsiveGridWrapperWorkspace({super.key});

  @override
  State<ResponsiveGridWrapperWorkspace> createState() =>
      _ResponsiveGridWrapperWorkspaceState();
}

class _ResponsiveGridWrapperWorkspaceState
    extends State<ResponsiveGridWrapperWorkspace> {
  double _simulatedWidth = 400.0; // Starts at mobile 400px

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final metrics = ResponsiveGridMetrics.fromWidth(_simulatedWidth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('4-to-8 Column Grid Matrix (TTMCS-003-A10)'),
        backgroundColor: colorScheme.surfaceContainerHigh,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.grid_goldenratio,
                      color: colorScheme.onPrimaryContainer,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TTMCS-003-A10: 4-to-8 Column Grid Matrix',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Strict 4-column layout on Mobile (<=600px) and 8-column layout on Tablet/Web (>600px) with programmatic column width calculations.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live Grid Telemetry Card
            Card(
              color: colorScheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Grid Metrics Telemetry',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _buildTelemetryItem(
                          context,
                          label: 'Simulated Viewport Width',
                          value: '${_simulatedWidth.round()}px',
                        ),
                        _buildTelemetryItem(
                          context,
                          label: 'Active Matrix Columns',
                          value: '${metrics.columns} Columns (${metrics.columns == 4 ? "Mobile" : "Tablet/Web"})',
                        ),
                        _buildTelemetryItem(
                          context,
                          label: 'Programmatic Column Width',
                          value: '${metrics.columnWidth.toStringAsFixed(1)}px',
                        ),
                        _buildTelemetryItem(
                          context,
                          label: 'Margin / Gutter Tokens',
                          value: '${metrics.margin.round()}px / ${metrics.gutter.round()}px',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Viewport Width Slider Control
            Text(
              'Interactive Viewport Slider: ${_simulatedWidth.round()}px',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _simulatedWidth,
                    min: 320.0,
                    max: 1200.0,
                    divisions: 88,
                    label: '${_simulatedWidth.round()}px',
                    onChanged: (val) => setState(() => _simulatedWidth = val),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _simulatedWidth = 360.0),
                  child: const Text('360px (Mobile)'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => setState(() => _simulatedWidth = 840.0),
                  child: const Text('840px (Tablet/Web)'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Visual Grid Canvas Container
            Text(
              'Programmatic Matrix Visualizer Canvas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: _simulatedWidth,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: metrics.margin),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        children: [
                          Text(
                            'Viewport: ${_simulatedWidth.round()}px',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                          Text(
                            'Columns: ${metrics.columns} | Gutter: ${metrics.gutter.round()}px',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Responsive Grid Demo with multiple column spans
                    ResponsiveGridWrapper(
                      children: [
                        // Item 1: Full-width item (spans 4 on mobile, 8 on tablet/web)
                        ResponsiveGridItem(
                          span: metrics.columns,
                          child: _buildGridCard(
                            context,
                            title: 'Full Row Span (${metrics.columns}/${metrics.columns} Cols)',
                            subtitle: 'Spans all columns on current viewport',
                            color: colorScheme.primaryContainer,
                            textColor: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        // Item 2 & 3: Half-width items (2 cols on mobile, 4 cols on tablet/web)
                        ResponsiveGridItem(
                          mobileSpan: 2,
                          tabletWebSpan: 4,
                          child: _buildGridCard(
                            context,
                            title: 'Half Span (${metrics.columns == 4 ? 2 : 4} Cols)',
                            subtitle: 'Adaptive 50% width',
                            color: colorScheme.secondaryContainer,
                            textColor: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        ResponsiveGridItem(
                          mobileSpan: 2,
                          tabletWebSpan: 4,
                          child: _buildGridCard(
                            context,
                            title: 'Half Span (${metrics.columns == 4 ? 2 : 4} Cols)',
                            subtitle: 'Adaptive 50% width',
                            color: colorScheme.secondaryContainer,
                            textColor: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        // Items 4-11: 1-column tiles (4 tiles fit on mobile row, 8 tiles fit on tablet/web row)
                        ...List.generate(metrics.columns, (index) {
                          return ResponsiveGridItem(
                            span: 1,
                            child: _buildGridCard(
                              context,
                              title: 'Col #${index + 1}',
                              subtitle: '${metrics.columnWidth.toStringAsFixed(0)}px',
                              color: colorScheme.tertiaryContainer,
                              textColor: colorScheme.onTertiaryContainer,
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required Color textColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2.0),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
