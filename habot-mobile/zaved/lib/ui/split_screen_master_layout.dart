/// TELEMETRY METADATA BLOCK
/// Layout Type: Split-Screen Adaptive Master Layout
/// Layout Grid Dimensions: 12-Column Responsive (6-Column/6-Column Split >= 840px, 1-Column Stack < 840px)
/// Spacing Rules: Exact Multiples of 8 (8.0, 16.0, 24.0, 32.0)
/// Alignment Settings: CrossAxisAlignment.stretch / MainAxisAlignment.start
/// Layout Validation Status: Target: Pass
library;

import 'package:flutter/material.dart';

/// SSELC-004: Foundational Split-Screen Master Layout for Back-Office Portal
class SplitScreenMasterLayout extends StatelessWidget {
  final Widget evidencePane;
  final Widget actionPane;
  final String? title;

  const SplitScreenMasterLayout({
    super.key,
    required this.evidencePane,
    required this.actionPane,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              backgroundColor: colorScheme.surface,
              surfaceTintColor: colorScheme.surfaceTint,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            // Fluid padding calculation based on screen width breakpoint
            final double fluidPadding;
            if (screenWidth >= 840) {
              fluidPadding = 32.0; // Web/Desktop 32.0 spacing multiple
            } else if (screenWidth >= 600) {
              fluidPadding = 24.0; // Tablet 24.0 spacing multiple
            } else {
              fluidPadding = 16.0; // Mobile 16.0 spacing multiple
            }

            // Web/Tablet View (maxWidth >= 840): 6-Column / 6-Column Split
            if (screenWidth >= 840) {
              return Padding(
                padding: EdgeInsets.all(fluidPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left 6-Column Pane (Evidence Pane)
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                            width: 1.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: evidencePane,
                      ),
                    ),
                    // Structural Spacing Multiple (24.0 px width, multiple of 8)
                    const SizedBox(width: 24.0),
                    // Right 6-Column Pane (Action Pane)
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                            width: 1.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: actionPane,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Mobile View (maxWidth < 840): Single-Column Stack
            return SingleChildScrollView(
              padding: EdgeInsets.all(fluidPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Pane (Evidence Pane)
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: evidencePane,
                  ),
                  // Structural Spacing Multiple (24.0 px height, multiple of 8)
                  const SizedBox(height: 24.0),
                  // Bottom Pane (Action Pane)
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: actionPane,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
