import 'package:flutter/material.dart';

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
            ? DynamicCanvasContainerEmbeddingPanelTokens.paddingXl
            : (isCompact ? DynamicCanvasContainerEmbeddingPanelTokens.paddingSm : DynamicCanvasContainerEmbeddingPanelTokens.paddingMd);

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
                    DynamicCanvasContainerEmbeddingPanelTokens.hGapMd,
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
                DynamicCanvasContainerEmbeddingPanelTokens.vGapMd,

                Text(
                  'Dynamic Canvas Grid Workspace (Cols F, Z: Responsive Canvas Blocks)',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                DynamicCanvasContainerEmbeddingPanelTokens.vGapXs,
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
                DynamicCanvasContainerEmbeddingPanelTokens.vGapMd,

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
                  DynamicCanvasContainerEmbeddingPanelTokens.vGapMd,
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

                DynamicCanvasContainerEmbeddingPanelTokens.vGapMd,
                Container(
                  padding: DynamicCanvasContainerEmbeddingPanelTokens.paddingSm,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class DynamicCanvasContainerEmbeddingPanelTokens {
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
            child: DynamicCanvasContainerEmbeddingPanel(),
          ),
        ),
      ),
    ),
  );
}
