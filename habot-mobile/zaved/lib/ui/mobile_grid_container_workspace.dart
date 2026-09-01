// ============================================================================
// TELEMETRY METADATA BLOCK
// Creation Date: 2026-08-26T11:08:43+05:30
// Created By: Antigravity UI Architecture Team
// Creation Method: Automated Atomic Mobile Grid System Generator
// Initial Configuration: {outerMargin: 16.0dp, gutter: 8.0dp, columns: 4, minTextScale: 0.8, maxTextScale: 1.2}
// Object ID: GRID-CONTAINER-M3-012
// Completion Status: Complete - 100% Typography Token Scale Adherence
// ============================================================================

import 'package:flutter/material.dart';
import 'mobile_grid_container.dart';

class MobileGridContainerWorkspace extends StatelessWidget {
  const MobileGridContainerWorkspace({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      child: const Icon(Icons.grid_4x4_rounded),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Atomic Mobile Grid System',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Fluid 16px Margins, 8px Gutters & Anti-Zoom Clamping',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32.0),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: MobileGridContainer(
                    children: List.generate(4, (index) {
                      return Container(
                        width: 140.0,
                        height: 90.0,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.layers_outlined, size: 20.0, color: colorScheme.primary),
                            const SizedBox(height: 6.0),
                            Text(
                              'Grid Item ${index + 1}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
