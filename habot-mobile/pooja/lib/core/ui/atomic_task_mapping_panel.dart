import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step 32: BPTR-0437-A02 - Workflow Task Deconstruction & Atomic Mapping Engine
/// Breaks complex workflow tasks into separate atomic steps guided by a clean Material Stepper component.
/// Strictly aligned with the 49 columns of `my steps.xlsx` (Row 94, Seq 5043).
class AtomicTaskMappingPanel extends StatefulWidget {
  const AtomicTaskMappingPanel({super.key});

  @override
  State<AtomicTaskMappingPanel> createState() => _AtomicTaskMappingPanelState();
}

class _AtomicSubTask {
  final String step;
  bool isComplete;
  _AtomicSubTask({required this.step, this.isComplete = false});
}

class _AtomicTaskMappingPanelState extends State<AtomicTaskMappingPanel> {
  // 49-Column Data Requirement & Lineage Fields (Cols O & AQ)
  final List<_AtomicSubTask> _atomicSubTasks = [
    _AtomicSubTask(step: 'Step 1: Schema Ingress Gate', isComplete: true),
    _AtomicSubTask(step: 'Step 2: Business Rule Matrix Evaluation', isComplete: true),
    _AtomicSubTask(step: 'Step 3: Database Mutation Commit', isComplete: false),
  ];

  final String _metricName = 'Data/Field Mapping Accuracy Rate';
  final double _floorBoundary = 97.0;
  final double _optimalTarget = 99.5;
  final double _ceilingBoundary = 100.0;
  final double _mappingAccuracy = 99.5;

  bool get _isWorkflowComplete => _atomicSubTasks.every((t) => t.isComplete);

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'sourceElementId': 'WORKFLOW-TASK-0437',
      'targetElementId': 'ATOMIC-STEP-MAP-0437',
      'mappingRule': 'Deconstruct Complex Workflow into 1-to-1 Atomic Steps',
      'mappingStatus': _isWorkflowComplete ? 'COMPLETE' : 'IN_PROGRESS',
      'mappingValidation': 'Diff Checked Against Spec',
      'completionStatus': 'Pass (Scale: Pass/Fail)',
      'actionEventTimestamp': DateTime.now().toIso8601String(),
      'userSessionId': 'SESS-BPTR-0437-A02',
      'metadata': {
        'taskCode': 'BPTR-0437-A02',
        'row': 94,
        'seq': 5043,
        'assigned': 'Pooja',
        'metricName': _metricName,
        'floor': _floorBoundary,
        'target': _optimalTarget,
        'ceiling': _ceilingBoundary,
        'unit': 'Pass (Scale: Pass/Fail)',
        'accuracy': _mappingAccuracy,
        'subTasksCount': _atomicSubTasks.length,
        'completedCount': _atomicSubTasks.where((t) => t.isComplete).length,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final contentPadding = isCompact
            ? AppSpacingTokens.paddingSm
            : (isExpanded ? AppSpacingTokens.paddingLg : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(
            vertical: isCompact ? 6 : 8,
            horizontal: isExpanded ? 16 : 0,
          ),
          child: Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.linear_scale_outlined, color: colorScheme.primary),
                    ),
                    AppSpacingTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BPTR-0437-A02: Workflow Atomic Step Mapping',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isCompact ? 14 : 16,
                            ),
                          ),
                          Text(
                            'Global Ref: BPTR-0437 | Seq: 5043 | Assigned: Pooja (UDF)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text('Accuracy: $_mappingAccuracy%'),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                Text(
                  'Linear Horizontal Progression (Cols M, Y, Z: One-at-a-time Progression | ${isCompact ? "Compact" : (isExpanded ? "Expanded" : "Medium")})',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacingTokens.vGapXs,
                ..._atomicSubTasks.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final task = entry.value;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: task.isComplete
                          ? colorScheme.surface
                          : AppColorPalette.brandPrimary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: task.isComplete
                            ? colorScheme.outlineVariant
                            : AppColorPalette.brandPrimary,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          task.isComplete ? Icons.check_circle : Icons.warning_amber,
                          color: task.isComplete ? AppColorPalette.success : AppColorPalette.brandPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.step,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: task.isComplete ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          child: Switch(
                            value: task.isComplete,
                            onChanged: (val) {
                              setState(() {
                                _atomicSubTasks[idx].isComplete = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                AppSpacingTokens.vGapMd,

                // Poka-Yoke: Complete button visually disabled until every toggle reads Yes
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: _isWorkflowComplete ? AppColorPalette.brandPrimary : null,
                      foregroundColor: _isWorkflowComplete ? Colors.white : null,
                    ),
                    onPressed: _isWorkflowComplete
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Workflow Complete! All atomic sub-tasks passed.')),
                            );
                          }
                        : null, // Poka-Yoke Locked (Col AD)
                    icon: Icon(_isWorkflowComplete ? Icons.done_all : Icons.lock),
                    label: Text(
                      _isWorkflowComplete
                          ? 'Complete Task (All Sub-Tasks Verified)'
                          : 'Complete Disabled (Poka-Yoke: Finish All Steps)',
                    ),
                  ),
                ),

                AppSpacingTokens.vGapMd,
                Container(
                  padding: AppSpacingTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '49-Column Specification Alignment (my steps.xlsx):',
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Metric: $_metricName | Floor: $_floorBoundary% | Target: $_optimalTarget% | Ceiling: $_ceilingBoundary%',
                        style: const TextStyle(fontSize: 10),
                      ),
                      const Text(
                        '• Poka-Yoke (Col AD): Complete button visually disabled until every toggle reads "Yes".',
                        style: TextStyle(fontSize: 10),
                      ),
                      const Text(
                        '• Self-Chasing (Col AE): Unfinished toggles maintain "Active Risk" state, chasing user to finish.',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
