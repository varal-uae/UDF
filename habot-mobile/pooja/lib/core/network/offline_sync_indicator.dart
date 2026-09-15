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
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

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
        bg = AppColorPalette.successContainer;
        fg = AppColorPalette.onSuccessContainer;
        iconData = Icons.cloud_done;
        break;
      case SyncStatus.syncing:
      case SyncStatus.reconnecting:
        bg = AppColorPalette.infoContainer;
        fg = AppColorPalette.onInfoContainer;
        iconData = Icons.sync;
        break;
      case SyncStatus.offline:
        bg = AppColorPalette.warningContainer;
        fg = AppColorPalette.onWarningContainer;
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
          borderRadius: BorderRadius.circular(AppSpacingTokens.lg),
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
                    horizontal: AppSpacingTokens.md,
                    vertical: AppSpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppSpacingTokens.lg),
                    border: widget.syncState.pendingQueueCount > 0
                        ? Border.all(color: AppColorPalette.warning, width: 1.5)
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
                      AppSpacingTokens.hGapXs,
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
                        AppSpacingTokens.hGapXs,
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
