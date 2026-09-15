/*
 * CSIVW-014-A13 — Three-Strike Policy Evaluator Panel
 * 
 * Setup Step (Action): Evaluate if the tracking variable meets a strict 3-strike policy limit.
 * Metric Name: Content Moderation (NLP) Accuracy (Floor: 85%, Target: 95%+, Ceiling: 100%)
 * Quality Standard: Real-time NLP filters minimize false positives while catching aggressive language.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

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
            ? AppSpacingTokens.paddingSm
            : (isExpanded ? AppSpacingTokens.paddingLg : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _isLockoutTriggered
                  ? AppColorPalette.lightError
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
                        color: (_isLockoutTriggered ? AppColorPalette.lightError : AppColorPalette.brandPrimary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isLockoutTriggered ? Icons.gavel_rounded : Icons.shield_outlined,
                        color: _isLockoutTriggered ? AppColorPalette.lightError : AppColorPalette.brandPrimary,
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
                        color: _isLockoutTriggered ? AppColorPalette.errorContainer : AppColorPalette.successContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isLockoutTriggered ? 'Lockout Active' : 'Pass ($_strikeCount/3)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isLockoutTriggered ? AppColorPalette.onErrorContainer : AppColorPalette.onSuccessContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                // 3-Strike Visual Indicator Matrix
                Text(
                  'Violation Strike Monitor (Hard Stop at 3 Strikes):',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacingTokens.vGapSm,
                Row(
                  children: List.generate(3, (idx) {
                    final isFilled = idx < _strikeCount;
                    return Expanded(
                      child: Container(
                        height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isFilled ? AppColorPalette.lightError : colorScheme.surfaceContainerHighest,
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
                AppSpacingTokens.vGapMd,

                // Policy Explanation Callout
                Container(
                  padding: AppSpacingTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.rule_rounded, size: 18, color: AppColorPalette.brandPrimary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          _isLockoutTriggered
                              ? 'STRICT LOCKOUT TRIGGERED: 3 strikes registered. Free text input physically prohibited.'
                              : 'Current Status: $_strikeCount of 3 strikes recorded. 3rd violation locks workflow.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _isLockoutTriggered ? AppColorPalette.lightError : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacingTokens.vGapMd,

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
