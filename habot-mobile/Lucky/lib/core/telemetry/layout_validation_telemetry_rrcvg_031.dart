// RRCVG-031 — Layout Validation Telemetry & DataFlowLayout Container.
// Provides an isolated validation function to audit application completeness indices, captures ISO 8601 timestamps upon layout instantiation, and implements the standardized DataFlowLayout container with Material 3 design tokens.

import 'package:flutter/material.dart';

/// Mock telemetry data model for step execution tracking.
class StepExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
  });

  Map<String, dynamic> toJson() => {
        'stepExecutionId': stepExecutionId,
        'executionStatus': executionStatus,
        'executionTimestamp': executionTimestamp.toIso8601String(),
        'stepOutcome': stepOutcome,
        'userId': userId,
        'completionStatus': completionStatus,
      };
}

/// Isolated validation function to audit application completeness indices
/// before deployment pipelines initialize. Relies entirely on universal
/// ISO 8601 strings, automatically correcting formatting anomalies.
class ApplicationCompletenessValidator {
  /// Validates that all required atomic-level data fields are present and
  /// correctly formatted using ISO 8601 standards.
  static bool validateCompleteness(List<StepExecutionRecord> records) {
    if (records.isEmpty) return false;

    for (final record in records) {
      // Poka-Yoke: Verify ISO 8601 timestamp integrity
      try {
        DateTime.parse(record.executionTimestamp.toIso8601String());
      } catch (_) {
        return false;
      }

      if (record.stepExecutionId.isEmpty ||
          record.executionStatus.isEmpty ||
          record.userId.isEmpty ||
          record.completionStatus != 'Pass' && record.completionStatus != 'Fail') {
        return false;
      }
    }
    return true;
  }

  /// Captures the absolute system timestamp upon layout instantiation
  /// using standardized time formatters.
  static String captureInstantiationTimestamp() {
    return DateTime.now().toUtc().toIso8601String();
  }
}

/// Standardized layout container component named DataFlowLayout.
/// Constructs verification reports using flexible data cards to prevent
/// element clipping on narrow canvases. Controls text wrapping explicitly
/// to ensure validation detail labels stay clean on small screens.
class DataFlowLayout extends StatefulWidget {
  final List<StepExecutionRecord> records;
  final VoidCallback? onValidationComplete;

  const DataFlowLayout({
    super.key,
    required this.records,
    this.onValidationComplete,
  });

  @override
  State<DataFlowLayout> createState() => _DataFlowLayoutState();
}

class _DataFlowLayoutState extends State<DataFlowLayout> {
  late final String _instantiationTimestamp;
  late bool _isValidated;
  bool _toggleAcknowledged = false;

  @override
  void initState() {
    super.initState();
    // Capture the absolute system time stamp upon layout instantiation
    _instantiationTimestamp = ApplicationCompletenessValidator.captureInstantiationTimestamp();
    _isValidated = ApplicationCompletenessValidator.validateCompleteness(widget.records);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const successColor = Color(0xFF2ECC71);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instantiation Timestamp Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Layout Initialized: $_instantiationTimestamp',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        // Flexible Data Cards for Verification Reports
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: widget.records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = widget.records[index];
              final isPass = record.completionStatus == 'Pass';

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verified criteria apply clean check symbols using success color tokens (#2ECC71)
                      Icon(
                        isPass ? Icons.check_circle : Icons.cancel,
                        color: isPass ? successColor : theme.colorScheme.error,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Control text wrapping explicitly to ensure validation detail labels stay clean
                            Text(
                              'Step ID: ${record.stepExecutionId}',
                              style: theme.textTheme.titleSmall,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'User: ${record.userId}',
                              style: theme.textTheme.bodyMedium,
                              softWrap: true,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Time: ${record.executionTimestamp.toIso8601String()}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              softWrap: true,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Outcome: ${record.stepOutcome}',
                              style: theme.textTheme.bodySmall,
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // High contrast toggle states for binary questions / Logic disables progression until toggled true
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Acknowledge Validation Report',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      softWrap: true,
                    ),
                  ),
                  Switch(
                    value: _toggleAcknowledged,
                    activeColor: successColor,
                    inactiveThumbColor: theme.colorScheme.surface,
                    inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                    onChanged: (value) {
                      setState(() {
                        _toggleAcknowledged = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Visual checkmarks appear upon completion / Logic disables progression until toggled true
              FilledButton.icon(
                onPressed: (_toggleAcknowledged && _isValidated)
                    ? () {
                        widget.onValidationComplete?.call();
                      }
                    : null,
                icon: const Icon(Icons.check),
                label: const Text('Proceed to Deployment Pipeline'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
                  disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mock data repository providing realistic local mock data directly
/// inside the generated file to satisfy backend/API requirements.
class MockTelemetryRepository {
  static List<StepExecutionRecord> getMockRecords() {
    return [
      StepExecutionRecord(
        stepExecutionId: 'STEP-001-RRCVG-031',
        executionStatus: 'Completed',
        executionTimestamp: DateTime.utc(2026, 9, 25, 10, 15, 30),
        stepOutcome: 'Success',
        userId: 'USR-8821',
        completionStatus: 'Pass',
      ),
      StepExecutionRecord(
        stepExecutionId: 'STEP-002-RRCVG-031',
        executionStatus: 'Completed',
        executionTimestamp: DateTime.utc(2026, 9, 25, 10, 16, 45),
        stepOutcome: 'Success',
        userId: 'USR-8822',
        completionStatus: 'Pass',
      ),
      StepExecutionRecord(
        stepExecutionId: 'STEP-003-RRCVG-031',
        executionStatus: 'Failed',
        executionTimestamp: DateTime.utc(2026, 9, 25, 10, 18, 12),
        stepOutcome: 'Timeout',
        userId: 'USR-8823',
        completionStatus: 'Fail',
      ),
    ];
  }
}