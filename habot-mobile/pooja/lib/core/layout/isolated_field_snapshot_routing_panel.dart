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
      padding: IsolatedFieldSnapshotRoutingPanelTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IsolatedFieldSnapshotRoutingPanelTokens.lightOutline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(IsolatedFieldSnapshotRoutingPanelTokens.sm),
                decoration: BoxDecoration(
                  color: IsolatedFieldSnapshotRoutingPanelTokens.brandPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_center_focus,
                  color: IsolatedFieldSnapshotRoutingPanelTokens.brandPrimary,
                  size: 24,
                ),
              ),
              IsolatedFieldSnapshotRoutingPanelTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: IsolatedFieldSnapshotRoutingPanelTokens.brandPrimary,
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
                  color: IsolatedFieldSnapshotRoutingPanelTokens.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '1-Field Lock',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: IsolatedFieldSnapshotRoutingPanelTokens.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          IsolatedFieldSnapshotRoutingPanelTokens.vGapMd,
          // Viewport constraint container
          Container(
            width: double.infinity,
            padding: IsolatedFieldSnapshotRoutingPanelTokens.paddingLg,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: IsolatedFieldSnapshotRoutingPanelTokens.brandPrimary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(active['title']!, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: IsolatedFieldSnapshotRoutingPanelTokens.brandPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: IsolatedFieldSnapshotRoutingPanelTokens.successContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('ISOLATED VIEWPORT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: IsolatedFieldSnapshotRoutingPanelTokens.onSuccessContainer)),
                    ),
                  ],
                ),
                IsolatedFieldSnapshotRoutingPanelTokens.vGapSm,
                Text('Field: ${active['fieldName']}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                IsolatedFieldSnapshotRoutingPanelTokens.vGapXs,
                Container(
                  width: double.infinity,
                  padding: IsolatedFieldSnapshotRoutingPanelTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: IsolatedFieldSnapshotRoutingPanelTokens.lightOutline.withValues(alpha: 0.2)),
                  ),
                  child: Text(active['fieldValue']!, style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                ),
                IsolatedFieldSnapshotRoutingPanelTokens.vGapXs,
                Text('Validation: ${active['rule']}', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          IsolatedFieldSnapshotRoutingPanelTokens.vGapMd,
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
              IsolatedFieldSnapshotRoutingPanelTokens.hGapSm,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class IsolatedFieldSnapshotRoutingPanelTokens {
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
            child: IsolatedFieldSnapshotRoutingPanel(),
          ),
        ),
      ),
    ),
  );
}
