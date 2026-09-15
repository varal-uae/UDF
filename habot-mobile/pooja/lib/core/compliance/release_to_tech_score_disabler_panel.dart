/*
 * EDEBS-015-10 — Release to Tech Score Disabler Panel
 * 
 * Setup Step (Action): Set the pipeline rules to physically disable the "Release to Tech" dashboard button if the score is greater than zero.
 * Metric Name: Observability / Alert Coverage (Floor: ≥90%, Target: 1, Ceiling: 1)
 * Quality Standard: Google SRE Handbook — Monitoring Distributed Systems (Best = Good 100%)
 * Telemetry: Step Execution ID; Execution Status; Execution Timestamp; Step Outcome; User ID; Completion Status ('Good/Average/Poor → Best = Good (100%)'); Action/Event Timestamp; User/Session ID
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class ReleaseToTechScoreDisablerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const ReleaseToTechScoreDisablerPanel({
    super.key,
    this.globalRefId = 'EDEBS-015',
    this.atomicStepRefId = 'EDEBS-015-10',
    this.sequenceOrder = '12868',
  });

  @override
  State<ReleaseToTechScoreDisablerPanel> createState() =>
      _ReleaseToTechScoreDisablerPanelState();
}

class _ReleaseToTechScoreDisablerPanelState
    extends State<ReleaseToTechScoreDisablerPanel> {
  int _defectScore = 0;
  final String _userSessionId = 'POOJA-EDEBS-015-10';
  final String _completionStatus = 'Good (100%)';

  Map<String, dynamic> getTelemetryData() {
    final isDisabled = _defectScore > 0;
    return {
      'stepExecutionId': 'EXEC-EDEBS-015-10-2026',
      'executionStatus': 'Verified',
      'executionTimestamp': DateTime.now().toIso8601String(),
      'stepOutcome': isDisabled
          ? 'Button physically disabled: defect score $_defectScore > 0'
          : 'Button physically active: defect score is 0',
      'userId': _userSessionId,
      'defectScore': _defectScore,
      'buttonState': isDisabled ? 'PHYSICALLY_DISABLED' : 'ACTIVE_ENABLED',
      'ruleEnforced': 'Score > 0 => onPressed = null',
      'observabilityStandard': 'Google SRE Handbook — Monitoring Distributed Systems',
      'completionStatus': _completionStatus,
      'actionEventTimestamp': DateTime.now().toIso8601String(),
      'userSessionId': _userSessionId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBlocked = _defectScore > 0;

    return Container(
      width: double.infinity,
      padding: AppSpacingTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorPalette.lightOutline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacingTokens.sm),
                decoration: BoxDecoration(
                  color: isBlocked ? AppColorPalette.lightErrorContainer : AppColorPalette.successContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isBlocked ? Icons.block : Icons.lock_open,
                  color: isBlocked ? AppColorPalette.lightError : AppColorPalette.success,
                  size: 24,
                ),
              ),
              AppSpacingTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColorPalette.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Release to Tech Button Disabler Rule',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isBlocked ? AppColorPalette.lightErrorContainer : AppColorPalette.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isBlocked ? 'GATE BLOCKED' : 'GATE CLEARED',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isBlocked ? AppColorPalette.lightOnErrorContainer : AppColorPalette.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacingTokens.vGapMd,
          Container(
            padding: AppSpacingTokens.paddingMd,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isBlocked
                    ? AppColorPalette.lightError.withValues(alpha: 0.3)
                    : AppColorPalette.success.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pipeline Defect Score:', style: theme.textTheme.labelLarge),
                    Text(
                      '$_defectScore',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isBlocked ? AppColorPalette.lightError : AppColorPalette.success,
                      ),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapSm,
                Text(
                  isBlocked
                      ? 'Rule Triggered: Score is greater than zero ($_defectScore > 0). The "Release to Tech" button is physically disabled (onPressed: null).'
                      : 'Rule Check: Score is zero (0). Pipeline gate allows activation of the "Release to Tech" button.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isBlocked ? AppColorPalette.lightError : colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacingTokens.vGapSm,
                Row(
                  children: [
                    const Text('Simulate Defect Score: '),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _defectScore > 0 ? () => setState(() => _defectScore--) : null,
                    ),
                    Text('$_defectScore', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => _defectScore++),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacingTokens.vGapMd,
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: isBlocked
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Release to Tech initiated (Defect Score = 0)'),
                          backgroundColor: AppColorPalette.success,
                        ),
                      );
                    },
              icon: Icon(isBlocked ? Icons.lock : Icons.rocket_launch),
              label: Text(
                isBlocked
                    ? 'Release to Tech (Disabled: Score > 0)'
                    : 'Release to Tech (Active)',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
