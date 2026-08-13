/*
 * STEP 3: BPTR-0498 — Implement Offline Sync State Icon & Header Indicator
 * 
 * Setup Step (Action): Open the primary mobile application assets folder layout.
 * Setup Step Description: Select offline icon (cloud with slash), define sync pending badge count,
 *   design "Reconnecting" animation, set persistent placement logic.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Persistent header icon tracking local storage vs cloud sync.
 *   - Clear distinction between online, offline (queued), and syncing states.
 *   - Prevents data loss anxiety on mobile 4G/5G drops.
 * 
 * What Was Done to Complete This Step:
 *   - Created `OfflineSyncIndicator` widget, `SyncStateDefinition` model, and `SyncStatus` enum in a single file.
 *   - Implemented cloud-off/cloud-queue visual tokens, animated rotating sync icon, and pending queue count badge.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

enum SyncStatus {
  online,
  offline,
  syncing,
}

class SyncStateDefinition {
  final SyncStatus status;
  final int pendingQueueCount;
  final String lastSyncedTimestamp;

  const SyncStateDefinition({
    required this.status,
    this.pendingQueueCount = 0,
    required this.lastSyncedTimestamp,
  });
}

/// Step BPTR-0498: Offline Sync State Header Indicator & Animation.
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
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    if (widget.syncState.status == SyncStatus.syncing) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(OfflineSyncIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.syncState.status == SyncStatus.syncing) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
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

    return InkWell(
      onTap: widget.onSyncTap,
      borderRadius: BorderRadius.circular(AppSpacingTokens.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm, vertical: AppSpacingTokens.xs),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacingTokens.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == SyncStatus.syncing)
              RotationTransition(
                turns: _rotationController,
                child: Icon(iconData, size: 18.0, color: fg),
              )
            else
              Icon(iconData, size: 18.0, color: fg),
            AppSpacingTokens.hGapXs,
            Text(
              status == SyncStatus.online
                  ? 'Online'
                  : status == SyncStatus.syncing
                      ? 'Syncing...'
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
  }
}
