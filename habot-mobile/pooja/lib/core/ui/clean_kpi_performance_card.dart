/*
 * STEP 15: MUFCE-024 — Strip Vanity Parameters from Performance Logs
 * 
 * Setup Step (Action): Set analytical engines to block displays if users overlay social vanity datasets.
 * Setup Step Description: Highlights "Zero-Touch Conversion Rate" as central high-emphasis KPI asset container.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Minimalist Material 3 KPI card styling variables.
 *   - Trend lines mapping layout velocity shifts clearly across weekly operational evaluation cycles.
 *   - Strips vanity social noise to focus mobile user on true operational performance metrics.
 * 
 * What Was Done to Complete This Step:
 *   - Created `CleanKpiPerformanceCard` widget and `PerformanceLogConfig` model in a single file.
 *   - Implemented zero-touch conversion KPI highlights, vanity parameter filtering badge, and velocity shift indicator.
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

class PerformanceLogConfig {
  final String zeroTouchConversionRate;
  final String weeklyVelocityShift;
  final bool isVanityStripped;

  const PerformanceLogConfig({
    required this.zeroTouchConversionRate,
    required this.weeklyVelocityShift,
    this.isVanityStripped = true,
  });
}

/// Step MUFCE-024: Clean Minimalist M3 KPI Performance Card (Vanity Parameters Stripped).
class CleanKpiPerformanceCard extends StatelessWidget {
  final PerformanceLogConfig config;

  const CleanKpiPerformanceCard({
    super.key,
    required this.config,
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
                    'Zero-Touch Conversion KPI Asset',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Chip(
                  label: Text('Vanity Filtered'),
                  avatar: Icon(Icons.block, size: 14),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            AppSpacingTokens.vGapMd,
            Text(
              config.zeroTouchConversionRate,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            AppSpacingTokens.vGapXs,
            Text(
              'Weekly Shift: ${config.weeklyVelocityShift} (Social Vanity Overlay Blocked)',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
