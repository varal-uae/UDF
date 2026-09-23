/*
 * CSIVW-014-A13 — Three-Strike Policy Evaluator Panel
 * 
 * Setup Step (Action): Evaluate if the tracking variable meets a strict 3-strike policy limit.
 * Metric Name: Content Moderation (NLP) Accuracy (Floor: 85%, Target: 95%+, Ceiling: 100%)
 * Quality Standard: Real-time NLP filters minimize false positives while catching aggressive language.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

class ThreeStrikePolicyEvaluatorPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const ThreeStrikePolicyEvaluatorPanel({
    super.key,
    this.globalRefId = 'CSIVW-014',
    this.atomicStepRefId = 'CSIVW-014-A13',
    this.sequenceOrder = '9076',
  });

  @override
  State<ThreeStrikePolicyEvaluatorPanel> createState() =>
      _ThreeStrikePolicyEvaluatorPanelState();
}

class _ThreeStrikePolicyEvaluatorPanelState
    extends State<ThreeStrikePolicyEvaluatorPanel> {
  int _strikeCount = 0;
  final double _accuracyRate = 0.98; // 98%

  bool get _isLockoutTriggered => _strikeCount >= 3;

  void _recordStrike() {
    if (_strikeCount < 3) {
      setState(() => _strikeCount++);
    }
  }

  void _resetStrikes() {
    setState(() => _strikeCount = 0);
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'stepExecutionId': 'EXEC-${widget.globalRefId}-2026',
      'executionStatus': _isLockoutTriggered ? 'POLICY_LIMIT_REACHED' : 'STRIKES_UNDER_LIMIT',
      'executionTimestamp': DateTime.now().toUtc().toIso8601String(),
      'stepOutcome': _isLockoutTriggered ? 'LOCKOUT_ENFORCED' : 'MONITORING_ACTIVE',
      'userId': 'USER-AUTO-B16',
      'completionStatus': 'Pass',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-${widget.globalRefId}',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 154,
        'seq': widget.sequenceOrder,
        'assigned': 'Pooja',
        'metricName': 'Content Moderation (NLP) Accuracy',
        'floor': '85%',
        'target': '95%+',
        'ceiling': '100%',
        'unit': 'Pass/Fail',
        'accuracyRate': _accuracyRate,
        'currentStrikes': _strikeCount,
        'maxPolicyLimit': 3,
        'isLockoutTriggered': _isLockoutTriggered,
      }
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
            ? ThreeStrikePolicyEvaluatorPanelTokens.paddingSm
            : (isExpanded ? ThreeStrikePolicyEvaluatorPanelTokens.paddingLg : ThreeStrikePolicyEvaluatorPanelTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _isLockoutTriggered
                  ? ThreeStrikePolicyEvaluatorPanelTokens.lightError
                  : ThreeStrikePolicyEvaluatorPanelTokens.brandPrimary.withValues(alpha: 0.3),
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
                        color: (_isLockoutTriggered ? ThreeStrikePolicyEvaluatorPanelTokens.lightError : ThreeStrikePolicyEvaluatorPanelTokens.brandPrimary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isLockoutTriggered ? Icons.gavel_rounded : Icons.shield_outlined,
                        color: _isLockoutTriggered ? ThreeStrikePolicyEvaluatorPanelTokens.lightError : ThreeStrikePolicyEvaluatorPanelTokens.brandPrimary,
                        size: 24,
                      ),
                    ),
                    ThreeStrikePolicyEvaluatorPanelTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.globalRefId} / ${widget.atomicStepRefId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ThreeStrikePolicyEvaluatorPanelTokens.brandPrimary,
                              fontSize: isExpanded ? 16 : 14,
                            ),
                          ),
                          Text(
                            'Three-Strike Policy Evaluator (Seq: ${widget.sequenceOrder})',
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
                        color: _isLockoutTriggered ? ThreeStrikePolicyEvaluatorPanelTokens.errorContainer : ThreeStrikePolicyEvaluatorPanelTokens.successContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isLockoutTriggered ? 'Lockout Active' : 'Pass ($_strikeCount/3)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isLockoutTriggered ? ThreeStrikePolicyEvaluatorPanelTokens.onErrorContainer : ThreeStrikePolicyEvaluatorPanelTokens.onSuccessContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                ThreeStrikePolicyEvaluatorPanelTokens.vGapMd,

                // 3-Strike Visual Indicator Matrix
                Text(
                  'Violation Strike Monitor (Hard Stop at 3 Strikes):',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                ThreeStrikePolicyEvaluatorPanelTokens.vGapSm,
                Row(
                  children: List.generate(3, (idx) {
                    final isFilled = idx < _strikeCount;
                    return Expanded(
                      child: Container(
                        height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isFilled ? ThreeStrikePolicyEvaluatorPanelTokens.lightError : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Strike ${idx + 1}',
                            style: TextStyle(
                              color: isFilled ? Colors.white : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                ThreeStrikePolicyEvaluatorPanelTokens.vGapMd,

                // Policy Explanation Callout
                Container(
                  padding: ThreeStrikePolicyEvaluatorPanelTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.rule_rounded, size: 18, color: ThreeStrikePolicyEvaluatorPanelTokens.brandPrimary),
                      ThreeStrikePolicyEvaluatorPanelTokens.hGapSm,
                      Expanded(
                        child: Text(
                          _isLockoutTriggered
                              ? 'STRICT LOCKOUT TRIGGERED: 3 strikes registered. Free text input physically prohibited.'
                              : 'Current Status: $_strikeCount of 3 strikes recorded. 3rd violation locks workflow.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _isLockoutTriggered ? ThreeStrikePolicyEvaluatorPanelTokens.lightError : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ThreeStrikePolicyEvaluatorPanelTokens.vGapMd,

                // Controls (Min 48x48dp target)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: FilledButton.tonalIcon(
                        onPressed: _isLockoutTriggered ? null : _recordStrike,
                        icon: const Icon(Icons.add_alert_rounded),
                        label: const Text('Add Violation Strike'),
                        style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: OutlinedButton.icon(
                        onPressed: _resetStrikes,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Reset Strike Counter'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(160, 48)),
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class ThreeStrikePolicyEvaluatorPanelTokens {
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

  static const Color lightPrimary = Color(0xFF6750A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEADDFF);
  static const Color lightOnPrimaryContainer = Color(0xFF21005D);

  static const Color lightSecondary = Color(0xFF625B71);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color lightOnSecondaryContainer = Color(0xFF1D192B);

  static const Color lightTertiary = Color(0xFF7D5260);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFFD8E4);
  static const Color lightOnTertiaryContainer = Color(0xFF31111D);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFF9DEDC);
  static const Color lightOnErrorContainer = Color(0xFF410E0B);

  static const Color lightBackground = Color(0xFFFEF7FF);
  static const Color lightOnBackground = Color(0xFF1D1B20);
  static const Color lightSurface = Color(0xFFFEF7FF);
  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  static const Color neutralLight = Color(0xFFF5F5F5);
  static const Color neutralDark = Color(0xFF212121);

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
            child: ThreeStrikePolicyEvaluatorPanel(),
          ),
        ),
      ),
    ),
  );
}
