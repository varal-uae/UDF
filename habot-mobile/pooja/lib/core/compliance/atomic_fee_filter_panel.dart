/*
 * STEP 41: PELCE-007-20 — Atomic Action Filter: Flat-Rate Platform Fee Deduction
 * 
 * Setup Step (Action): Implement the atomic action filter that performs flat-rate
 *   platform fee deductions, ensuring that the logic is transparent to
 *   non-technical operational track leads.
 * Setup Step Description: Apply highly responsive dimensions, ample breathing
 *   room, and clean contrast parameters to the visual layout components.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Interface layouts utilize ample breathing room to separate actionable display layers.
 *   - Interactive text strings preserve clean contrast parameters against background graphics (WCAG 2.2 AA/AAA >=7:1).
 *   - Visual layout components employ highly responsive dimensions to keep fields structured.
 *   - Transparent mathematical breakdown for non-technical operational track leads.
 * 
 * What Was Done to Complete This Step:
 *   - Created `AtomicFeeFilterPanel` widget and `AtomicFeeFilterRecord` data model.
 *   - Implemented `PlatformFeeDeductionFilter` and `ContrastRatioValidator` calculation engines.
 *   - Added interactive gross & flat-rate fee adjustment controls, contrast compliance status badge, and dense audit table.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step PELCE-007-20: Atomic Fee Filter Audit Record Data Model.
class AtomicFeeFilterRecord {
  final String layoutType;
  final String layoutGridDimensions;
  final String spacingRules;
  final String alignmentSettings;
  final String layoutValidationStatus;
  final String completionStatus; // 'Pass (≥7:1)' / 'Fail (<4.5:1)'
  final String actionTimestamp;
  final String userSessionId;
  final String contrastStandard;
  final double contrastRatio;

  const AtomicFeeFilterRecord({
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
    this.completionStatus = 'Pass (≥7:1)',
    required this.actionTimestamp,
    required this.userSessionId,
    this.contrastStandard = 'WCAG 2.2 SC 1.4.3 (AA) / SC 1.4.6 (AAA)',
    this.contrastRatio = 7.0,
  });
}

/// Itemized breakdown of a flat-rate fee deduction.
class FeeDeductionResult {
  final double grossAmount;
  final double flatFeeAmount;
  final double netAmount;
  final double effectiveFeePercentage;
  final String explanation;

  const FeeDeductionResult({
    required this.grossAmount,
    required this.flatFeeAmount,
    required this.netAmount,
    required this.effectiveFeePercentage,
    required this.explanation,
  });
}

/// Platform Fee Deduction Filter Engine.
abstract class PlatformFeeDeductionFilter {
  static FeeDeductionResult apply({
    required double grossAmount,
    required double flatFeeAmount,
  }) {
    if (grossAmount < 0 || flatFeeAmount < 0) {
      final safeGross = grossAmount < 0 ? 0.0 : grossAmount;
      final safeFee = flatFeeAmount < 0 ? 0.0 : flatFeeAmount;
      return FeeDeductionResult(
        grossAmount: safeGross,
        flatFeeAmount: safeFee,
        netAmount: safeGross,
        effectiveFeePercentage: 0.0,
        explanation: 'Invalid negative value entered. Calculation halted.',
      );
    }
    if (flatFeeAmount > grossAmount) {
      return FeeDeductionResult(
        grossAmount: grossAmount,
        flatFeeAmount: flatFeeAmount,
        netAmount: 0.0,
        effectiveFeePercentage: grossAmount == 0 ? 0.0 : (flatFeeAmount / grossAmount) * 100,
        explanation:
            'Flat fee (\$${flatFeeAmount.toStringAsFixed(2)}) exceeds gross amount '
            '(\$${grossAmount.toStringAsFixed(2)}); net payout capped at \$0.00.',
      );
    }

    final netAmount = grossAmount - flatFeeAmount;
    final effectivePct = grossAmount == 0 ? 0.0 : (flatFeeAmount / grossAmount) * 100;

    final explanation = grossAmount == 0
        ? 'Gross amount is 0.00, so no fee is deducted and net payout is 0.00.'
        : 'A flat platform fee of \$${flatFeeAmount.toStringAsFixed(2)} was '
            'deducted from the gross amount of \$${grossAmount.toStringAsFixed(2)}, '
            'leaving a net payout of \$${netAmount.toStringAsFixed(2)}. This flat '
            'fee equals ${effectivePct.toStringAsFixed(2)}% of this transaction, '
            'providing complete fee transparency to operational track leads.';

    return FeeDeductionResult(
      grossAmount: grossAmount,
      flatFeeAmount: flatFeeAmount,
      netAmount: netAmount,
      effectiveFeePercentage: effectivePct,
      explanation: explanation,
    );
  }
}

/// Contrast Ratio Validator Engine.
abstract class ContrastRatioValidator {
  static const double floor = 4.5;
  static const double optimal = 7.0;

  static String evaluate(double measuredRatio) {
    if (measuredRatio >= optimal) {
      return 'Pass/Fail → Best = Pass (≥7:1) [AAA Optimal]';
    }
    if (measuredRatio >= floor) {
      return 'Pass (meets AA floor 4.5:1)';
    }
    return 'Fail (below AA floor 4.5:1)';
  }
}

/// Step PELCE-007-20: Atomic Fee Filter Panel Component.
class AtomicFeeFilterPanel extends StatefulWidget {
  final AtomicFeeFilterRecord record;

  const AtomicFeeFilterPanel({
    super.key,
    required this.record,
  });

  @override
  State<AtomicFeeFilterPanel> createState() => _AtomicFeeFilterPanelState();
}

class _AtomicFeeFilterPanelState extends State<AtomicFeeFilterPanel> {
  double _grossAmount = 150.0;
  double _flatFeeAmount = 15.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final feeResult = PlatformFeeDeductionFilter.apply(
      grossAmount: _grossAmount,
      flatFeeAmount: _flatFeeAmount,
    );
    final contrastStatusLabel = ContrastRatioValidator.evaluate(widget.record.contrastRatio);
    final isPass = widget.record.contrastRatio >= ContrastRatioValidator.floor;

    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingMd,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header Card ---
              Card(
                elevation: 2,
                color: colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.filter_alt_outlined, color: colorScheme.primary, size: 28),
                          AppSpacingTokens.hGapSm,
                          Expanded(
                            child: Text(
                              'Step 41: Atomic Action Filter: Flat-Rate Platform Fee Deduction',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'PELCE-007-20',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      Text(
                        'Applies highly responsive dimensions, ample breathing room, and clean contrast parameters to visual layout components, ensuring fee calculation logic is transparent to non-technical track leads.',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Fee Deduction Calculator Card ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flat-Rate Fee Deduction Breakdown',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacingTokens.vGapSm,
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _grossAmount,
                              min: 0,
                              max: 1000,
                              divisions: 100,
                              label: 'Gross \$${_grossAmount.toStringAsFixed(0)}',
                              onChanged: (val) => setState(() => _grossAmount = val),
                            ),
                          ),
                          Text('Gross: \$${_grossAmount.toStringAsFixed(2)}', style: theme.textTheme.labelMedium),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _flatFeeAmount,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: 'Fee \$${_flatFeeAmount.toStringAsFixed(0)}',
                              onChanged: (val) => setState(() => _flatFeeAmount = val),
                            ),
                          ),
                          Text('Flat Fee: \$${_flatFeeAmount.toStringAsFixed(2)}', style: theme.textTheme.labelMedium),
                        ],
                      ),
                      const Divider(),
                      AppSpacingTokens.vGapXs,
                      Text(
                        'Gross: \$${feeResult.grossAmount.toStringAsFixed(2)}   |   '
                        'Flat Fee: \$${feeResult.flatFeeAmount.toStringAsFixed(2)}   |   '
                        'Net Payout: \$${feeResult.netAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      AppSpacingTokens.vGapSm,
                      Container(
                        padding: AppSpacingTokens.paddingSm,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Text(
                          feeResult.explanation,
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- Contrast Ratio Metric Status Card ---
              Card(
                elevation: 1,
                color: isPass ? AppColorPalette.successContainer : AppColorPalette.warningContainer,
                child: Padding(
                  padding: AppSpacingTokens.paddingMd,
                  child: Row(
                    children: [
                      Icon(
                        isPass ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                        color: isPass ? AppColorPalette.onSuccessContainer : AppColorPalette.onWarningContainer,
                      ),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'Text/UI Contrast Ratio: ${widget.record.contrastRatio.toStringAsFixed(1)}:1 — $contrastStatusLabel',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isPass ? AppColorPalette.onSuccessContainer : AppColorPalette.onWarningContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // --- System Audit Fields Table ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Collected by System',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacingTokens.vGapSm,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Layout Type')),
                            DataColumn(label: Text('Grid Dimensions')),
                            DataColumn(label: Text('Spacing Rules')),
                            DataColumn(label: Text('Alignment')),
                            DataColumn(label: Text('Validation Status')),
                            DataColumn(label: Text('Completion Status')),
                            DataColumn(label: Text('Session ID')),
                          ],
                          rows: [
                            DataRow(cells: [
                              DataCell(Text(widget.record.layoutType)),
                              DataCell(Text(widget.record.layoutGridDimensions)),
                              DataCell(Text(widget.record.spacingRules)),
                              DataCell(Text(widget.record.alignmentSettings)),
                              DataCell(Text(widget.record.layoutValidationStatus)),
                              DataCell(Text(widget.record.completionStatus)),
                              DataCell(Text(widget.record.userSessionId)),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
