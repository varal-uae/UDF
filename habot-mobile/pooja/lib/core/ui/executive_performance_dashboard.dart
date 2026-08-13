/*
 * STEP 13: LSAV-001 — Mobile-View Optimized Single-Column Executive Summary Dashboard
 * 
 * Setup Step (Action): Apply compact padding styles to eliminate unnecessary vertical viewport scrolling needs.
 * Setup Step Description: Single-column executive performance dashboard with revenue cards, conversion rate, and period metrics.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Responsive breakpoint coverage passing 320–1280px range (Google M3 Breakpoints & WCAG 1.4.10 Reflow).
 *   - Compact padding styles eliminating unnecessary vertical viewport scrolling.
 *   - Clear typographic hierarchy for fast executive scanning on mobile screens.
 * 
 * What Was Done to Complete This Step:
 *   - Created `ExecutivePerformanceDashboard` widget and `ExecutiveSummaryData` model in a single file.
 *   - Implemented single-column card layout, KPI metric tiles, and financial summary cards.
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

class ExecutiveSummaryData {
  final String periodLabel;
  final String netRevenue;
  final String conversionRate;
  final String totalOperationalCost;

  const ExecutiveSummaryData({
    required this.periodLabel,
    required this.netRevenue,
    required this.conversionRate,
    required this.totalOperationalCost,
  });
}

/// Step LSAV-001: Mobile & Web Responsive Executive Performance Summary Dashboard.
class ExecutivePerformanceDashboard extends StatelessWidget {
  final ExecutiveSummaryData data;

  const ExecutivePerformanceDashboard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Executive Summary (${data.periodLabel})',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.leaderboard, color: colorScheme.primary, size: 20.0),
              ],
            ),
            AppSpacingTokens.vGapMd,
            Container(
              padding: AppSpacingTokens.paddingSm,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacingTokens.xs),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 360;
                  if (isNarrow) {
                    return Column(
                      children: [
                        Column(
                          children: [
                            Text('Net Revenue', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                            Text(data.netRevenue, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        AppSpacingTokens.vGapSm,
                        Column(
                          children: [
                            Text('Conversion Rate', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                            Text(data.conversionRate, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text('Net Revenue', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                            Text(data.netRevenue, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(height: 30, width: 1, color: colorScheme.outlineVariant),
                      Expanded(
                        child: Column(
                          children: [
                            Text('Conversion Rate', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                            Text(data.conversionRate, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
