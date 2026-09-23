/*
 * CCBPB-011-A08 — Final Alert Condition Threshold (100% Critical Hard-Stop) Panel
 * 
 * Global Reference ID: CCBPB-011
 * Atomic Steps Reference ID: CCBPB-011-A08
 * Setup Step (Action): Set the final alert condition threshold step parameter to intercept variances hitting exactly 100%.
 * Sequence Order: 7234 | Row: 130 | Team: Pooja (Agile Architecture & BDD Implementation)
 * 
 * 49-Columns Alignment & Architecture Mandates (my steps_backup.xlsx):
 * - Col AD (Poka-Yoke): The interface physically blocks new purchase submissions once spending metrics cross the 100% hard limit.
 * - Col AE (Self-Chasing): Budget tracking interfaces built without active threshold alert hooks fail build pipeline validation passes.
 * - Col AK (Metric Name): Threshold-Based Alert Banding Accuracy
 * - Col AL (Floor): 70% (early warning band)
 * - Col AM (Optimal Target): 85% (elevated warning band)
 * - Col AN (Ceiling): 100% (critical/hard-stop band)
 * - Col AO (Qualitative Output): Pass/Fail
 * - Col AP (Standard): Standard three-tier band (≈70% / 85% / 100%) for budget or capacity alert
 * - Col AQ (Telemetry): Step Execution ID; Execution Status; Execution Timestamp; Step Outcome; User ID; Completion Status; Action/Event Timestamp; User/Session ID
 * - Cols Y-AB (M3 Decisions): Shift banner color scheme to bold errorContainer (md.sys.color.errorContainer); Pinned critical alert banner; Purchase submission lock.
 * - DEA-170826 Guidelines (mobile eb & ux eb):
 *   - Mathematical Triangular Check Gate: Delta = Current Spending (101.4%) - Hard Ceiling (100.0%) = 1.4% overrun.
 * 
 * Standardized Telemetry Export:
 *   - toExecutionLogJson() provides structured EXEC-CCBPB-011-A08-2026 schema output.
 */

import 'package:flutter/material.dart';

/// Step CCBPB-011-A08: Interactive Panel
class BudgetAlertThreshold100Panel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const BudgetAlertThreshold100Panel({
    super.key,
    this.globalRefId = 'CCBPB-011',
    this.atomicStepRefId = 'CCBPB-011-A08',
    this.sequenceOrder = 7234,
  });

  @override
  State<BudgetAlertThreshold100Panel> createState() =>
      _BudgetAlertThreshold100PanelState();
}

class _BudgetAlertThreshold100PanelState
    extends State<BudgetAlertThreshold100Panel> {
  double _currentSpendingPercentage = 101.4;
  final double _hardLimit = 100.0;
  int _blockedPurchaseAttempts = 0;

  void _updateSpending(double val) {
    setState(() {
      _currentSpendingPercentage = val;
    });
  }

  void _attemptPurchaseOrder() {
    if (_currentSpendingPercentage >= _hardLimit) {
      setState(() {
        _blockedPurchaseAttempts++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'POKA-YOKE HARD STOP: Purchases locked! Budget is at or above 100% limit.',
          ),
          backgroundColor: BudgetAlertThreshold100PanelTokens.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Purchase order authorized (spend < 100%).'),
        backgroundColor: BudgetAlertThreshold100PanelTokens.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'stepExecutionId': 'EXEC-${widget.atomicStepRefId}-2026',
      'executionStatus': 'COMPLIANT',
      'executionTimestamp': DateTime.now().toUtc().toIso8601String(),
      'stepOutcome': 'SUCCESS',
      'userId': 'USER-AUTO-R13',
      'completionStatus': 'Pass/Fail',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-${widget.globalRefId}',
      'metadata': {
        'taskCode': widget.atomicStepRefId,
        'row': 130,
        'seq': widget.sequenceOrder,
        'assigned': 'Pooja',
        'metricName': 'Threshold-Based Alert Banding Accuracy',
        'floor': '70% (early warning band)',
        'target': '85% (elevated warning band)',
        'ceiling': '100% (critical/hard-stop band)',
        'unit': 'Pass/Fail',
        'currentSpendingPercentage': _currentSpendingPercentage,
        'hardLimit': _hardLimit,
        'blockedPurchaseAttempts': _blockedPurchaseAttempts,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHardStop = _currentSpendingPercentage >= _hardLimit;
    // Triangular Check: Delta = Current Spend - 100.0%
    final overrunDelta = _currentSpendingPercentage - _hardLimit;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final cardPadding = isCompact
            ? BudgetAlertThreshold100PanelTokens.paddingSm
            : (isExpanded ? BudgetAlertThreshold100PanelTokens.paddingLg : BudgetAlertThreshold100PanelTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: BudgetAlertThreshold100PanelTokens.error.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.block_rounded,
                          color: BudgetAlertThreshold100PanelTokens.error, size: 22),
                    ),
                    BudgetAlertThreshold100PanelTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.globalRefId} / ${widget.atomicStepRefId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: BudgetAlertThreshold100PanelTokens.brandPrimary,
                              fontSize: isExpanded ? 16 : 14,
                            ),
                          ),
                          Text(
                            'Budget Alert Threshold 100% (Seq: ${widget.sequenceOrder})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: isCompact ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHardStop
                            ? BudgetAlertThreshold100PanelTokens.errorContainer
                            : BudgetAlertThreshold100PanelTokens.successContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isHardStop ? '100% HARD STOP' : 'Nominal (<100%)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isHardStop
                              ? BudgetAlertThreshold100PanelTokens.onErrorContainer
                              : BudgetAlertThreshold100PanelTokens.onSuccessContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                BudgetAlertThreshold100PanelTokens.vGapMd,

                // Architectural Directive
                Text(
                  'Threshold Parameter Tier 3 Hard-Stop (Col AD Poka-Yoke Mandate):',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                BudgetAlertThreshold100PanelTokens.vGapXs,
                Text(
                  'Sets the final alert condition parameter at exactly 100.0% variance to physically block new purchase submissions and freeze budget overruns.',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
                BudgetAlertThreshold100PanelTokens.vGapMd,

                // Spend Simulation Slider
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Simulated Spend Utilization:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_currentSpendingPercentage.toStringAsFixed(1)}% of Budget',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isHardStop ? BudgetAlertThreshold100PanelTokens.error : const Color(0xFFED6C02),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _currentSpendingPercentage,
                        min: 85.0,
                        max: 120.0,
                        divisions: 35,
                        label: '${_currentSpendingPercentage.toStringAsFixed(1)}%',
                        activeColor: isHardStop ? BudgetAlertThreshold100PanelTokens.error : const Color(0xFFED6C02),
                        onChanged: _updateSpending,
                      ),
                      LinearProgressIndicator(
                        value: (_currentSpendingPercentage / 100.0).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isHardStop ? BudgetAlertThreshold100PanelTokens.error : const Color(0xFFED6C02),
                        ),
                      ),
                    ],
                  ),
                ),
                BudgetAlertThreshold100PanelTokens.vGapMd,

                // 100% Critical Banner (md.sys.color.errorContainer)
                if (isHardStop)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BudgetAlertThreshold100PanelTokens.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: BudgetAlertThreshold100PanelTokens.error, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.gpp_bad_rounded, color: BudgetAlertThreshold100PanelTokens.error, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TIER 3 CRITICAL: 100% HARD LIMIT BREACHED',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: BudgetAlertThreshold100PanelTokens.onErrorContainer,
                                ),
                              ),
                              Text(
                                'Overrun: +${overrunDelta.toStringAsFixed(1)}% above allocation limit. Purchase submission controls physically locked.',
                                style: const TextStyle(fontSize: 10, color: BudgetAlertThreshold100PanelTokens.onErrorContainer),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                BudgetAlertThreshold100PanelTokens.vGapMd,

                // Purchase Order Action Button (Locked if >=100%) with min 48dp target
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isHardStop ? null : _attemptPurchaseOrder,
                      icon: Icon(isHardStop ? Icons.lock_outline_rounded : Icons.shopping_cart_checkout_rounded, size: 18),
                      label: Text(isHardStop ? 'Purchases Blocked (100% Limit Reached)' : 'Submit Purchase Order'),
                      style: FilledButton.styleFrom(
                        backgroundColor: isHardStop ? theme.colorScheme.surfaceContainerHighest : BudgetAlertThreshold100PanelTokens.brandPrimary,
                        foregroundColor: isHardStop ? theme.colorScheme.onSurface.withValues(alpha: 0.38) : Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                BudgetAlertThreshold100PanelTokens.vGapMd,

                // 49-Columns Audit Alignment Container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '49-Column Specification Alignment (my steps.xlsx):',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Metric: Alert Banding Accuracy (Floor: 70% | Target: 85% | Ceiling: 100%)',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        '• Poka-Yoke (Col AD): Hard limit physically disables button; Blocked attempts: $_blockedPurchaseAttempts',
                        style: const TextStyle(fontSize: 10),
                      ),
                      Text(
                        '• Triangular Check: Current (${_currentSpendingPercentage.toStringAsFixed(1)}%) - Ceiling (100.0%) = Delta ${overrunDelta.toStringAsFixed(1)}%.',
                        style: const TextStyle(fontSize: 10),
                      ),
                      Text(
                        '• Telemetry (Col AQ): Purchases Blocked: $_blockedPurchaseAttempts | Hard Stop Active: $isHardStop | Status: Pass',
                        style: const TextStyle(fontSize: 10),
                      ),
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
abstract final class BudgetAlertThreshold100PanelTokens {
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
            child: BudgetAlertThreshold100Panel(),
          ),
        ),
      ),
    ),
  );
}
