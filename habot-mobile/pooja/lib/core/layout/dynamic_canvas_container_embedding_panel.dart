import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Step 41: BPTR-0693-A10 - Dynamic Canvas Container Embedding Engine
/// Embeds dynamic layout canvas containers on report project workspaces with fluid responsive grid scaling.
/// Strictly aligned with the 49 columns of `my steps.xlsx` (Row 103, Seq 5168).
class DynamicCanvasContainerEmbeddingPanel extends StatefulWidget {
  const DynamicCanvasContainerEmbeddingPanel({super.key});

  @override
  State<DynamicCanvasContainerEmbeddingPanel> createState() => _DynamicCanvasContainerEmbeddingPanelState();
}

class _DynamicCanvasContainerEmbeddingPanelState extends State<DynamicCanvasContainerEmbeddingPanel> {
  // 49-Column Data Requirement & Lineage Fields (Cols O & AQ)
  int _canvasContainerCount = 3;
  final double _containerWidth = 320.0;
  bool _showExecutionLog = false;

  final String _metricName = 'Design System / Layout Consistency Score';
  final double _floorBoundary = 90.0;
  final double _optimalTarget = 97.0;
  final double _ceilingBoundary = 100.0;
  final double _consistencyScore = 97.0;

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'workspaceName': 'Report Canvas Project Workspace',
      'workspaceId': 'WS-REPORT-0693-A10',
      'workspaceConfiguration': 'Dynamic Multi-Canvas Grid',
      'memberList': 'Pooja, Lead Architect',
      'workspaceStatus': 'ACTIVE',
      'completionStatus': 'Good (Scale: Good/Average/Poor)',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESS-BPTR-0693-A10',
      'metadata': {
        'taskCode': 'BPTR-0693-A10',
        'row': 103,
        'seq': 5168,
        'assigned': 'Pooja',
        'metricName': _metricName,
        'floor': _floorBoundary,
        'target': _optimalTarget,
        'ceiling': _ceilingBoundary,
        'unit': 'Good (Scale: Good/Average/Poor)',
        'consistencyScore': _consistencyScore,
        'canvasContainerCount': _canvasContainerCount,
        'containerWidth': _containerWidth,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final horizontalPadding = isExpanded
            ? AppSpacingTokens.paddingXl
            : (isCompact ? AppSpacingTokens.paddingSm : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(
            vertical: isCompact ? 4 : 8,
            horizontal: isExpanded ? 16 : 0,
          ),
          child: Padding(
            padding: horizontalPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.dashboard_customize_outlined, color: theme.colorScheme.primary),
                    ),
                    AppSpacingTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BPTR-0693-A10: Dynamic Canvas Embedding Engine',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isCompact ? 13 : 15,
                            ),
                          ),
                          Text(
                            'Global Ref: BPTR-0693 | Seq: 5168 | Assigned: Pooja (UDF)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text('Consistency: ${_consistencyScore.toInt()}%'),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                    ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                Text(
                  'Dynamic Canvas Grid Workspace (Cols F, Z: Responsive Canvas Blocks)',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacingTokens.vGapXs,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_canvasContainerCount, (i) {
                      return Container(
                        width: isCompact ? 120 : (isExpanded ? 160 : 140),
                        height: 80,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Canvas #${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            const Spacer(),
                            const Text('Fluid Grid Block', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                AppSpacingTokens.vGapMd,

                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: () => setState(() => _canvasContainerCount = _canvasContainerCount > 1 ? _canvasContainerCount - 1 : 1),
                      child: const Text('Remove Block'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: () => setState(() => _canvasContainerCount = _canvasContainerCount < 6 ? _canvasContainerCount + 1 : 6),
                      child: const Text('Add Canvas Block'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      icon: Icon(_showExecutionLog ? Icons.visibility_off : Icons.receipt_long),
                      tooltip: 'Toggle Audit Telemetry',
                      onPressed: () => setState(() => _showExecutionLog = !_showExecutionLog),
                    ),
                  ],
                ),

                if (_showExecutionLog) ...[
                  AppSpacingTokens.vGapMd,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: SelectableText(
                      toExecutionLogJson().toString(),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ],

                AppSpacingTokens.vGapMd,
                Container(
                  padding: AppSpacingTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('49-Column Specification Alignment (my steps.xlsx):', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('• Metric: $_metricName | Floor: $_floorBoundary% | Target: $_optimalTarget% | Ceiling: $_ceilingBoundary%', style: const TextStyle(fontSize: 10)),
                      Text('• Data Collected (Col AQ): Canvas Blocks ($_canvasContainerCount), Container Width ($_containerWidth), User ID', style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
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
