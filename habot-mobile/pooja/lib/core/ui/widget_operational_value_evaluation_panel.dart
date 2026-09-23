import 'package:flutter/material.dart';

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
            horizontal: isCompact ? WidgetOperationalValueEvaluationPanelTokens.xs : (isExpanded ? WidgetOperationalValueEvaluationPanelTokens.lg : WidgetOperationalValueEvaluationPanelTokens.sm),
          ),
          child: Padding(
            padding: isCompact ? WidgetOperationalValueEvaluationPanelTokens.paddingSm : WidgetOperationalValueEvaluationPanelTokens.paddingMd,
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
                    WidgetOperationalValueEvaluationPanelTokens.hGapMd,
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
                WidgetOperationalValueEvaluationPanelTokens.vGapMd,

                Text(
                  'Operational Priority F-Pattern Hierarchy (Cols M & N | ${isCompact ? "Compact" : (isExpanded ? "Expanded" : "Medium")})',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                WidgetOperationalValueEvaluationPanelTokens.vGapXs,
                ..._widgets.map((w) {
                  final isVital = w.tier.contains('Tier 1');
                  final isPulsing = w.pulse;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPulsing
                          ? WidgetOperationalValueEvaluationPanelTokens.error.withValues(alpha: 0.15)
                          : isVital
                              ? WidgetOperationalValueEvaluationPanelTokens.brandPrimary.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPulsing
                            ? WidgetOperationalValueEvaluationPanelTokens.error
                            : isVital
                                ? WidgetOperationalValueEvaluationPanelTokens.brandPrimary
                                : colorScheme.outlineVariant,
                        width: isPulsing ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isVital ? Icons.star : Icons.circle_outlined,
                          size: 16,
                          color: isPulsing ? WidgetOperationalValueEvaluationPanelTokens.error : (isVital ? WidgetOperationalValueEvaluationPanelTokens.brandPrimary : Colors.grey),
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

                WidgetOperationalValueEvaluationPanelTokens.vGapMd,
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

                WidgetOperationalValueEvaluationPanelTokens.vGapMd,
                Container(
                  padding: WidgetOperationalValueEvaluationPanelTokens.paddingSm,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class WidgetOperationalValueEvaluationPanelTokens {
  // Brand & Semantic Color Tokens
  static const Color brandPrimary = Color(0xFF2E86C1);
  static const Color onBrandPrimary = Color(0xFFFFFFFF);
  static const Color brandPrimaryContainer = Color(0xFFD6EAF8);
  static const Color onBrandPrimaryContainer = Color(0xFF1B4F72);
  static const Color brandPrimaryHoverOverlay = Color(0x1F2E86C1);
  static const Color brandPrimaryActiveOverlay = Color(0x3D2E86C1);

  static const Color primary = brandPrimary;
  static const Color primarySeed = Color(0xFF6750A4);
  static const Color secondarySeed = Color(0xFF625B71);
  static const Color tertiarySeed = Color(0xFF7D5260);
  static const Color neutralSeed = Color(0xFF605D62);

  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD0F8CE);
  static const Color onSuccessContainer = Color(0xFF002204);

  static const Color warning = Color(0xFFED6C02);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFDCC6);
  static const Color onWarningContainer = Color(0xFF341100);

  static const Color info = Color(0xFF0288D1);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFCBE6FF);
  static const Color onInfoContainer = Color(0xFF001E30);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightOnError = Color(0xFFFFFFFF);

  static const Color neutralLight = Color(0xFFF5F5F5);
  static const Color neutralDark = Color(0xFF212121);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  // Elevation Tokens
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
  static const double level5 = 12.0;

  // Spacing & Layout Tokens (4dp Metric Grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double mdSm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);

  static const Widget vGapXs = SizedBox(height: xs);
  static const Widget vGapSm = SizedBox(height: sm);
  static const Widget vGapMd = SizedBox(height: md);
  static const Widget vGapLg = SizedBox(height: lg);
  static const Widget vGapXl = SizedBox(height: xl);

  static const Widget hGapXs = SizedBox(width: xs);
  static const Widget hGapSm = SizedBox(width: sm);
  static const Widget hGapMd = SizedBox(width: md);
  static const Widget hGapLg = SizedBox(width: lg);
  static const Widget hGapXl = SizedBox(width: xl);
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: WidgetOperationalValueEvaluationPanel(),
          ),
        ),
      ),
    ),
  );
}
