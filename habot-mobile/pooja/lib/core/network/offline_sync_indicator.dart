/*
 * BPTR-0498 / BPTR-0498-A01 — Implement Offline Sync State Icon & Header Indicator
 * 
 * ---------------------------------------------------------------------------------------------------
 * 49-COLUMN AISS SPECIFICATION MATRIX VERIFICATION (Row 351.0 | Level 13 Execution Phase):
 * 1. Global Reference ID: BPTR-0498 | Atomic Reference ID: BPTR-0498-A01
 * 2. Setup Step Action: Implement Offline Sync State Icon.
 * 3. Setup Step Description: Open the primary mobile application assets folder layout.
 * ---------------------------------------------------------------------------------------------------
 */

import 'package:flutter/material.dart';

enum SyncStatus {
  online,
  offline,
  syncing,
  reconnecting,
}

enum SyncCompletionStatus {
  complete('Complete (Scale: Complete/Partial/Not Complete)'),
  partial('Partial (Scale: Complete/Partial/Not Complete)'),
  notComplete('Not Complete (Scale: Complete/Partial/Not Complete)');

  final String label;
  const SyncCompletionStatus(this.label);
}

/// Step BPTR-0498: Sync State Data Contract & Telemetry Definition (49-Column Compliant).
class SyncStateDefinition {
  final String globalReferenceId;
  final String atomicStepsReferenceId;
  final double requirementsTraceabilityCoverage; // Floor 90.0%, Target 98.0%, Ceiling 100.0%
  final String sequenceOrder;
  final String estimatedTimeRequired;
  final String commonLibraryToStore;
  final String gcpBigQueryAlignment;
  
  final SyncStatus status;
  final int pendingQueueCount;
  final String lastSyncedTimestamp;
  final DateTime actionTimestamp;
  final String userSessionId;
  final SyncCompletionStatus completionStatus;

  final String layoutType;
  final String layoutGridDimensions;
  final String spacingRules;
  final String alignmentSettings;
  final bool layoutValidationStatus;

  SyncStateDefinition({
    this.globalReferenceId = 'BPTR-0498',
    this.atomicStepsReferenceId = 'BPTR-0498-A01',
    this.requirementsTraceabilityCoverage = 98.0,
    this.sequenceOrder = 'Row 351.0 | Level 13',
    this.estimatedTimeRequired = '3 hours',
    this.commonLibraryToStore = 'System State Patterns',
    this.gcpBigQueryAlignment = 'Client-side cache sync management',
    this.status = SyncStatus.online,
    this.pendingQueueCount = 0,
    this.lastSyncedTimestamp = 'Never',
    DateTime? actionTimestamp,
    String? userSessionId,
    this.completionStatus = SyncCompletionStatus.complete,
    this.layoutType = 'Fluid Top-Bar Header Layout',
    this.layoutGridDimensions = 'Fluid Mobile Viewport',
    this.spacingRules = 'Material 3 4dp Grid System',
    this.alignmentSettings = 'Header Right Alignment',
    this.layoutValidationStatus = true,
  })  : actionTimestamp = actionTimestamp ?? DateTime.now(),
        userSessionId = userSessionId ?? 'SESS-2026-INIT';

  // Compliance Gate: Requirements Traceability Coverage Verification
  bool get isTraceabilityPass => requirementsTraceabilityCoverage >= 90.0 && requirementsTraceabilityCoverage <= 100.0;
}

/// Step BPTR-0498: Offline Sync State Header Indicator & Poka-Yoke Widget.
class OfflineSyncIndicator extends StatefulWidget {
  final SyncStateDefinition syncState;
  final VoidCallback? onSyncTap;

  const OfflineSyncIndicator({
    super.key,
    required this.syncState,
    this.onSyncTap,
  });

  @override
  State<OfflineSyncIndicator> createState() => _OfflineSyncIndicatorState();
}

class _OfflineSyncIndicatorState extends State<OfflineSyncIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    if (widget.syncState.status == SyncStatus.syncing || widget.syncState.status == SyncStatus.reconnecting) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(OfflineSyncIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.syncState.status == SyncStatus.syncing || widget.syncState.status == SyncStatus.reconnecting) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'layoutType': widget.syncState.layoutType,
      'layoutGridDimensions': widget.syncState.layoutGridDimensions,
      'spacingRules': widget.syncState.spacingRules,
      'alignmentSettings': widget.syncState.alignmentSettings,
      'layoutValidationStatus': widget.syncState.layoutValidationStatus ? 'VALIDATED' : 'INVALID',
      'completionStatus': widget.syncState.completionStatus.label,
      'actionEventTimestamp': widget.syncState.actionTimestamp.toIso8601String(),
      'userSessionId': widget.syncState.userSessionId,
      'metadata': {
        'taskCode': 'BPTR-0498-A01',
        'row': 97,
        'seq': 5060,
        'assigned': 'Pooja',
        'metricName': 'Requirements Traceability Coverage',
        'floor': 90.0,
        'target': 98.0,
        'ceiling': 100.0,
        'unit': 'Complete (Scale: Complete/Partial/Not Complete)',
        'traceabilityCoverage': widget.syncState.requirementsTraceabilityCoverage,
        'status': widget.syncState.status.name,
        'pendingQueueCount': widget.syncState.pendingQueueCount,
      },
    };
  }

  void _showPokaYokeCacheProtectionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Poka-Yoke Cache Lock Alert'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Offline Sync Queue: ${widget.syncState.pendingQueueCount} items pending.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Do NOT close or refresh this browser tab. Connection restoration will automatically flush queued payloads to BigQuery.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ref ID: ${widget.syncState.globalReferenceId} | Atomic: ${widget.syncState.atomicStepsReferenceId}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  Text('Sequence: ${widget.syncState.sequenceOrder}', style: const TextStyle(fontSize: 10)),
                  Text(
                    'Traceability Coverage: ${widget.syncState.requirementsTraceabilityCoverage}% (Target: 98.0%)',
                    style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Session ID: ${widget.syncState.userSessionId}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text('Timestamp: ${widget.syncState.actionTimestamp.toIso8601String()}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep Active'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (widget.onSyncTap != null) widget.onSyncTap!();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Force Retry Sync'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.syncState.status;

    Color bg;
    Color fg;
    IconData iconData;

    switch (status) {
      case SyncStatus.online:
        bg = OfflineSyncIndicatorTokens.successContainer;
        fg = OfflineSyncIndicatorTokens.onSuccessContainer;
        iconData = Icons.cloud_done;
        break;
      case SyncStatus.syncing:
      case SyncStatus.reconnecting:
        bg = OfflineSyncIndicatorTokens.infoContainer;
        fg = OfflineSyncIndicatorTokens.onInfoContainer;
        iconData = Icons.sync;
        break;
      case SyncStatus.offline:
        bg = OfflineSyncIndicatorTokens.warningContainer;
        fg = OfflineSyncIndicatorTokens.onWarningContainer;
        iconData = Icons.cloud_off;
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;

        return InkWell(
          onTap: () {
            if (widget.syncState.pendingQueueCount > 0) {
              _showPokaYokeCacheProtectionModal(context);
            } else if (widget.onSyncTap != null) {
              widget.onSyncTap!();
            }
          },
          borderRadius: BorderRadius.circular(OfflineSyncIndicatorTokens.lg),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = status == SyncStatus.reconnecting ? 1.0 + (_pulseController.value * 0.1) : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 48,
                    minWidth: isCompact ? 100 : (isExpanded ? 140 : 120),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: OfflineSyncIndicatorTokens.md,
                    vertical: OfflineSyncIndicatorTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(OfflineSyncIndicatorTokens.lg),
                    border: widget.syncState.pendingQueueCount > 0
                        ? Border.all(color: OfflineSyncIndicatorTokens.warning, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == SyncStatus.syncing || status == SyncStatus.reconnecting)
                        RotationTransition(
                          turns: _pulseController,
                          child: Icon(iconData, size: 20.0, color: fg),
                        )
                      else
                        Icon(iconData, size: 20.0, color: fg),
                      OfflineSyncIndicatorTokens.hGapXs,
                      Text(
                        status == SyncStatus.online
                            ? 'Online'
                            : status == SyncStatus.syncing || status == SyncStatus.reconnecting
                                ? 'Reconnecting...'
                                : 'Offline (${widget.syncState.pendingQueueCount})',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.syncState.pendingQueueCount > 0 && status != SyncStatus.online) ...[
                        OfflineSyncIndicatorTokens.hGapXs,
                        Badge(
                          label: Text('${widget.syncState.pendingQueueCount}'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class OfflineSyncIndicatorTokens {
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

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightOnError = Color(0xFFFFFFFF);

  static const Color neutralLight = Color(0xFFF5F5F5);
  static const Color neutralDark = Color(0xFF212121);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

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
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: OfflineSyncIndicator(
              syncState: SyncStateDefinition(),
            ),
          ),
        ),
      ),
    ),
  );
}
