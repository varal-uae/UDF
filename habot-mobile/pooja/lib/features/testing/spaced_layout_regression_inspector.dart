import 'package:flutter/material.dart';

/// Unique design tokens for Spaced Layout Visual Regression Inspector.
abstract final class SpacedRegressionTokens {
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Accent & status
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color passGreen = Color(0xFF16A34A);
  static const Color passGreenBg = Color(0xFFDCFCE7);
  static const Color diffOverlay = Color(0x33EF4444);
}

/// Representation of a layout spacing audit rule.
class SpacingRule {
  final String tokenName;
  final double expectedDp;
  final double measuredDp;
  final bool isCompliant;

  const SpacingRule({
    required this.tokenName,
    required this.expectedDp,
    required this.measuredDp,
    required this.isCompliant,
  });
}

/// Visual regression testing console for spaced mobile layouts.
class SpacedLayoutRegressionInspector extends StatefulWidget {
  final void Function(double pixelDeltaRatio)? onRegressionCompleted;

  const SpacedLayoutRegressionInspector({
    super.key,
    this.onRegressionCompleted,
  });

  @override
  State<SpacedLayoutRegressionInspector> createState() =>
      _SpacedLayoutRegressionInspectorState();
}

class _SpacedLayoutRegressionInspectorState extends State<SpacedLayoutRegressionInspector> {
  int _selectedViewportIndex = 0; // 0: Compact (360dp), 1: Standard (412dp), 2: Expanded (600dp)
  double _sliderDiffPosition = 0.5;
  bool _showDeltaHeatmap = false;
  double _similarityScore = 99.8;

  final List<SpacingRule> _rules = const [
    SpacingRule(tokenName: 'spacing.screen.horizontal_padding', expectedDp: 16.0, measuredDp: 16.0, isCompliant: true),
    SpacingRule(tokenName: 'spacing.card.inner_gap', expectedDp: 12.0, measuredDp: 12.0, isCompliant: true),
    SpacingRule(tokenName: 'spacing.list.item_gutter', expectedDp: 8.0, measuredDp: 8.0, isCompliant: true),
    SpacingRule(tokenName: 'spacing.touch.min_boundary', expectedDp: 48.0, measuredDp: 48.0, isCompliant: true),
  ];

  void _runVisualDiff() {
    setState(() {
      _similarityScore = 99.9;
      _showDeltaHeatmap = true;
    });
    widget.onRegressionCompleted?.call(0.001);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: SpacedRegressionTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: SpacedRegressionTokens.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SpacedRegressionTokens.primaryBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.compare_rounded,
                  color: SpacedRegressionTokens.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spaced Layout Regression',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SpacedRegressionTokens.textDark,
                      ),
                    ),
                    Text(
                      'ISO/IEC 27001 Visual Diff & Spacing Token Audit',
                      style: TextStyle(
                        fontSize: 12,
                        color: SpacedRegressionTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SpacedRegressionTokens.passGreenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_similarityScore.toStringAsFixed(1)}% MATCH',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SpacedRegressionTokens.passGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Viewport Selector
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Compact (360)')),
              ButtonSegment(value: 1, label: Text('Standard (412)')),
              ButtonSegment(value: 2, label: Text('Expanded (600)')),
            ],
            selected: {_selectedViewportIndex},
            onSelectionChanged: (set) {
              setState(() => _selectedViewportIndex = set.first);
            },
          ),
          const SizedBox(height: 14),
          // Visual Diff Comparator Stage
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SpacedRegressionTokens.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SpacedRegressionTokens.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Golden Baseline vs Current Spacing Render',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: SpacedRegressionTokens.textDark,
                      ),
                    ),
                    Text(
                      _showDeltaHeatmap ? 'Heatmap: 0.01% Drift' : 'Pixel Match: Identical',
                      style: const TextStyle(
                        fontSize: 11,
                        color: SpacedRegressionTokens.passGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Simulated Mock Layout Preview
                Stack(
                  children: [
                    Container(
                      height: 90,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SpacedRegressionTokens.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: SpacedRegressionTokens.primaryBlue.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.dashboard_customize_outlined,
                              color: SpacedRegressionTokens.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 140,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCBD5E1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 90,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: SpacedRegressionTokens.passGreenBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: SpacedRegressionTokens.passGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showDeltaHeatmap)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: SpacedRegressionTokens.diffOverlay.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent.withAlpha(60)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Diff Split:', style: TextStyle(fontSize: 11, color: SpacedRegressionTokens.textMuted)),
                    Expanded(
                      child: Slider(
                        value: _sliderDiffPosition,
                        onChanged: (v) => setState(() => _sliderDiffPosition = v),
                      ),
                    ),
                    Text('${(_sliderDiffPosition * 100).toInt()}%',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Spacing Rules Table
          Column(
            children: _rules.map((rule) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: SpacedRegressionTokens.passGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule.tokenName,
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: SpacedRegressionTokens.textDark),
                      ),
                    ),
                    Text(
                      '${rule.expectedDp.toInt()}dp / ${rule.measuredDp.toInt()}dp',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SpacedRegressionTokens.passGreen),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Trigger Execution Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _runVisualDiff,
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('Execute Visual Regression Suite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SpacedRegressionTokens.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: SpacedLayoutRegressionInspector(),
          ),
        ),
      ),
    ),
  );
}
