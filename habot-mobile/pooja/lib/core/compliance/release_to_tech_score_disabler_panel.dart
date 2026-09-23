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
      padding: ReleaseToTechScoreDisablerPanelTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ReleaseToTechScoreDisablerPanelTokens.lightOutline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ReleaseToTechScoreDisablerPanelTokens.sm),
                decoration: BoxDecoration(
                  color: isBlocked ? ReleaseToTechScoreDisablerPanelTokens.lightErrorContainer : ReleaseToTechScoreDisablerPanelTokens.successContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isBlocked ? Icons.block : Icons.lock_open,
                  color: isBlocked ? ReleaseToTechScoreDisablerPanelTokens.lightError : ReleaseToTechScoreDisablerPanelTokens.success,
                  size: 24,
                ),
              ),
              ReleaseToTechScoreDisablerPanelTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ReleaseToTechScoreDisablerPanelTokens.brandPrimary,
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
                  color: isBlocked ? ReleaseToTechScoreDisablerPanelTokens.lightErrorContainer : ReleaseToTechScoreDisablerPanelTokens.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isBlocked ? 'GATE BLOCKED' : 'GATE CLEARED',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isBlocked ? ReleaseToTechScoreDisablerPanelTokens.lightOnErrorContainer : ReleaseToTechScoreDisablerPanelTokens.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ReleaseToTechScoreDisablerPanelTokens.vGapMd,
          Container(
            padding: ReleaseToTechScoreDisablerPanelTokens.paddingMd,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isBlocked
                    ? ReleaseToTechScoreDisablerPanelTokens.lightError.withValues(alpha: 0.3)
                    : ReleaseToTechScoreDisablerPanelTokens.success.withValues(alpha: 0.3),
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
                        color: isBlocked ? ReleaseToTechScoreDisablerPanelTokens.lightError : ReleaseToTechScoreDisablerPanelTokens.success,
                      ),
                    ),
                  ],
                ),
                ReleaseToTechScoreDisablerPanelTokens.vGapSm,
                Text(
                  isBlocked
                      ? 'Rule Triggered: Score is greater than zero ($_defectScore > 0). The "Release to Tech" button is physically disabled (onPressed: null).'
                      : 'Rule Check: Score is zero (0). Pipeline gate allows activation of the "Release to Tech" button.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isBlocked ? ReleaseToTechScoreDisablerPanelTokens.lightError : colorScheme.onSurfaceVariant,
                  ),
                ),
                ReleaseToTechScoreDisablerPanelTokens.vGapSm,
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
          ReleaseToTechScoreDisablerPanelTokens.vGapMd,
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
                          backgroundColor: ReleaseToTechScoreDisablerPanelTokens.success,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class ReleaseToTechScoreDisablerPanelTokens {
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
            child: ReleaseToTechScoreDisablerPanel(),
          ),
        ),
      ),
    ),
  );
}
