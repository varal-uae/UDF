/*
 * CPNCA-007-A03 — Grouped Data Interaction Steps
 * 
 * Setup Step (Action): Group complex, disorganized data elements into clearly simplified, digestible interaction steps.
 * Metric Name: General Implementation Task Compliance (Complete/Partial/Not Complete)
 * Quality Standard: Confirm the atomic step's output matches the parent Implementation Step's stated intent exactly, with no scope drift, before marking it complete.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class ExceptionStepItem {
  final String stepId;
  final String title;
  final String description;
  final Map<String, String> dataFields;
  final bool isCompleted;

  const ExceptionStepItem({
    required this.stepId,
    required this.title,
    required this.description,
    required this.dataFields,
    this.isCompleted = false,
  });
}

class GroupedDataInteractionStepsPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const GroupedDataInteractionStepsPanel({
    super.key,
    this.globalRefId = 'CPNCA-007',
    this.atomicStepRefId = 'CPNCA-007-A03',
    this.sequenceOrder = '8327',
  });

  @override
  State<GroupedDataInteractionStepsPanel> createState() =>
      _GroupedDataInteractionStepsPanelState();
}

class _GroupedDataInteractionStepsPanelState
    extends State<GroupedDataInteractionStepsPanel> {
  int _activeStepIndex = 0;
  final List<bool> _stepCompletion = [false, false, false];

  final List<ExceptionStepItem> _steps = const [
    ExceptionStepItem(
      stepId: 'STEP-01-INGRESS',
      title: 'Step 1: Payload Ingress Validation',
      description: 'Isolate corrupted packet headers and confirm inbound digest checksum.',
      dataFields: {
        'Packet ID': 'PKT-9041-A8',
        'Checksum SHA': '8e2b...41f0',
        'Source Node': 'KAFKA-CLUSTER-04',
      },
    ),
    ExceptionStepItem(
      stepId: 'STEP-02-LEDGER',
      title: 'Step 2: Ledger Delta Re-calculation',
      description: 'Reconcile points liabilities against dual-entry accounting journals.',
      dataFields: {
        'Ledger Entry': 'LDG-2026-0908',
        'Liability Delta': '-5,000 Points',
        'Balanced State': 'True (Validated)',
      },
    ),
    ExceptionStepItem(
      stepId: 'STEP-03-CONFIRM',
      title: 'Step 3: Operator State Authorization',
      description: 'Apply operator sign-off and dispatch state transition notification.',
      dataFields: {
        'Operator': 'POOJA-QA-LEAD',
        'Authorization Tier': 'TIER-3-CHIEF',
        'Action': 'RELEASE_STATE_LOCK',
      },
    ),
  ];

  void _nextStep() {
    if (_activeStepIndex < _steps.length - 1) {
      setState(() {
        _stepCompletion[_activeStepIndex] = true;
        _activeStepIndex++;
      });
    } else {
      setState(() {
        _stepCompletion[_activeStepIndex] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ All Grouped Exception Interaction Steps Verified & Completed!'),
          backgroundColor: AppColorPalette.success,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _prevStep() {
    if (_activeStepIndex > 0) {
      setState(() {
        _activeStepIndex--;
      });
    }
  }

  Map<String, dynamic> toExecutionLogJson() {
    final allComplete = _stepCompletion.every((element) => element);
    return {
      'stepExecutionId': 'EXEC-${widget.globalRefId}-2026',
      'executionStatus': allComplete ? 'COMPLETE' : 'IN_PROGRESS',
      'executionTimestamp': DateTime.now().toUtc().toIso8601String(),
      'stepOutcome': allComplete ? 'SUCCESS' : 'PENDING_ACTIONS',
      'userId': 'USER-AUTO-B14',
      'completionStatus': allComplete ? 'Complete' : 'Partial',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-${widget.globalRefId}',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 139,
        'seq': widget.sequenceOrder,
        'assigned': 'Pooja',
        'metricName': 'General Implementation Task Compliance',
        'floor': 'Task functionally implemented, not yet peer-reviewed',
        'target': 'Task implemented, peer-reviewed, matches parent objective',
        'ceiling': 'N/A (gate, not a range)',
        'unit': 'Complete/Partial/Not Complete',
        'activeStep': _activeStepIndex + 1,
        'totalSteps': _steps.length,
        'isAllCompleted': allComplete,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allDone = _stepCompletion.every((element) => element);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final contentPadding = isCompact
            ? AppSpacingTokens.paddingSm
            : (isExpanded ? AppSpacingTokens.paddingLg : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: allDone
                  ? AppColorPalette.success
                  : AppColorPalette.brandPrimary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColorPalette.brandPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.layers_rounded,
                        color: AppColorPalette.brandPrimary,
                        size: 24,
                      ),
                    ),
                    AppSpacingTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.globalRefId} / ${widget.atomicStepRefId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColorPalette.brandPrimary,
                              fontSize: isExpanded ? 16 : 14,
                            ),
                          ),
                          Text(
                            'Grouped Data Interaction Steps (Seq: ${widget.sequenceOrder})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: isCompact ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: allDone
                            ? AppColorPalette.successContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        allDone ? 'Complete (3/3)' : 'Step ${_activeStepIndex + 1}/3',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: allDone
                              ? AppColorPalette.onSuccessContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                // Progress Indicator
                LinearProgressIndicator(
                  value: (_activeStepIndex + (_stepCompletion[_activeStepIndex] ? 1 : 0.5)) / _steps.length,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: AppColorPalette.brandPrimary,
                ),
                AppSpacingTokens.vGapMd,

                // Step Content Card
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey<int>(_activeStepIndex),
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _steps[_activeStepIndex].title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColorPalette.brandPrimary,
                              ),
                            ),
                            Icon(
                              _stepCompletion[_activeStepIndex]
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: _stepCompletion[_activeStepIndex]
                                  ? AppColorPalette.success
                                  : Colors.grey,
                              size: 18,
                            ),
                          ],
                        ),
                        AppSpacingTokens.vGapXs,
                        Text(
                          _steps[_activeStepIndex].description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        AppSpacingTokens.vGapMd,
                        const Text(
                          'Digestible Data Fields (Max 3-5 fields per card):',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        AppSpacingTokens.vGapXs,
                        ..._steps[_activeStepIndex].dataFields.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                Text(entry.value,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace')),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                AppSpacingTokens.vGapMd,

                // Navigation Controls (Min 48x48dp interactive touch target)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: OutlinedButton.icon(
                        onPressed: _activeStepIndex > 0 ? _prevStep : null,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Previous'),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: FilledButton.icon(
                        onPressed: _nextStep,
                        icon: Icon(allDone ? Icons.done_all_rounded : Icons.arrow_forward_rounded),
                        label: Text(allDone ? 'Re-confirm Step' : (_activeStepIndex == _steps.length - 1 ? 'Complete All' : 'Next Step')),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColorPalette.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
