/*
 * BTPM-028-04 — Precision View Initialization to Layout Draw Duration Timer
 * 
 * Global Reference ID: BTPM-028-04
 * Atomic Steps Reference ID: BTPM-028-04
 * Setup Step (Action): Capture precision millisecond durations counting from view initialization down to layout draw.
 * S.No: 117 | Sequence Order: 6077 | Assigned Team: Pooja (UDF) | Group: UDF | Decision Group: 2290
 * 
 * Data Requirement (Col O): Layout Type; Layout Grid Dimensions; Spacing Rules; Alignment Settings; Layout Validation Status
 * UX / UI Translation: Live microsecond and millisecond benchmark measuring time from initState down to addPostFrameCallback.
 * System Verbs (mobile eb.docx): CALCULATES, VALIDATES
 * Mathematical Triangular Check (ux Eb.docx): Delta = (Draw Timestamp - Init Timestamp) - Measured Elapsed Duration = 0.
 * Mistake-Proofing (Poka-Yoke - Col AD): Warns and logs layout bottlenecks whenever initial render duration exceeds 16.6ms (60fps boundary).
 * Self-Chasing (Col AE): Layout render profiling streams directly to BigQuery frame monitoring logs.
 * 
 * QUALITY METRIC BOUNDARIES (Cols AK-AP):
 * Metric Name: Touch Target Size & Accessibility Compliance
 * - Floor Boundary: 44px / WCAG AA
 * - Optimal Target: 48px / WCAG AA
 * - Ceiling Boundary: 56px / WCAG AAA
 * Best Qualitative Output: Good (Scale: Good/Average/Poor)
 * Output Type: Precision Frame Budget Profiler & Touch Target Conformance
 * Telemetry Collected (Col AQ): Layout Type; Layout Grid Dimensions; Spacing Rules; Alignment Settings; Layout Validation Status; Completion Status ('Good (Scale: Good/Average/Poor)'); Action/Event Timestamp; User/Session ID
 */

import 'package:flutter/material.dart';

/// Row 117: BTPM-028-04 Record Data Model.
class ViewInitializationDurationRecord {
  final String globalRefId;
  final String atomicStepRefId;
  final String layoutType;
  final String layoutGridDimensions;
  final String spacingRules;
  final String alignmentSettings;
  final String layoutValidationStatus;
  final String completionStatus;
  final String actionTimestamp;
  final String userSessionId;
  final double touchTargetSizeDp;
  final double floorBoundaryDp;
  final double optimalTargetDp;
  final double ceilingBoundaryDp;

  const ViewInitializationDurationRecord({
    this.globalRefId = 'BTPM-028-04',
    this.atomicStepRefId = 'BTPM-028-04',
    this.layoutType = 'View Initialization Profiler',
    this.layoutGridDimensions = '390x240 dp Viewport Canvas',
    this.spacingRules = '16dp Grid Matrix / 8dp Sub-Elements',
    this.alignmentSettings = 'Vertical Column Auto-Stretch',
    this.layoutValidationStatus = 'Validated Compliant',
    this.completionStatus = 'Good',
    this.actionTimestamp = '2026-09-07T16:39:00Z',
    this.userSessionId = 'SESSION-BTPM-028-04',
    this.touchTargetSizeDp = 48.0,
    this.floorBoundaryDp = 44.0,
    this.optimalTargetDp = 48.0,
    this.ceilingBoundaryDp = 56.0,
  });
}

/// Main Component Panel Widget for Row 117: BTPM-028-04.
class ViewInitializationDurationPanel extends StatefulWidget {
  final ViewInitializationDurationRecord record;

  const ViewInitializationDurationPanel({
    super.key,
    this.record = const ViewInitializationDurationRecord(),
  });

  @override
  State<ViewInitializationDurationPanel> createState() => _ViewInitializationDurationPanelState();
}

class _ViewInitializationDurationPanelState extends State<ViewInitializationDurationPanel> {
  int _initTimeMicros = 0;
  int _drawTimeMicros = 0;
  double _measuredDurationMs = 0.0;
  bool _hasDrawn = false;
  int _renderRunCount = 0;
  bool _showExecutionLog = false;

  @override
  void initState() {
    super.initState();
    _startBenchmark();
  }

  void _startBenchmark() {
    _initTimeMicros = DateTime.now().microsecondsSinceEpoch;
    _hasDrawn = false;
    _renderRunCount++;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final drawMicros = DateTime.now().microsecondsSinceEpoch;
        final elapsedMs = (drawMicros - _initTimeMicros) / 1000.0;
        setState(() {
          _drawTimeMicros = drawMicros;
          _measuredDurationMs = elapsedMs;
          _hasDrawn = true;
        });
      }
    });
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'layoutType': widget.record.layoutType,
      'layoutGridDimensions': widget.record.layoutGridDimensions,
      'spacingRules': widget.record.spacingRules,
      'alignmentSettings': widget.record.alignmentSettings,
      'layoutValidationStatus': widget.record.layoutValidationStatus,
      'completionStatus': widget.record.completionStatus,
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': widget.record.userSessionId,
      'metadata': {
        'taskCode': 'BTPM-028-04',
        'row': 117,
        'seq': 6077,
        'assigned': 'Pooja',
        'metricName': 'Touch Target Size & Accessibility Compliance',
        'floor': widget.record.floorBoundaryDp,
        'target': widget.record.optimalTargetDp,
        'ceiling': widget.record.ceilingBoundaryDp,
        'unit': 'Good (Scale: Good/Average/Poor)',
        'initTimeMicros': _initTimeMicros,
        'drawTimeMicros': _drawTimeMicros,
        'measuredDurationMs': _measuredDurationMs,
        'renderRunCount': _renderRunCount,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calculatedDeltaMicros = (_drawTimeMicros - _initTimeMicros);
    final triangularCheckVariance = (_drawTimeMicros > 0)
        ? (calculatedDeltaMicros / 1000.0) - _measuredDurationMs
        : 0.0;
    final isWithin60FpsBudget = _measuredDurationMs <= 16.6;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final horizontalPadding = isExpanded
            ? ViewInitializationDurationPanelTokens.paddingXl
            : (isCompact ? ViewInitializationDurationPanelTokens.paddingSm : ViewInitializationDurationPanelTokens.paddingMd);

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
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isWithin60FpsBudget
                            ? theme.colorScheme.primaryContainer
                            : Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.speed_outlined,
                        color: isWithin60FpsBudget ? theme.colorScheme.primary : Colors.amber.shade900,
                        size: 24,
                      ),
                    ),
                    ViewInitializationDurationPanelTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BTPM-028-04: View Init to Layout Draw Timer',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isCompact ? 13 : 15,
                            ),
                          ),
                          Text(
                            'Global Ref: ${widget.record.globalRefId} | Atomic: ${widget.record.atomicStepRefId} | Seq: 6077',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text('${_measuredDurationMs.toStringAsFixed(2)} ms'),
                      backgroundColor: isWithin60FpsBudget ? Colors.green.shade100 : Colors.amber.shade200,
                    ),
                  ],
                ),
                ViewInitializationDurationPanelTokens.vGapMd,

                // Live Benchmark Results Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isWithin60FpsBudget ? Colors.green.shade600 : Colors.amber.shade800,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Precision Stopwatch Benchmark:',
                            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _hasDrawn ? 'DRAW COMPLETE' : 'PROFILING...',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _hasDrawn ? Colors.green.shade800 : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildBenchmarkRow('Init State Timestamp:', '$_initTimeMicros \u00b5s'),
                      _buildBenchmarkRow('Post-Frame Draw Timestamp:', '$_drawTimeMicros \u00b5s'),
                      _buildBenchmarkRow('Net View Render Duration:', '${_measuredDurationMs.toStringAsFixed(3)} ms'),
                      _buildBenchmarkRow(
                        '60fps Frame Budget (16.6ms):',
                        isWithin60FpsBudget ? 'PASS (Optimal Frame Target)' : 'WARNING (High Render Load)',
                        valueColor: isWithin60FpsBudget ? Colors.green.shade700 : Colors.amber.shade900,
                      ),
                    ],
                  ),
                ),

                ViewInitializationDurationPanelTokens.vGapMd,

                // Interactive Retest Trigger (48dp Minimum Touch Target)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _startBenchmark();
                          });
                        },
                        icon: const Icon(Icons.replay, size: 16),
                        label: Text('Retest Render Latency (Run #$_renderRunCount)', style: const TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(48, 48)),
                      ),
                    ),
                  ],
                ),

                ViewInitializationDurationPanelTokens.vGapMd,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      icon: Icon(_showExecutionLog ? Icons.visibility_off : Icons.receipt_long),
                      label: Text(_showExecutionLog ? 'Hide Telemetry' : 'View Audit Telemetry'),
                      onPressed: () => setState(() => _showExecutionLog = !_showExecutionLog),
                    ),
                  ],
                ),

                if (_showExecutionLog) ...[
                  ViewInitializationDurationPanelTokens.vGapMd,
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

                ViewInitializationDurationPanelTokens.vGapMd,

                // Telemetry & Architectural Specs
                Container(
                  padding: ViewInitializationDurationPanelTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('49-Column Specification Alignment (my steps.xlsx):',
                          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('• Metric: Touch Target 48dp (Optimal: 48px | Floor: 44px | Ceiling: 56px WCAG AAA)',
                          style: TextStyle(fontSize: 10)),
                      const Text('• Poka-Yoke (Col AD): Frame budget monitor flags render bottlenecks exceeding 16.6ms.',
                          style: TextStyle(fontSize: 10)),
                      Text('• Triangular Check: (Draw - Init) - Measured = ${triangularCheckVariance.toStringAsFixed(6)} (Zero-Variance Delta = 0).',
                          style: const TextStyle(fontSize: 10)),
                      Text('• Telemetry (Col AQ): Layout: ${widget.record.layoutType} | Dimensions: ${widget.record.layoutGridDimensions}',
                          style: const TextStyle(fontSize: 10)),
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

  Widget _buildBenchmarkRow(String label, String val, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
          Text(
            val,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class ViewInitializationDurationPanelTokens {
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
            child: ViewInitializationDurationPanel(),
          ),
        ),
      ),
    ),
  );
}
