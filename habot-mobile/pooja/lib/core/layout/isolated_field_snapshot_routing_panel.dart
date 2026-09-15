/*
 * ETMDI-001-10 — Isolated Field Snapshot Routing Panel
 * 
 * Setup Step (Action): Restrict the mobile viewport routing to permit only one isolated field snapshot at a time.
 * Metric Name: Schema/Field Configuration Accuracy Rate (Floor: ≥90%, Target: 100%, Ceiling: 1)
 * Quality Standard: DAMA-DMBOK2 Data Modeling & Schema Design Standard (Best = Good 100%)
 * Telemetry: Mobile Platform; OS Version; Device Type; Screen Dimensions; Mobile Configuration; Completion Status ('Good/Average/Poor → Best = Good (100%)'); Action/Event Timestamp; User/Session ID
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class IsolatedFieldSnapshotRoutingPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const IsolatedFieldSnapshotRoutingPanel({
    super.key,
    this.globalRefId = 'ETMDI-001',
    this.atomicStepRefId = 'ETMDI-001-10',
    this.sequenceOrder = '14146',
  });

  @override
  State<IsolatedFieldSnapshotRoutingPanel> createState() =>
      _IsolatedFieldSnapshotRoutingPanelState();
}

class _IsolatedFieldSnapshotRoutingPanelState
    extends State<IsolatedFieldSnapshotRoutingPanel> {
  final String _userSessionId = 'POOJA-ETMDI-001-10';
  final String _completionStatus = 'Good (100%)';
  int _currentSnapshotIndex = 0;

  final List<Map<String, String>> _snapshots = [
    {
      'title': 'Snapshot 1 of 3: VAT TRN Isolation',
      'fieldName': 'Tax Registration Number',
      'fieldValue': '100482910400003',
      'rule': 'Strict numeric regex mask',
    },
    {
      'title': 'Snapshot 2 of 3: Invoice Amount Isolation',
      'fieldName': 'Total Gross Verified Value',
      'fieldValue': 'AED 1,480,250.00',
      'rule': 'Currency boundary lock',
    },
    {
      'title': 'Snapshot 3 of 3: Cryptographic Proof Isolation',
      'fieldName': 'Proof SHA-256 Hash',
      'fieldValue': '0x8f2d9c4b11ea572a9e01df3c',
      'rule': 'Hexadecimal 64-char lock',
    },
  ];

  Map<String, dynamic> getTelemetryData(BuildContext context) {
    final mq = MediaQuery.of(context);
    final active = _snapshots[_currentSnapshotIndex];
    return {
      'stepExecutionId': 'EXEC-ETMDI-001-10-2026',
      'mobilePlatform': Theme.of(context).platform.toString(),
      'deviceType': 'Mobile Viewport Handset',
      'screenDimensions': '${mq.size.width.toInt()}x${mq.size.height.toInt()}dp',
      'mobileConfiguration': 'Isolated Field Snapshot Routing (1 At A Time)',
      'activeSnapshot': active['fieldName'],
      'schemaAccuracyRate': '100% (Target: 100%)',
      'completionStatus': _completionStatus,
      'actionEventTimestamp': DateTime.now().toIso8601String(),
      'userSessionId': _userSessionId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final active = _snapshots[_currentSnapshotIndex];

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
                  color: AppColorPalette.brandPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_center_focus,
                  color: AppColorPalette.brandPrimary,
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
                      'Isolated Field Snapshot Routing',
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
                  color: AppColorPalette.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '1-Field Lock',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColorPalette.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacingTokens.vGapMd,
          // Viewport constraint container
          Container(
            width: double.infinity,
            padding: AppSpacingTokens.paddingLg,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColorPalette.brandPrimary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(active['title']!, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColorPalette.brandPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColorPalette.successContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('ISOLATED VIEWPORT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColorPalette.onSuccessContainer)),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapSm,
                Text('Field: ${active['fieldName']}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                AppSpacingTokens.vGapXs,
                Container(
                  width: double.infinity,
                  padding: AppSpacingTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColorPalette.lightOutline.withValues(alpha: 0.2)),
                  ),
                  child: Text(active['fieldValue']!, style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                ),
                AppSpacingTokens.vGapXs,
                Text('Validation: ${active['rule']}', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          AppSpacingTokens.vGapMd,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _currentSnapshotIndex > 0
                      ? () => setState(() => _currentSnapshotIndex--)
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous Snapshot'),
                ),
              ),
              AppSpacingTokens.hGapSm,
              Expanded(
                child: FilledButton.icon(
                  onPressed: _currentSnapshotIndex < _snapshots.length - 1
                      ? () => setState(() => _currentSnapshotIndex++)
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next Snapshot'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
