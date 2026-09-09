// BPTR-0498-A03 — Offline Sync State Icon.
// Global app shell header icon that indicates local persistence vs cloud sync, pulses green while queued, and notifies when refresh is blocked to prevent cache wipe.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum OfflineSyncStatus { online, offline, syncing }

class OfflineSyncStateIcon extends StatefulWidget {
  const OfflineSyncStateIcon({
    super.key,
    required this.syncQueueCount,
    this.onRefreshBlocked,
    this.semanticLabelOnline = 'Online - all changes synced',
    this.semanticLabelOffline = 'Offline - changes saved locally',
    this.semanticLabelSyncing = 'Syncing - queued changes',
  });

  final int syncQueueCount;
  final VoidCallback? onRefreshBlocked;
  final String semanticLabelOnline;
  final String semanticLabelOffline;
  final String semanticLabelSyncing;

  @override
  State<OfflineSyncStateIcon> createState() => _OfflineSyncStateIconState();
}

class _OfflineSyncStateIconState extends State<OfflineSyncStateIcon> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;
  bool _isSyncing = false;
  Timer? _pulseTimer;

  OfflineSyncStatus get _status {
    if (!_isOnline) return OfflineSyncStatus.offline;
    if (_isSyncing || widget.syncQueueCount > 0) return OfflineSyncStatus.syncing;
    return OfflineSyncStatus.online;
  }

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_handleConnectivityChanged);
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _handleConnectivityChanged(results);
  }

  void _handleConnectivityChanged(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    final wasOffline = !_isOnline;
    setState(() {
      _isOnline = online;
      _isSyncing = online && wasOffline && widget.syncQueueCount > 0;
    });
    if (_isSyncing) {
      _startPulse();
    } else {
      _stopPulse();
    }
  }

  void _startPulse() {
    _pulseTimer?.cancel();
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      setState(() {});
    });
  }

  void _stopPulse() {
    _pulseTimer?.cancel();
    _pulseTimer = null;
  }

  @override
  void didUpdateWidget(covariant OfflineSyncStateIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.syncQueueCount > 0 && _isOnline) {
      _isSyncing = true;
      _startPulse();
    } else if (widget.syncQueueCount == 0) {
      _isSyncing = false;
      _stopPulse();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = _status;
    final IconData icon;
    final Color color;
    final String semanticLabel;
    switch (status) {
      case OfflineSyncStatus.online:
        icon = Icons.cloud_done_outlined;
        color = colorScheme.primary;
        semanticLabel = widget.semanticLabelOnline;
        break;
      case OfflineSyncStatus.offline:
        icon = Icons.cloud_off_outlined;
        color = colorScheme.error;
        semanticLabel = widget.semanticLabelOffline;
        break;
      case OfflineSyncStatus.syncing:
        icon = Icons.sync;
        final phase = (_pulseTimer?.tick ?? 0) % 2;
        color = Colors.green.withOpacity(phase == 0 ? 0.5 : 1.0);
        semanticLabel = widget.semanticLabelSyncing;
        break;
    }
    return Semantics(
      label: semanticLabel,
      container: true,
      child: IconButton(
        tooltip: semanticLabel,
        onPressed: () {
          if (widget.syncQueueCount > 0) {
            widget.onRefreshBlocked?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.syncQueueCount} unsynced changes. Keep app open until sync completes.'),
              ),
            );
          }
        },
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Icon(
            icon,
            key: ValueKey(status),
            color: color,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}
