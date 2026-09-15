/*
 * CUITC-039 — UAE FTA VAT Regulatory Compliance & Payroll Gate
 * 
 * Setup Step (Action): Review FTA VAT regulatory parameters and requirements.
 * Metric Name: Regulatory Compliance Defect Resolution / Correction Rate (%) (Floor: 0.9, Target: 0.99, Ceiling: 1.0)
 * Quality Standard: Six Sigma DMAIC defect-closure benchmark; COSO Internal Control / ISO 19600 guidelines.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

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
            Icon(Icons.shield_outlined, color: AppColorPalette.brandPrimary),
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
            ? AppSpacingTokens.paddingSm
            : (isExpanded ? AppSpacingTokens.paddingLg : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _complianceBreached
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
                        color: (_complianceBreached ? AppColorPalette.lightError : AppColorPalette.brandPrimary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _complianceBreached ? Icons.gavel_rounded : Icons.verified_rounded,
                        color: _complianceBreached ? AppColorPalette.lightError : AppColorPalette.brandPrimary,
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
                        color: _complianceBreached ? AppColorPalette.errorContainer : AppColorPalette.successContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _complianceBreached ? 'Suspended' : 'Good (99.5%)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _complianceBreached ? AppColorPalette.onErrorContainer : AppColorPalette.onSuccessContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                // TRN & VAT Computation Card
                Container(
                  padding: AppSpacingTokens.paddingMd,
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
                          Text('AED ${_calculatedVat.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AppColorPalette.brandPrimary)),
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
                AppSpacingTokens.vGapMd,

                // Poka-Yoke Payroll Bonus Lock Gate
                Container(
                  padding: AppSpacingTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: _complianceBreached
                        ? AppColorPalette.errorContainer.withValues(alpha: 0.6)
                        : AppColorPalette.successContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _complianceBreached ? AppColorPalette.lightError : AppColorPalette.success),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _complianceBreached ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                        size: 20,
                        color: _complianceBreached ? AppColorPalette.lightError : AppColorPalette.success,
                      ),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          _complianceBreached
                              ? 'Poka-Yoke Active: VAT mismatch detected. Executive bonus payouts are physically blocked from manual HR override.'
                              : 'Payroll Discretion Status: Normal. VAT reconciliation verified with 0 defects.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _complianceBreached ? AppColorPalette.onErrorContainer : AppColorPalette.onSuccessContainer,
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
