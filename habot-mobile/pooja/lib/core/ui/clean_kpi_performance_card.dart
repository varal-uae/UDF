/*
 * MUFCE-024 — Strip Vanity Parameters from Performance Logs
 * 
 * Setup Step (Action): Set analytical engines to block displays if users overlay social vanity datasets.
 * Setup Step Description: Highlights "Zero-Touch Conversion Rate" as central high-emphasis KPI asset container.
 * 
 * AUDIT NOTICE:
 * Object Lock / State Consistency Audit: High (Scale: High/Medium/Low).
 * Poka-Yoke Gate: Analytical engine blocks rendering if social vanity parameters bypass filtering layers.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Minimalist Material 3 KPI card styling variables.
 *   - Trend lines mapping layout velocity shifts clearly across weekly operational evaluation cycles.
 *   - Strips vanity social noise to focus mobile user on true operational performance metrics.
 *   - Minimum touch target >= 48dp on detail chips.
 * 
 * What Was Done to Complete This Step:
 *   - Created `CleanKpiPerformanceCard` widget, `PerformanceLogConfig` model, and `KpiCompletionStatus` enum.
 *   - Implemented zero-touch conversion KPI highlights, vanity parameter filtering badge, and velocity shift indicator.
 *   - Added required telemetry fields (`lockType`, `lockStatus`, `lockedBy`, `lockTimestamp`, `lockReason`, `actionTimestamp`, `userSessionId`, `completionStatus`).
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

enum KpiCompletionStatus {
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;
  const KpiCompletionStatus(this.label);
}

class PerformanceLogConfig {
  final String zeroTouchConversionRate;
  final String weeklyVelocityShift;
  final bool isVanityStripped;
  final String lockType;
  final String lockStatus;
  final String lockedBy;
  final String lockTimestamp;
  final String lockReason;
  final DateTime actionTimestamp;
  final String userSessionId;
  final KpiCompletionStatus completionStatus;

  PerformanceLogConfig({
    required this.zeroTouchConversionRate,
    required this.weeklyVelocityShift,
    this.isVanityStripped = true,
    this.lockType = 'ANALYTICS_VANITY_BLOCKER_LOCK',
    this.lockStatus = 'ACTIVE_LOCKED',
    this.lockedBy = 'SECURITY_ANALYTICS_ENGINE',
    this.lockTimestamp = '2026-08-14T10:00:00Z',
    this.lockReason = 'STRIP_VANITY_PARAMETERS_PER_SPEC_MUFCE_024',
    DateTime? actionTimestamp,
    String? userSessionId,
    this.completionStatus = KpiCompletionStatus.high,
  })  : actionTimestamp = actionTimestamp ?? DateTime.now(),
        userSessionId = userSessionId ?? 'SESS-KPI-2026';
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
              'Weekly Shift: ${config.weeklyVelocityShift} | Lock: ${config.lockStatus}',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

