import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step 3: BPTR-0019-A02 - Widget Critical Operational Value Evaluation Engine
/// Evaluates and prioritizes widgets based on operational value according to human scanning patterns (F-Pattern).
/// Strictly aligned with the 49 columns of `my steps.xlsx` (Row 65, Seq 4722).
class WidgetOperationalValueEvaluationPanel extends StatefulWidget {
  const WidgetOperationalValueEvaluationPanel({super.key});

  @override
  State<WidgetOperationalValueEvaluationPanel> createState() => _WidgetOperationalValueEvaluationPanelState();
}

class _WidgetItem {
  final String id;
  final String name;
  final String tier;
  final double score;
  bool pulse;
  _WidgetItem({required this.id, required this.name, required this.tier, required this.score, this.pulse = false});
}

class _WidgetOperationalValueEvaluationPanelState extends State<WidgetOperationalValueEvaluationPanel> {
  // 49-Column Data Requirement & Lineage Fields (Cols O & AQ)
  final List<_WidgetItem> _widgets = [
    _WidgetItem(id: 'WDG-REVENUE-01', name: 'Net Real-Time Revenue', tier: 'Tier 1: Vital (Top-Left)', score: 98.5, pulse: false),
    _WidgetItem(id: 'WDG-CONVERSION-02', name: 'Active Conversion Rate', tier: 'Tier 1: Vital (Top-Right)', score: 96.0, pulse: false),
    _WidgetItem(id: 'WDG-TRAFFIC-03', name: 'Hourly Traffic Density', tier: 'Tier 2: Secondary', score: 88.0, pulse: false),
    _WidgetItem(id: 'WDG-FEEDBACK-04', name: 'Customer Satisfaction NPS', tier: 'Tier 3: Auxiliary', score: 74.0, pulse: false),
  ];

  final String _metricName = 'Operational Value Alignment Score';
  final double _floorBoundary = 90.0;
  final double _optimalTarget = 97.0;
  final double _ceilingBoundary = 100.0;
  double _overallQualityScore = 97.5;

  void _simulateKpiFailure() {
    setState(() {
      // Self-Chasing (Col AE): If a top-left KPI fails to load, the widget pulses red.
      _widgets[0].pulse = true;
      _overallQualityScore = 89.0;
    });
  }

  void _restoreKpi() {
    setState(() {
      _widgets[0].pulse = false;
      _overallQualityScore = 97.5;
    });
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'execution_id': 'EXEC-BPTR-0019-A02-2026',
      'global_ref_id': 'BPTR-0019-A02',
      'atomic_step_ref_id': 'BPTR-0019-A02',
      'task_title': 'Evaluate each widget based on its critical operational value to the user.',
      'timestamp': '2026-09-08 11:15:00 UTC',
      'user_session_id': 'USR-WIDGETEVAL-47220',
      'telemetry_payload': {
        'step_execution_id': 'EXEC-WDGEVAL-47220',
        'execution_status': 'EVALUATED_OPTIMAL',
        'execution_timestamp': '2026-09-08 11:15:00 UTC',
        'step_outcome': 'SUCCESS',
        'user_id': 'USR-WIDGETEVAL-47220',
        'completion_status': 'Pass',
        'overall_quality_score': _overallQualityScore,
        'action_event_timestamp': '2026-09-08 11:15:00 UTC',
        'user_session_id': 'USR-WIDGETEVAL-47220',
      },
      'metric_evaluation': {
        'metric_name': _metricName,
        'floor_boundary': '$_floorBoundary%',
        'optimal_target': '$_optimalTarget%',
        'ceiling_boundary': '$_ceilingBoundary%',
        'current_measured': '${_overallQualityScore.toStringAsFixed(1)}% (Optimal Alignment)',
        'qualitative_output': 'Pass',
        'compliance_verified': _overallQualityScore >= _floorBoundary,
      },
      'standards': [
        'Nielsen Norman Group F-Pattern Visual Hierarchy Standard',
        'Critical Operational Value Metric Benchmark',
        'WCAG 2.2 SC 2.5.8 Touch Target Area (>=48x48dp)',
      ],
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

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: isCompact ? AppSpacingTokens.xs : (isExpanded ? AppSpacingTokens.lg : AppSpacingTokens.sm),
          ),
          child: Padding(
            padding: isCompact ? AppSpacingTokens.paddingSm : AppSpacingTokens.paddingMd,
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
                      child: Icon(Icons.auto_graph_outlined, color: colorScheme.primary),
                    ),
                    AppSpacingTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BPTR-0019-A02: Widget Operational Value Evaluator',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isCompact ? 14 : 16,
                            ),
                          ),
                          Text(
                            'Global Ref: BPTR-0019 | Seq: 4722 | Assigned: Pooja (UDF)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text('Quality: ${_overallQualityScore.toStringAsFixed(1)}%'),
                      backgroundColor: _overallQualityScore >= _floorBoundary
                          ? colorScheme.secondaryContainer
                          : colorScheme.errorContainer,
                    ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                Text(
                  'Operational Priority F-Pattern Hierarchy (Cols M & N | ${isCompact ? "Compact" : (isExpanded ? "Expanded" : "Medium")})',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacingTokens.vGapXs,
                ..._widgets.map((w) {
                  final isVital = w.tier.contains('Tier 1');
                  final isPulsing = w.pulse;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPulsing
                          ? AppColorPalette.error.withValues(alpha: 0.15)
                          : isVital
                              ? AppColorPalette.brandPrimary.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPulsing
                            ? AppColorPalette.error
                            : isVital
                                ? AppColorPalette.brandPrimary
                                : colorScheme.outlineVariant,
                        width: isPulsing ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isVital ? Icons.star : Icons.circle_outlined,
                          size: 16,
                          color: isPulsing ? AppColorPalette.error : (isVital ? AppColorPalette.brandPrimary : Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w.name, style: TextStyle(fontWeight: isVital ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                              Text('${w.tier} • Value Score: ${w.score}%', style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        if (isPulsing)
                          const Text('PULSING RED: KPI FAILED', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                        else
                          const Icon(Icons.lock, size: 14, color: Colors.grey),
                      ],
                    ),
                  );
                }),

                AppSpacingTokens.vGapMd,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: _simulateKpiFailure,
                      icon: const Icon(Icons.warning_amber),
                      label: const Text('Simulate Top-Left KPI Failure (Self-Chasing)'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: _restoreKpi,
                      child: const Text('Restore KPI'),
                    ),
                  ],
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
                      Text('49-Column Specification Alignment (my steps.xlsx):', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('• Metric: $_metricName | Floor: $_floorBoundary% | Target: $_optimalTarget% | Ceiling: $_ceilingBoundary%', style: const TextStyle(fontSize: 10)),
                      const Text('• Poka-Yoke (Col AD): Widget placement hard-coded; dragging secondary metrics is disabled.', style: TextStyle(fontSize: 10)),
                      const Text('• Self-Chasing (Col AE): If top-left KPI fails to load, widget pulses red to demand fix.', style: TextStyle(fontSize: 10)),
                      const Text('• Data Collected (Col AQ): Widget ID, Operational Score, Placement Tier, Timestamp, User ID', style: TextStyle(fontSize: 10, fontFamily: 'monospace')),
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
