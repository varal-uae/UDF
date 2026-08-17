/*
 * STEP 4: RRCVG-024 — Enforce Binary Checklist Stepper Offboarding Rules
 * 
 * Setup Step (Action): Analyze complex multi-system offboarding manuals provided by Tech, OPS, and HRE teams.
 * Setup Step Description: Define offboarding items, map tool toggles, build vertical stepper UI, code final gate logic.
 * 
 * DEA AUDIT NOTICE:
 * Process Execution Quality (%): Floor 85%, Optimal 95%, Ceiling 100%.
 * Poka-Yoke Gate: The final "Complete Offboarding" button is visually disabled until EVERY SINGLE tool's toggle
 * reads "YES (Revoked)". Unfinished toggles maintain the ticket in an "Active Risk" state on the Security Dashboard.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Auto-advancing to the next step upon successful toggle interaction.
 *   - Clear completed (checkmark) and pending (number) step indicators.
 *   - Smooth accordion expansions and mobile-friendly vertical stepper structure.
 *   - Minimum touch target size >= 48dp on all switches and action buttons.
 * 
 * What Was Done to Complete This Step:
 *   - Created `BinaryChecklistStepper` widget, `OffboardingStepItem` model, and `OffboardingCompletionStatus` enum.
 *   - Implemented vertical step progression, interactive toggles, auto-advancing focus, and hard-locked final submission gate.
 *   - Added required telemetry fields (`stepExecutionId`, `executionStatus`, `actionTimestamp`, `userSessionId`, `completionStatus`).
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

enum OffboardingCompletionStatus {
  complete('Complete/Partial/Not Complete'),
  partial('Partial/Not Complete'),
  notComplete('Not Complete');

  final String label;
  const OffboardingCompletionStatus(this.label);
}

class OffboardingStepItem {
  final String id;
  final String title;
  final String description;
  final String targetSystem;
  final bool isCompleted;
  final String stepExecutionId;
  final String executionStatus;
  final String stepOutcome;
  final String userId;
  final DateTime actionTimestamp;
  final String userSessionId;
  final OffboardingCompletionStatus completionStatus;

  OffboardingStepItem({
    required this.id,
    required this.title,
    required this.description,
    required this.targetSystem,
    this.isCompleted = false,
    String? stepExecutionId,
    this.executionStatus = 'EXEC_IN_PROGRESS',
    this.stepOutcome = 'PENDING_REVOCATION',
    this.userId = 'HRE-ADMIN-01',
    DateTime? actionTimestamp,
    String? userSessionId,
    this.completionStatus = OffboardingCompletionStatus.notComplete,
  })  : stepExecutionId = stepExecutionId ?? 'EXEC-STEP-04',
        actionTimestamp = actionTimestamp ?? DateTime.now(),
        userSessionId = userSessionId ?? 'SESS-HRE-2026';

  OffboardingStepItem copyWith({
    bool? isCompleted,
    String? executionStatus,
    String? stepOutcome,
    OffboardingCompletionStatus? completionStatus,
  }) {
    return OffboardingStepItem(
      id: id,
      title: title,
      description: description,
      targetSystem: targetSystem,
      isCompleted: isCompleted ?? this.isCompleted,
      stepExecutionId: stepExecutionId,
      executionStatus: executionStatus ?? this.executionStatus,
      stepOutcome: stepOutcome ?? this.stepOutcome,
      userId: userId,
      actionTimestamp: DateTime.now(),
      userSessionId: userSessionId,
      completionStatus: completionStatus ?? this.completionStatus,
    );
  }
}

/// Step RRCVG-024: Binary Checklist Stepper for Offboarding Rules.
class BinaryChecklistStepper extends StatefulWidget {
  final List<OffboardingStepItem> initialSteps;
  final ValueChanged<List<OffboardingStepItem>>? onCompletedChanged;

  const BinaryChecklistStepper({
    super.key,
    required this.initialSteps,
    this.onCompletedChanged,
  });

  @override
  State<BinaryChecklistStepper> createState() => _BinaryChecklistStepperState();
}

class _BinaryChecklistStepperState extends State<BinaryChecklistStepper> {
  late List<OffboardingStepItem> _steps;
  int _activeStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _steps = List.from(widget.initialSteps);
  }

  bool get _isAllCompleted => _steps.every((s) => s.isCompleted);

  void _toggleStep(int index, bool value) {
    setState(() {
      _steps[index] = _steps[index].copyWith(
        isCompleted: value,
        executionStatus: value ? 'EXEC_SUCCESS' : 'EXEC_IN_PROGRESS',
        stepOutcome: value ? 'REVOKED_CONFIRMED' : 'ACTIVE_RISK',
        completionStatus: value ? OffboardingCompletionStatus.complete : OffboardingCompletionStatus.notComplete,
      );
      if (value && index < _steps.length - 1) {
        _activeStepIndex = index + 1; // Auto-advance to next step
      }
    });

    widget.onCompletedChanged?.call(_steps);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.verified_user, color: Colors.blue, size: 18),
              const SizedBox(width: 6),
              Text(
                'HRE / IAM Admin Offboarding Sign-Off Gate',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
        ),
        Stepper(
          currentStep: _activeStepIndex,
          onStepTapped: (idx) => setState(() => _activeStepIndex = idx),
          controlsBuilder: (context, details) => const SizedBox.shrink(),
          steps: _steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;

            return Step(
              title: Text(item.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text('System: ${item.targetSystem} | Exec ID: ${item.stepExecutionId}',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              isActive: idx == _activeStepIndex,
              state: item.isCompleted ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.description, style: theme.textTheme.bodyMedium),
                  AppSpacingTokens.vGapSm,
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text('Revoke Access:', style: theme.textTheme.labelMedium),
                      Switch(
                        value: item.isCompleted,
                        onChanged: (val) => _toggleStep(idx, val),
                      ),
                      Text(
                        item.isCompleted ? 'YES (Revoked)' : 'NO (Active Risk)',
                        style: TextStyle(
                          color: item.isCompleted ? colorScheme.primary : colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        AppSpacingTokens.vGapMd,
        Card(
          color: _isAllCompleted ? colorScheme.primaryContainer : colorScheme.errorContainer.withValues(alpha: 0.2),
          child: Padding(
            padding: AppSpacingTokens.paddingMd,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Text(
                  _isAllCompleted ? '100% Revocation Confirmed' : 'Offboarding Gate Locked: Active Access Risks Remain',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isAllCompleted ? colorScheme.onPrimaryContainer : colorScheme.error,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _isAllCompleted
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Offboarding successfully completed! Payload logged.')),
                          );
                        }
                      : null, // Hard-locked gate until 100% complete
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Complete Offboarding'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

