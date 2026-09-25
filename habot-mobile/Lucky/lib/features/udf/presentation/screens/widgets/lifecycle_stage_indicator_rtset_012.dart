// RTSET-012 — Live User Lifecycle Stage Detection Engine & Status Indicator.
// Displays active lifecycle status positions on the customer console using Material 3 progress indicators and responsive layout rules. Includes local mock data for lifecycle stages.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level lifecycle stage fields.
class LifecycleStageMockData {
  static const List<Map<String, dynamic>> stages = [
    {
      'stepExecutionId': 'EXEC-001',
      'executionStatus': 'completed',
      'executionTimestamp': '2026-09-25T08:00:00Z',
      'stepOutcome': 'success',
      'userId': 'USR-9921',
      'title': 'Account Created',
    },
    {
      'stepExecutionId': 'EXEC-002',
      'executionStatus': 'completed',
      'executionTimestamp': '2026-09-25T08:15:00Z',
      'stepOutcome': 'success',
      'userId': 'USR-9921',
      'title': 'Identity Verified',
    },
    {
      'stepExecutionId': 'EXEC-003',
      'executionStatus': 'active',
      'executionTimestamp': '2026-09-25T09:00:00Z',
      'stepOutcome': 'pending',
      'userId': 'USR-9921',
      'title': 'Profile Configuration',
    },
    {
      'stepExecutionId': 'EXEC-004',
      'executionStatus': 'pending',
      'executionTimestamp': null,
      'stepOutcome': 'pending',
      'userId': 'USR-9921',
      'title': 'Service Activation',
    },
  ];
}

/// Responsive lifecycle stage indicator widget adhering to Material 3 design tokens.
/// Maps out onboarding milestones across customer account portals.
class LifecycleStageIndicator extends StatelessWidget {
  const LifecycleStageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    // Calculate progress based on completed/active stages
    final totalStages = LifecycleStageMockData.stages.length;
    final completedStages = LifecycleStageMockData.stages
        .where((s) => s['executionStatus'] == 'completed')
        .length;
    final activeProgress = totalStages > 0
        ? (completedStages + 0.5) / totalStages
        : 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row adheres to strict text alignment scaling rules (md.sys.typescale.title-medium)
            Text(
              'Lifecycle Progress',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            // Interactive progress banners condense into smooth status tracking icons on space-constrained viewports
            if (isMobile) ...[
              _buildCompactMobileView(context, activeProgress),
            ] else ...[
              _buildExpandedDesktopView(context, activeProgress),
            ],
          ],
        ),
      ),
    );
  }

  /// Compact mobile view: collapses grid views to single-column card feeds on mobile devices.
  Widget _buildCompactMobileView(BuildContext context, double progress) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Material 3 Progress Indicators map out onboarding milestones
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            // Highlight panels link to primary platform container color rules
            colorScheme.primaryFixedDim,
          ),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 16),
        // Smooth sliding movements when ranking entries rearrange
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: ListView.separated(
            key: ValueKey(progress),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: LifecycleStageMockData.stages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final stage = LifecycleStageMockData.stages[index];
              return _buildStageTile(context, stage, index);
            },
          ),
        ),
      ],
    );
  }

  /// Expanded desktop view with detailed metric cards.
  Widget _buildExpandedDesktopView(BuildContext context, double progress) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toStringAsFixed(0)}% Complete',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            // Metric cards use clean layout borders to separate details on compact screens
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primaryFixedDim),
              ),
              child: Text(
                'Active',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primaryFixedDim),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: LifecycleStageMockData.stages.asMap().entries.map((entry) {
            return SizedBox(
              width: 220,
              child: _buildStageTile(context, entry.value, entry.key),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Individual stage tile implementing restore-on-return behavior conceptually via saved state display.
  Widget _buildStageTile(
    BuildContext context,
    Map<String, dynamic> stage,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final status = stage['executionStatus'] as String;

    Color iconColor;
    IconData iconData;

    switch (status) {
      case 'completed':
        iconColor = colorScheme.primary;
        iconData = Icons.check_circle_rounded;
        break;
      case 'active':
        iconColor = colorScheme.tertiary;
        iconData = Icons.radio_button_checked_rounded;
        break;
      default:
        iconColor = colorScheme.outline;
        iconData = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status == 'active'
            ? colorScheme.primaryFixedDim.withOpacity(0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == 'active'
              ? colorScheme.primaryFixedDim
              : colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(iconData, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage['title'] as String,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: status == 'active' ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  status.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}