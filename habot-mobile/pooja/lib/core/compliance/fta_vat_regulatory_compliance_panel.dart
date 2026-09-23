/*
 * CUITC-039 — UAE FTA VAT Regulatory Compliance & Payroll Gate
 * 
 * Setup Step (Action): Review FTA VAT regulatory parameters and requirements.
 * Metric Name: Regulatory Compliance Defect Resolution / Correction Rate (%) (Floor: 0.9, Target: 0.99, Ceiling: 1.0)
 * Quality Standard: Six Sigma DMAIC defect-closure benchmark; COSO Internal Control / ISO 19600 guidelines.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

class FtaVatRegulatoryCompliancePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const FtaVatRegulatoryCompliancePanel({
    super.key,
    this.globalRefId = 'CUITC-039',
    this.atomicStepRefId = 'CUITC-039',
    this.sequenceOrder = '10332',
  });

  @override
  State<FtaVatRegulatoryCompliancePanel> createState() =>
      _FtaVatRegulatoryCompliancePanelState();
}

class _FtaVatRegulatoryCompliancePanelState
    extends State<FtaVatRegulatoryCompliancePanel> {
  final String _taxRegistrationNumber = '100234567890003'; // 15-digit UAE TRN
  final double _standardVatRate = 0.05; // 5% UAE VAT
  final double _baseAmountAed = 10000.00;
  bool _complianceBreached = false;
  final double _defectResolutionRate = 0.995; // 99.5% target

  double get _calculatedVat => _baseAmountAed * _standardVatRate;
  double get _totalGrossAmount => _baseAmountAed + _calculatedVat;

  void _toggleBreachSimulation() {
    setState(() => _complianceBreached = !_complianceBreached);
  }

  void _showRecoveryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: FtaVatRegulatoryCompliancePanelTokens.brandPrimary),
            SizedBox(width: 8),
            Text('FTA VAT Compliance Recovery'),
          ],
        ),
        content: const Text(
          'Payroll bonuses are conditionally locked whenever VAT audit discrepancies exist. To resolve: submit audited tax invoice #INV-2026-904 to the regulatory clearinghouse.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'stepExecutionId': 'EXEC-${widget.globalRefId}-2026',
      'executionStatus': _complianceBreached ? 'PAYROLL_BONUS_LOCKED' : 'COMPLIANT_CLEARED',
      'executionTimestamp': DateTime.now().toUtc().toIso8601String(),
      'stepOutcome': 'ZERO_TAX_DEFECT',
      'userId': 'USER-AUTO-B16',
      'completionStatus': _complianceBreached ? 'Average' : 'Good',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-${widget.globalRefId}',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 159,
        'seq': widget.sequenceOrder,
        'assigned': 'Pooja',
        'metricName': 'Regulatory Compliance Defect Resolution Rate',
        'floor': '0.90 (90%)',
        'target': '0.99 (99%)',
        'ceiling': '1.00 (100%)',
        'unit': 'Poor / Average / Good',
        'defectResolutionRate': _defectResolutionRate,
        'trn': _taxRegistrationNumber,
        'vatRate': '${(_standardVatRate * 100).toInt()}%',
        'complianceBreached': _complianceBreached,
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
            ? FtaVatRegulatoryCompliancePanelTokens.paddingSm
            : (isExpanded ? FtaVatRegulatoryCompliancePanelTokens.paddingLg : FtaVatRegulatoryCompliancePanelTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _complianceBreached
                  ? FtaVatRegulatoryCompliancePanelTokens.lightError
                  : FtaVatRegulatoryCompliancePanelTokens.brandPrimary.withValues(alpha: 0.3),
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
                        color: (_complianceBreached ? FtaVatRegulatoryCompliancePanelTokens.lightError : FtaVatRegulatoryCompliancePanelTokens.brandPrimary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _complianceBreached ? Icons.gavel_rounded : Icons.verified_rounded,
                        color: _complianceBreached ? FtaVatRegulatoryCompliancePanelTokens.lightError : FtaVatRegulatoryCompliancePanelTokens.brandPrimary,
                        size: 24,
                      ),
                    ),
                    FtaVatRegulatoryCompliancePanelTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.globalRefId} / ${widget.atomicStepRefId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: FtaVatRegulatoryCompliancePanelTokens.brandPrimary,
                              fontSize: isExpanded ? 16 : 14,
                            ),
                          ),
                          Text(
                            'FTA VAT Regulatory Review & Gate (Seq: ${widget.sequenceOrder})',
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
                        color: _complianceBreached ? FtaVatRegulatoryCompliancePanelTokens.errorContainer : FtaVatRegulatoryCompliancePanelTokens.successContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _complianceBreached ? 'Suspended' : 'Good (99.5%)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _complianceBreached ? FtaVatRegulatoryCompliancePanelTokens.onErrorContainer : FtaVatRegulatoryCompliancePanelTokens.onSuccessContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                FtaVatRegulatoryCompliancePanelTokens.vGapMd,

                // TRN & VAT Computation Card
                Container(
                  padding: FtaVatRegulatoryCompliancePanelTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Federal Tax Authority TRN', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(_taxRegistrationNumber, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Standard VAT Rate (UAE)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('${(_standardVatRate * 100).toInt()}% Statutory', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Net Base Amount', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('AED ${_baseAmountAed.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('VAT Tax Component (5%)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('AED ${_calculatedVat.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: FtaVatRegulatoryCompliancePanelTokens.brandPrimary)),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Gross Invoice Total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('AED ${_totalGrossAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                FtaVatRegulatoryCompliancePanelTokens.vGapMd,

                // Poka-Yoke Payroll Bonus Lock Gate
                Container(
                  padding: FtaVatRegulatoryCompliancePanelTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: _complianceBreached
                        ? FtaVatRegulatoryCompliancePanelTokens.errorContainer.withValues(alpha: 0.6)
                        : FtaVatRegulatoryCompliancePanelTokens.successContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _complianceBreached ? FtaVatRegulatoryCompliancePanelTokens.lightError : FtaVatRegulatoryCompliancePanelTokens.success),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _complianceBreached ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                        size: 20,
                        color: _complianceBreached ? FtaVatRegulatoryCompliancePanelTokens.lightError : FtaVatRegulatoryCompliancePanelTokens.success,
                      ),
                      FtaVatRegulatoryCompliancePanelTokens.hGapSm,
                      Expanded(
                        child: Text(
                          _complianceBreached
                              ? 'Poka-Yoke Active: VAT mismatch detected. Executive bonus payouts are physically blocked from manual HR override.'
                              : 'Payroll Discretion Status: Normal. VAT reconciliation verified with 0 defects.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _complianceBreached ? FtaVatRegulatoryCompliancePanelTokens.onErrorContainer : FtaVatRegulatoryCompliancePanelTokens.onSuccessContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FtaVatRegulatoryCompliancePanelTokens.vGapMd,

                // Controls (Min 48x48dp target)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: FilledButton.tonalIcon(
                        onPressed: _toggleBreachSimulation,
                        icon: Icon(_complianceBreached ? Icons.refresh_rounded : Icons.warning_rounded),
                        label: Text(_complianceBreached ? 'Clear Compliance Breach' : 'Simulate VAT Discrepancy Breach'),
                        style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
                      ),
                    ),
                    if (_complianceBreached)
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        child: OutlinedButton.icon(
                          onPressed: _showRecoveryDialog,
                          icon: const Icon(Icons.help_outline_rounded),
                          label: const Text('Recovery Guidance'),
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
abstract final class FtaVatRegulatoryCompliancePanelTokens {
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
            child: FtaVatRegulatoryCompliancePanel(),
          ),
        ),
      ),
    ),
  );
}
