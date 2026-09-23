// RECET-006-A12 — Sharjah Entity Data Dictionary Configuration Card.
// Mobile-first responsive layout for data verification, consent capture, and constraint configuration with Material 3 design tokens.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level execution fields for Sharjah Entity Records.
class _MockExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;
  final bool isOutOfBounds;

  const _MockExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
    this.isOutOfBounds = false,
  });
}

final List<_MockExecutionRecord> _mockRecords = [
  _MockExecutionRecord(
    stepExecutionId: 'STEP-EXE-9999-001',
    executionStatus: 'SUCCESS',
    executionTimestamp: DateTime(2026, 9, 23, 10, 15),
    stepOutcome: 'Data dictionary constraints applied successfully.',
    userId: 'USR-SHJ-4412',
    completionStatus: 'Complete',
    isOutOfBounds: false,
  ),
  _MockExecutionRecord(
    stepExecutionId: 'STEP-EXE-9999-002',
    executionStatus: 'FAILED',
    executionTimestamp: DateTime(2026, 9, 23, 10, 18),
    stepOutcome: 'Regex validation failed on field mapping. Character limit exceeded.',
    userId: 'USR-SHJ-4413',
    completionStatus: 'Partial',
    isOutOfBounds: true,
  ),
  _MockExecutionRecord(
    stepExecutionId: 'STEP-EXE-9999-003',
    executionStatus: 'PENDING',
    executionTimestamp: DateTime(2026, 9, 23, 10, 22),
    stepOutcome: 'Awaiting UAE PDPL / GDPR Art. 7 lawful consent standard verification.',
    userId: 'USR-SHJ-4414',
    completionStatus: 'Not Complete',
    isOutOfBounds: false,
  ),
];

/// Main widget implementing the mobile-first configuration card for Sharjah Entity Records.
/// Aligns with GCP/BigQuery ingest-driven safety gates evaluating privacy compliance tokens.
class SharjahEntityConfigCard extends StatefulWidget {
  const SharjahEntityConfigCard({super.key});

  @override
  State<SharjahEntityConfigCard> createState() => _SharjahEntityConfigCardState();
}

class _SharjahEntityConfigCardState extends State<SharjahEntityConfigCard> {
  final TextEditingController _feedbackController = TextEditingController();
  double _consentCompleteness = 0.95; // Floor boundary metric

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Text(
                      'Sharjah Entity Records Configuration',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data Dictionary Format Constraints & Privacy Compliance Tokens',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Consent Capture Metric Progress Line
                    _buildConsentMetricSection(theme),
                    const SizedBox(height: 24),

                    // Multi-column data verification blocks stacked vertically into digest cards
                    ..._mockRecords.map((record) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildDigestCard(record, theme),
                        )),
                    const SizedBox(height: 16),

                    // Feedback Text Entry leveraging structured multi-line Material text area
                    Text(
                      'Compliance Feedback',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      minLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter compliance feedback or regex mapping notes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                      ),
                    ),
                    const SizedBox(height: 80), // Space for footer
                  ],
                ),
              ),
            ),
            // Workflow actions clustered inside an inline contextual footer container
            _buildContextualFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentMetricSection(ThemeData theme) {
    final ColorScheme colorScheme = theme.colorScheme;
    final double optimalTarget = 0.995;
    final double ceilingBoundary = 1.0;

    return Card(
      elevation: 0,
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
                Text(
                  'Consent Capture Completeness (%)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Choice badge visual treatments adhering to high-contrast tonal weights
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _consentCompleteness >= optimalTarget
                        ? colorScheme.primaryContainer
                        : colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(_consentCompleteness * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: _consentCompleteness >= optimalTarget
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress lines compress aspect grids smoothly
            LinearProgressIndicator(
              value: _consentCompleteness / ceilingBoundary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Standard: UAE PDPL / GDPR Art. 7 Lawful Consent',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigestCard(_MockExecutionRecord record, ThemeData theme) {
    final ColorScheme colorScheme = theme.colorScheme;

    // Out-of-bounds fields highlight text elements using highly contrasting error typography
    final TextStyle valueStyle = record.isOutOfBounds
        ? theme.textTheme.bodyMedium!.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.bold,
            backgroundColor: colorScheme.errorContainer.withOpacity(0.3),
          )
        : theme.textTheme.bodyMedium!.copyWith(
            color: colorScheme.onSurface,
          );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: record.isOutOfBounds ? colorScheme.error : colorScheme.outlineVariant,
          width: record.isOutOfBounds ? 1.5 : 1.0,
        ),
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
                    record.stepExecutionId,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(record.completionStatus, theme),
              ],
            ),
            const Divider(height: 24),
            // Component layout frames wrap content entries gracefully preventing long character descriptions from breaking bounds
            _buildDataRow('User ID', record.userId, valueStyle),
            const SizedBox(height: 8),
            _buildDataRow('Status', record.executionStatus, valueStyle),
            const SizedBox(height: 8),
            _buildDataRow(
              'Timestamp',
              '${record.executionTimestamp.year}-${record.executionTimestamp.month.toString().padLeft(2, '0')}-${record.executionTimestamp.day.toString().padLeft(2, '0')} ${record.executionTimestamp.hour}:${record.executionTimestamp.minute.toString().padLeft(2, '0')}',
              valueStyle,
            ),
            const SizedBox(height: 12),
            Text(
              'Outcome',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              record.stepOutcome,
              style: valueStyle,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, TextStyle valueStyle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle,
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    final ColorScheme colorScheme = theme.colorScheme;
    Color bgColor;
    Color fgColor;

    switch (status) {
      case 'Complete':
        bgColor = colorScheme.primaryContainer;
        fgColor = colorScheme.onPrimaryContainer;
        break;
      case 'Partial':
        bgColor = colorScheme.tertiaryContainer;
        fgColor = colorScheme.onTertiaryContainer;
        break;
      case 'Not Complete':
      default:
        bgColor = colorScheme.errorContainer;
        fgColor = colorScheme.onErrorContainer;
        break;
    }

    // Choice badge visual treatments adhere to explicit, high-contrast Material design tonal weights
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContextualFooter(ThemeData theme) {
    final ColorScheme colorScheme = theme.colorScheme;

    // Workflow actions cluster cleanly inside an inline contextual footer container on compact displays
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _consentCompleteness = 0.995; // Simulate programmatic generation
                  });
                },
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Validate Integrity'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () {
                  // Automated checks implementation hook
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Submit Compliance'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}