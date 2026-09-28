// GEN-04169 — Artifact Repository Compliance M3 Status Card.
// Displays the compliance state of storing artifacts in the Core GCP Event Messaging Package repository using Material 3 Elevated Cards and Status Chips with mock data.

import 'package:flutter/material.dart';

/// Mock data model representing the artifact repository compliance step.
class ArtifactComplianceMockData {
  final String atomicId;
  final String globalReferenceId;
  final String stepName;
  final bool isCompliant;
  final DateTime lastChecked;
  final String assignedTeam;
  final String metricName;
  final String standard;

  const ArtifactComplianceMockData({
    required this.atomicId,
    required this.globalReferenceId,
    required this.stepName,
    required this.isCompliant,
    required this.lastChecked,
    required this.assignedTeam,
    required this.metricName,
    required this.standard,
  });
}

/// Hardcoded mock data simulating backend response for GEN-04169.
const ArtifactComplianceMockData kMockArtifactCompliance = ArtifactComplianceMockData(
  atomicId: 'GEN-04169',
  globalReferenceId: 'GEN-04169',
  stepName: 'Store resulting artifact in designated repository: Core GCP Event Messaging Package',
  isCompliant: true,
  lastChecked: DateTime(2026, 9, 28, 14, 30, 0),
  assignedTeam: 'DEA',
  metricName: 'Artifact Repository Compliance',
  standard: 'ISO/IEC 12207 Software Life Cycle – Configuration Management',
);

/// A Material 3 compliant widget that displays the compliance status
/// of a specific atomic implementation step as an elevated card.
class ArtifactRepositoryComplianceCard extends StatelessWidget {
  final ArtifactComplianceMockData data;
  final VoidCallback? onDeepLinkTap;

  const ArtifactRepositoryComplianceCard({
    super.key,
    this.data = kMockArtifactCompliance,
    this.onDeepLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final Color statusColor = data.isCompliant ? colorScheme.primary : colorScheme.error;
    final String statusLabel = data.isCompliant ? 'Pass' : 'Fail';
    final IconData statusIcon = data.isCompliant ? Icons.check_circle_outline : Icons.error_outline;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onDeepLinkTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          data.atomicId,
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          data.metricName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // M3 Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          statusIcon,
                          size: 16.0,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          statusLabel,
                          style: textTheme.labelLarge?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                data.stepName,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16.0),
              Divider(color: colorScheme.outlineVariant, height: 1.0),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildInfoPill(
                    context,
                    label: 'Team',
                    value: data.assignedTeam,
                  ),
                  _buildInfoPill(
                    context,
                    label: 'Standard',
                    value: 'ISO/IEC 12207',
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.access_time,
                    size: 14.0,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    'Last checked: ${_formatTimestamp(data.lastChecked)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (onDeepLinkTap != null) ...<Widget>[
                const SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onDeepLinkTap,
                    icon: const Icon(Icons.open_in_new, size: 18.0),
                    label: const Text('Drill Down'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48.0, 48.0), // 48x48dp touch targets
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPill(BuildContext context, {required String label, required String value}) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day $hour:$minute UTC';
  }
}

/// Preview wrapper demonstrating responsive single-column layout behavior.
class ArtifactCompliancePreviewScreen extends StatelessWidget {
  const ArtifactCompliancePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console - Step Health'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulates pull-to-refresh manual sync
          await Future<void>.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16.0 : 64.0,
            vertical: 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 840.0,
              ),
              child: const ArtifactRepositoryComplianceCard(),
            ),
          ),
        ),
      ),
    );
  }
}