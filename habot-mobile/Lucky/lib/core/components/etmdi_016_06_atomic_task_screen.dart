// ETMDI-016-06 — Atomic Task Screen UI for Rule of AND deconstruction.
// Renders a single-focus mobile task using M3 Cards, soft shapes, centered alignment, and generous padding.

import 'package:flutter/material.dart';

class AtomicTaskScreenETMDI01606 extends StatelessWidget {
  const AtomicTaskScreenETMDI01606({
    super.key,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    this.stepExecutionId,
    this.executionStatus,
    this.executionTimestamp,
    this.stepOutcome,
    this.userId,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final String? stepExecutionId;
  final String? executionStatus;
  final DateTime? executionTimestamp;
  final String? stepOutcome;
  final String? userId;

  static bool shouldTriggerAtomicStep({
    required double remainingDistance,
    required double triggerBuffer,
  }) {
    return remainingDistance > triggerBuffer;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Semantics(
                container: true,
                label: 'Atomic task: $title',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 2,
                      shadowColor: colorScheme.shadow,
                      surfaceTintColor: colorScheme.surfaceTint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 48,
                              color: colorScheme.primary,
                              semanticLabel: 'Single action task',
                            ),
                            const SizedBox(height: 16),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              description,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: onAction,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(actionLabel),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AuditStripETMDI01606(
                      stepExecutionId: stepExecutionId,
                      executionStatus: executionStatus,
                      executionTimestamp: executionTimestamp,
                      stepOutcome: stepOutcome,
                      userId: userId,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuditStripETMDI01606 extends StatelessWidget {
  const _AuditStripETMDI01606({
    this.stepExecutionId,
    this.executionStatus,
    this.executionTimestamp,
    this.stepOutcome,
    this.userId,
  });

  final String? stepExecutionId;
  final String? executionStatus;
  final DateTime? executionTimestamp;
  final String? stepOutcome;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = <String>[
      if (stepExecutionId != null) 'Step Execution ID: $stepExecutionId',
      if (executionStatus != null) 'Execution Status: $executionStatus',
      if (executionTimestamp != null)
        'Execution Timestamp: ${executionTimestamp!.toIso8601String()}',
      if (stepOutcome != null) 'Step Outcome: $stepOutcome',
      if (userId != null) 'User ID: $userId',
    ];

    if (entries.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          entries.join('  •  '),
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
