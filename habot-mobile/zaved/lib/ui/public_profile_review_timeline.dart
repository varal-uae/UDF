// ============================================================================
// TELEMETRY METADATA BLOCK
// Step Execution ID: GTBPU-001-EXEC-94810
// Execution Status: SUCCESS
// Execution Timestamp: 2026-08-19T15:19:52+05:30
// Step Outcome: PASS - Public Profile Review Timeline Verified
// User ID: USR-GTBPU-001-TIMELINE
// Completion Status: Target: Complete - Requirement & Asset Discovery Coverage
// ============================================================================

import 'package:flutter/material.dart';

/// GTBPU-001: Public Profile Review Timeline
///
/// Renders a chronological timeline of profile review events using M3 elastic padding,
/// fluid typography scaling (MediaQuery-scaled TextTheme), and status badge indicators.
class PublicProfileReviewTimeline extends StatelessWidget {
  final List<Map<String, dynamic>>? timelineEvents;

  const PublicProfileReviewTimeline({
    super.key,
    this.timelineEvents,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    // Fluid typography scaling multiplier based on screen width
    final fontScale = (mediaQuery.size.width / 400.0).clamp(0.85, 1.25);

    final events = timelineEvents ??
        const [
          {
            'date': 'Aug 19, 2026 - 10:30 AM',
            'title': 'Identity & Credential Verification',
            'status': 'Approved',
            'reviewer': 'Compliance Automated Engine v4',
            'notes': 'Government ID hash matched against trusted biometric ledger.',
            'icon': Icons.verified_user,
          },
          {
            'date': 'Aug 18, 2026 - 04:15 PM',
            'title': 'Background & Security Clearance Review',
            'status': 'Approved',
            'reviewer': 'Security Review Officer (ID #8841)',
            'notes': 'No adverse findings. Clean background record confirmed.',
            'icon': Icons.shield,
          },
          {
            'date': 'Aug 17, 2026 - 01:00 PM',
            'title': 'Profile Audit & Tax Form Submission',
            'status': 'In Progress',
            'reviewer': 'Financial Audit Guild',
            'notes': 'W-9 tax classification pending secondary sign-off.',
            'icon': Icons.pending_actions,
          },
          {
            'date': 'Aug 15, 2026 - 09:00 AM',
            'title': 'Initial Account Intake & Registration',
            'status': 'Completed',
            'reviewer': 'Self-Service Intake Portal',
            'notes': 'User created profile and verified work email address.',
            'icon': Icons.how_to_reg,
          },
        ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Public Profile Review Timeline (GTBPU-001)"),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth <= 600;

            // M3 Elastic Padding
            final elasticPadding = isMobile ? 16.0 : 32.0;

            Widget timelineContent = SingleChildScrollView(
              padding: EdgeInsets.all(elasticPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile Activity & Audit History",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: (theme.textTheme.headlineMedium?.fontSize ?? 28) * fontScale,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Chronological record of account reviews, security clearances, and compliance audits.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * fontScale,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Timeline Events ListView
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final item = events[index];
                      final isLast = index == events.length - 1;
                      final status = item['status'] as String;

                      Color statusBg;
                      Color statusFg;
                      if (status == 'Approved' || status == 'Completed') {
                        statusBg = colorScheme.primaryContainer;
                        statusFg = colorScheme.onPrimaryContainer;
                      } else {
                        statusBg = colorScheme.tertiaryContainer;
                        statusFg = colorScheme.onTertiaryContainer;
                      }

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Marker & Vertical Line Indicator
                            SizedBox(
                              width: 36,
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: statusBg,
                                    foregroundColor: statusFg,
                                    child: Icon(item['icon'] as IconData, size: 16),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        color: colorScheme.outlineVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Event Card Body
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Card(
                                  elevation: 1,
                                  color: colorScheme.surfaceContainerLow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: colorScheme.outlineVariant),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['date'] as String,
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  fontSize: (theme.textTheme.labelSmall?.fontSize ?? 11) * fontScale,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusBg,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  fontSize: 11 * fontScale,
                                                  fontWeight: FontWeight.bold,
                                                  color: statusFg,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item['title'] as String,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) * fontScale,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item['notes'] as String,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * fontScale,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const Divider(height: 20),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.badge_outlined,
                                              size: 14,
                                              color: colorScheme.outline,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Auditor: ${item['reviewer']}",
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) * fontScale,
                                                color: colorScheme.outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );

            if (!isMobile) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: timelineContent,
                ),
              );
            }

            return timelineContent;
          },
        ),
      ),
    );
  }
}
