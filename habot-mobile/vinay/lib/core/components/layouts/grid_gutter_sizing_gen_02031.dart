// GEN-02031 — 12-Column Grid Gutter Sizing Calculation (Fixed vs Fluid).
// Defines gutter sizing logic for M3 responsive layouts with single-column mobile (<600dp) and multi-column desktop (>=840dp) enforcement.

import 'package:flutter/material.dart';

/// Enum representing the gutter calculation strategy.
enum GutterStrategy { fixed, fluid }

/// Configuration model for 12-column grid gutter sizing.
class GridGutterConfig {
  final double mobileGutter;
  final double tabletGutter;
  final double desktopGutter;
  final GutterStrategy strategy;

  const GridGutterConfig({
    this.mobileGutter = 16.0,
    this.tabletGutter = 24.0,
    this.desktopGutter = 32.0,
    this.strategy = GutterStrategy.fluid,
  });
}

/// Calculates the appropriate gutter size based on screen width and strategy.
double calculateGutterSize(double screenWidth, GridGutterConfig config) {
  if (config.strategy == GutterStrategy.fixed) {
    return config.mobileGutter;
  }

  // M3 responsive breakpoints: mobile <600dp, tablet >=600dp, desktop >=840dp
  if (screenWidth < 600) {
    return config.mobileGutter;
  } else if (screenWidth < 840) {
    return config.tabletGutter;
  } else {
    return config.desktopGutter;
  }
}

/// Determines the number of columns based on M3 responsive layout rules.
int calculateColumnCount(double screenWidth) {
  if (screenWidth < 600) {
    return 1; // Single-column mobile layout
  } else if (screenWidth < 840) {
    return 8; // Tablet layout
  } else {
    return 12; // Desktop 12-column grid
  }
}

/// A reusable widget that enforces 12-column grid consistency with proper gutter sizing.
class ResponsiveGridScaffold extends StatelessWidget {
  final List<Widget> children;
  final GridGutterConfig gutterConfig;

  const ResponsiveGridScaffold({
    super.key,
    required this.children,
    this.gutterConfig = const GridGutterConfig(),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final gutter = calculateGutterSize(screenWidth, gutterConfig);
        final columnCount = calculateColumnCount(screenWidth);

        return GridView.builder(
          padding: EdgeInsets.all(gutter),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: gutter,
            mainAxisSpacing: gutter,
            childAspectRatio: columnCount == 1 ? 2.5 : 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) {
            return children[index];
          },
        );
      },
    );
  }
}

/// M3 Elevated Card Level 2 (3dp) with status chip for engineering console dashboard.
class StepHealthCard extends StatelessWidget {
  final String stepId;
  final String stepName;
  final String completionStatus;
  final double completionRate;

  const StepHealthCard({
    super.key,
    required this.stepId,
    required this.stepName,
    required this.completionStatus,
    required this.completionRate,
  });

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (completionStatus) {
      case 'Complete':
        return colorScheme.primary;
      case 'Partial':
        return colorScheme.tertiary;
      case 'Not Complete':
      default:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Deep-link drill-down placeholder
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      stepId,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      completionStatus,
                      style: textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                stepName,
                style: textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12.0),
              LinearProgressIndicator(
                value: completionRate / 100.0,
                minHeight: 4.0,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(context),
                ),
              ),
              const SizedBox(height: 4.0),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${completionRate.toStringAsFixed(1)}%',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mock data repository providing local test data for GEN-02031 implementation.
class MockStepRepository {
  static const List<Map<String, dynamic>> mockSteps = [
    {
      'stepId': 'GEN-02031',
      'stepName': '12-Column Grid Consistency Enforcement',
      'completionStatus': 'Complete',
      'completionRate': 100.0,
    },
    {
      'stepId': 'GEN-02030',
      'stepName': 'Prior Foundational Step Dependency',
      'completionStatus': 'Complete',
      'completionRate': 99.5,
    },
    {
      'stepId': 'GEN-02032',
      'stepName': 'Downstream Baseline Configuration',
      'completionStatus': 'Partial',
      'completionRate': 75.0,
    },
    {
      'stepId': 'GEN-02033',
      'stepName': 'M3 Status Cards Rendering Validation',
      'completionStatus': 'Not Complete',
      'completionRate': 0.0,
    },
  ];

  static List<StepHealthCard> getMockHealthCards() {
    return mockSteps.map((data) {
      return StepHealthCard(
        stepId: data['stepId'] as String,
        stepName: data['stepName'] as String,
        completionStatus: data['completionStatus'] as String,
        completionRate: data['completionRate'] as double,
      );
    }).toList();
  }
}
