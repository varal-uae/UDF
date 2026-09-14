// FIEVR-005-A07 — Dynamic Form Completeness Checklist & Live Verification Panel.
// Mobile-first responsive checklist tracking form validation state, displaying pre-verified color indicator badges, and enforcing blunder-proofing (Poka-Yoke) submission locks.

import 'package:flutter/material.dart';

/// Status of an individual form completeness requirement item.
enum ChecklistItemStatus {
  complete,
  partial,
  notComplete,
}

/// Configuration for a specific field/step item within the completeness checklist.
class FormChecklistItem {
  final String id;
  final String label;
  final String? instructionNote;
  final bool isCompleted;
  final bool hasError;
  final String? errorMessage;

  const FormChecklistItem({
    required this.id,
    required this.label,
    this.instructionNote,
    this.isCompleted = false,
    this.hasError = false,
    this.errorMessage,
  });

  ChecklistItemStatus get status {
    if (isCompleted) return ChecklistItemStatus.complete;
    if (hasError) return ChecklistItemStatus.notComplete;
    return ChecklistItemStatus.partial;
  }

  FormChecklistItem copyWith({
    String? id,
    String? label,
    String? instructionNote,
    bool? isCompleted,
    bool? hasError,
    String? errorMessage,
  }) {
    return FormChecklistItem(
      id: id ?? this.id,
      label: label ?? this.label,
      instructionNote: instructionNote ?? this.instructionNote,
      isCompleted: isCompleted ?? this.isCompleted,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Telemetry record emitted during step execution tracking for GCP/BigQuery alignment.
class FormCompletenessTelemetry {
  final String stepExecutionId;
  final String globalReferenceId;
  final String atomicStepsReferenceId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String? userId;
  final String completionStatus; // 'Complete' | 'Partial' | 'Not Complete'
  final double scorePercentage;

  const FormCompletenessTelemetry({
    required this.stepExecutionId,
    this.globalReferenceId = 'FIEVR-005',
    this.atomicStepsReferenceId = 'FIEVR-005-A07',
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    this.userId,
    required this.completionStatus,
    required this.scorePercentage,
  });

  Map<String, dynamic> toJson() => {
        'stepExecutionId': stepExecutionId,
        'globalReferenceId': globalReferenceId,
        'atomicStepsReferenceId': atomicStepsReferenceId,
        'executionStatus': executionStatus,
        'executionTimestamp': executionTimestamp.toIso8601String(),
        'stepOutcome': stepOutcome,
        'userId': userId,
        'completionStatus': completionStatus,
        'scorePercentage': scorePercentage,
      };
}

/// Dynamic Form Completeness Checklist panel designed for mobile-first layouts.
/// Provides visual validation feedback and disables submission actions until 100% completion.
class FormCompletenessChecklist extends StatefulWidget {
  final List<FormChecklistItem> items;
  final String? title;
  final String? userId;
  final String stepExecutionId;
  final ValueChanged<FormCompletenessTelemetry>? onTelemetryEmitted;
  final Widget Function(BuildContext context, bool canSubmit, double completionRate)? submitBuilder;
  final VoidCallback? onSubmit;

  const FormCompletenessChecklist({
    super.key,
    required this.items,
    required this.stepExecutionId,
    this.title,
    this.userId,
    this.onTelemetryEmitted,
    this.submitBuilder,
    this.onSubmit,
  });

  @override
  State<FormCompletenessChecklist> createState() => _FormCompletenessChecklistState();
}

class _FormCompletenessChecklistState extends State<FormCompletenessChecklist> {
  late double _lastScore;

  @override
  void initState() {
    super.initState();
    _lastScore = _calculateScore();
    _emitTelemetryIfNeeded();
  }

  @override
  void didUpdateWidget(covariant FormCompletenessChecklist oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentScore = _calculateScore();
    if (currentScore != _lastScore) {
      _lastScore = currentScore;
      _emitTelemetryIfNeeded();
    }
  }

  double _calculateScore() {
    if (widget.items.isEmpty) return 0.0;
    final completedCount = widget.items.where((e) => e.isCompleted).length;
    return completedCount / widget.items.length;
  }

  String _resolveCompletionStatus(double score) {
    if (score >= 1.0) return 'Complete';
    if (score > 0.0) return 'Partial';
    return 'Not Complete';
  }

  void _emitTelemetryIfNeeded() {
    final score = _calculateScore();
    final status = _resolveCompletionStatus(score);
    final telemetry = FormCompletenessTelemetry(
      stepExecutionId: widget.stepExecutionId,
      executionStatus: score >= 1.0 ? 'Success' : 'In-Progress',
      executionTimestamp: DateTime.now().toUtc(),
      stepOutcome: score >= 1.0 ? 'Pass' : 'PendingRequirements',
      userId: widget.userId,
      completionStatus: status,
      scorePercentage: score * 100,
    );
    widget.onTelemetryEmitted?.call(telemetry);
  }

  Color _getStatusColor(ChecklistItemStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ChecklistItemStatus.complete:
        return const Color(0xFF2E7D32); // Pre-verified green
      case ChecklistItemStatus.partial:
        return const Color(0xFFF57C00); // Pre-verified amber
      case ChecklistItemStatus.notComplete:
        return colorScheme.error; // Pre-verified red
    }
  }

  Widget _buildStatusBadge(ChecklistItemStatus status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _getStatusColor(status, colorScheme);
    final label = switch (status) {
      ChecklistItemStatus.complete => 'Complete',
      ChecklistItemStatus.partial => 'Pending',
      ChecklistItemStatus.notComplete => 'Required',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final score = _calculateScore();
    final is100Percent = score >= 1.0;
    final percentageText = '${(score * 100).toInt()}%';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: is100Percent ? Colors.green.shade300 : colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row: Title and Percentage Track
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title ?? 'Form Completeness',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: is100Percent
                        ? Colors.green.withValues(alpha: 0.15)
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    percentageText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: is100Percent ? Colors.green.shade800 : colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Continuous Progress Track Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  is100Percent ? Colors.green : colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // List of Checklist items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.items.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final status = item.status;
                final statusColor = _getStatusColor(status, colorScheme);

                return Semantics(
                  label: '${item.label}, status: ${status.name}',
                  child: Container(
                    decoration: item.hasError
                        ? BoxDecoration(
                            color: colorScheme.error.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colorScheme.error, width: 1),
                          )
                        : null,
                    padding: item.hasError ? const EdgeInsets.all(8) : EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              item.isCompleted
                                  ? Icons.check_circle_rounded
                                  : item.hasError
                                      ? Icons.error_outline_rounded
                                      : Icons.radio_button_unchecked_rounded,
                              color: statusColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: item.isCompleted
                                      ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)
                                      : theme.textTheme.bodyMedium?.color,
                                  decoration:
                                      item.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            _buildStatusBadge(status, context),
                          ],
                        ),
                        // Instruction / Alert Note
                        if (item.instructionNote != null || item.errorMessage != null) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 28),
                            child: Text(
                              item.errorMessage ?? item.instructionNote!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: item.hasError ? colorScheme.error : theme.hintColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Poka-Yoke Submit Lock
            if (widget.submitBuilder != null)
              widget.submitBuilder!(context, is100Percent, score)
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: is100Percent ? widget.onSubmit : null,
                  icon: const Icon(Icons.send_rounded),
                  label: Text(is100Percent
                      ? 'Submit Form'
                      : 'Complete all required steps ($percentageText)'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
