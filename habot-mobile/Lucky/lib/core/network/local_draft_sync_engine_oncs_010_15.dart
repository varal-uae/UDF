// ONCS-010-15 — Local Draft Storage Synchronization Engine.
// Configures background state synchronization to preserve user data entries through unexpected network dropouts using local storage, with visual sync status indicators and offline badges.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

/// Atomic-level data fields for Sync tracking.
enum SyncType { manual, automatic, background }

enum SyncStatus { idle, syncing, success, failed, offline, conflict }

class SyncRecord {
  final String id;
  final SyncType syncType;
  final SyncStatus syncStatus;
  final DateTime lastSyncDate;
  final List<String> syncConflicts;
  final Duration syncDuration;
  final String? payload;

  const SyncRecord({
    required this.id,
    required this.syncType,
    required this.syncStatus,
    required this.lastSyncDate,
    required this.syncConflicts,
    required this.syncDuration,
    this.payload,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'syncType': syncType.name,
        'syncStatus': syncStatus.name,
        'lastSyncDate': lastSyncDate.toIso8601String(),
        'syncConflicts': syncConflicts,
        'syncDurationMs': syncDuration.inMilliseconds,
        'payload': payload,
      };

  factory SyncRecord.fromJson(Map<String, dynamic> json) => SyncRecord(
        id: json['id'] as String,
        syncType: SyncType.values.firstWhere((e) => e.name == json['syncType']),
        syncStatus: SyncStatus.values.firstWhere((e) => e.name == json['syncStatus']),
        lastSyncDate: DateTime.parse(json['lastSyncDate'] as String),
        syncConflicts: List<String>.from(json['syncConflicts'] ?? []),
        syncDuration: Duration(milliseconds: json['syncDurationMs'] as int? ?? 0),
        payload: json['payload'] as String?,
      );
}

/// Mock Local Storage Engine (Replaces browser IndexedDB boundaries).
/// In production Flutter, this maps to Hive, Drift, or SharedPreferences.
class MockIndexedDbStorage {
  final Map<String, String> _store = {};

  Future<void> put(String key, String value) async {
    await Future.delayed(const Duration(milliseconds: 15));
    _store[key] = value;
  }

  Future<String?> get(String key) async {
    await Future.delayed(const Duration(milliseconds: 15));
    return _store[key];
  }

  Future<List<String>> getAllKeys() async {
    await Future.delayed(const Duration(milliseconds: 15));
    return _store.keys.toList();
  }

  Future<void> delete(String key) async {
    await Future.delayed(const Duration(milliseconds: 15));
    _store.remove(key);
  }
}

/// Background state synchronization manager.
class LocalDraftSyncEngine extends ChangeNotifier {
  final MockIndexedDbStorage _storage = MockIndexedDbStorage();
  
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  final List<SyncRecord> _syncHistory = [];
  List<SyncRecord> get syncHistory => List.unmodifiable(_syncHistory);

  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _backgroundSyncTimer;

  LocalDraftSyncEngine() {
    _initMockConnectivityStream();
    _startBackgroundSyncManager();
  }

  void _initMockConnectivityStream() {
    // Simulating connectivity changes
    _connectivitySubscription = Stream<bool>.periodic(
      const Duration(seconds: 30),
      (count) => count % 5 != 0, // Occasionally simulate dropout
    ).listen((hasConnection) {
      _updateConnectivity(hasConnection);
    });
  }

  void _updateConnectivity(bool hasConnection) {
    if (_isOnline != hasConnection) {
      _isOnline = hasConnection;
      _currentStatus = hasConnection ? SyncStatus.idle : SyncStatus.offline;
      notifyListeners();
      
      if (hasConnection) {
        synchronizePendingDrafts();
      }
    }
  }

  void _startBackgroundSyncManager() {
    _backgroundSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_isOnline) {
        synchronizePendingDrafts();
      }
    });
  }

  /// Saves draft locally during offline mode or unexpected network dropouts.
  Future<void> saveDraftLocally(String draftId, Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    await _storage.put('draft_$draftId', jsonString);
    
    final record = SyncRecord(
      id: draftId,
      syncType: SyncType.background,
      syncStatus: _isOnline ? SyncStatus.idle : SyncStatus.offline,
      lastSyncDate: DateTime.now(),
      syncConflicts: [],
      syncDuration: Duration.zero,
      payload: jsonString,
    );
    _syncHistory.add(record);
    notifyListeners();
  }

  /// Automatically synchronizes when connectivity is restored.
  Future<void> synchronizePendingDrafts() async {
    if (!_isOnline || _currentStatus == SyncStatus.syncing) return;

    _currentStatus = SyncStatus.syncing;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    final keys = await _storage.getAllKeys();
    final draftKeys = keys.where((k) => k.startsWith('draft_')).toList();

    for (final key in draftKeys) {
      final payload = await _storage.get(key);
      if (payload != null) {
        try {
          // Simulate API call to backend
          await Future.delayed(const Duration(milliseconds: 200));
          
          // On success, clear from local IndexedDB equivalent
          await _storage.delete(key);
          
          _syncHistory.add(SyncRecord(
            id: key.replaceFirst('draft_', ''),
            syncType: SyncType.automatic,
            syncStatus: SyncStatus.success,
            lastSyncDate: DateTime.now(),
            syncConflicts: [],
            syncDuration: stopwatch.elapsed,
          ));
        } catch (e) {
          _syncHistory.add(SyncRecord(
            id: key.replaceFirst('draft_', ''),
            syncType: SyncType.automatic,
            syncStatus: SyncStatus.conflict,
            lastSyncDate: DateTime.now(),
            syncConflicts: ['Network timeout or server rejection'],
            syncDuration: stopwatch.elapsed,
          ));
        }
      }
    }

    stopwatch.stop();
    _currentStatus = draftKeys.isEmpty ? SyncStatus.idle : SyncStatus.success;
    notifyListeners();
  }

  /// Simulate forced offline mode for QA Testing (AISS verification).
  void forceOfflineModeForTesting() {
    _updateConnectivity(false);
  }

  void forceOnlineModeForTesting() {
    _updateConnectivity(true);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _backgroundSyncTimer?.cancel();
    super.dispose();
  }
}

/// UI Implementation: Network Status Warning Banner & Offline Badge.
/// Slides gracefully from app headers if sync tasks stall.
class SyncStatusBanner extends StatelessWidget {
  final LocalDraftSyncEngine syncEngine;

  const SyncStatusBanner({super.key, required this.syncEngine});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: syncEngine,
      builder: (context, child) {
        final isStalled = syncEngine.currentStatus == SyncStatus.offline ||
            syncEngine.currentStatus == SyncStatus.conflict;

        return AnimatedSlide(
          offset: isStalled ? Offset.zero : const Offset(0, -1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: isStalled ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Material(
              elevation: 2,
              color: syncEngine.currentStatus == SyncStatus.conflict
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  // Enforce unyielding padding lines to preserve layout structural balance
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Icon(
                        syncEngine.currentStatus == SyncStatus.conflict
                            ? Icons.sync_problem_rounded
                            : Icons.cloud_off_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          syncEngine.currentStatus == SyncStatus.conflict
                              ? 'Sync stalled: Conflict detected'
                              : 'Offline mode: Data saved locally',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      if (syncEngine.currentStatus == SyncStatus.offline)
                        _buildOfflineBadge(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Map offline status badges strictly to standard muted system color paths.
  Widget _buildOfflineBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Text(
        'OFFLINE',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

/// Quick-tap choice icons designed to simplify validation entry on mobile tracking layouts.
/// Includes invisible hit-slop expansion padding for small icon assets.
class QuickTapSyncIcon extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String tooltip;

  const QuickTapSyncIcon({
    super.key,
    required this.onTap,
    this.icon = Icons.sync_rounded,
    this.tooltip = 'Force Sync',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      button: true,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          // Configure invisible hit-slop expansion padding for small icon assets
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Expanded hit area
            child: Icon(
              icon,
              size: 24.0,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal dialog prompts to prevent users from bypassing task check steps during data entry.
class SyncValidationDialog {
  static Future<bool> showTaskCheckBypassPrevention(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sync Required'),
        content: const Text(
          'You must complete the data synchronization step before proceeding. '
          'Please ensure your connection is stable.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Acknowledge & Sync'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Fluid data-field arrangement grids that scale cleanly across changing screen orientations.
/// Forces validation metrics to maintain high-visibility formatting properties inside view templates.
class SyncMetricsGrid extends StatelessWidget {
  final List<SyncRecord> records;

  const SyncMetricsGrid({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : (constraints.maxWidth > 400 ? 2 : 1);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            childAspectRatio: 2.5,
          ),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _SyncMetricCard(record: record);
          },
        );
      },
    );
  }
}

class _SyncMetricCard extends StatelessWidget {
  final SyncRecord record;
  const _SyncMetricCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color statusColor;
    switch (record.syncStatus) {
      case SyncStatus.success:
        statusColor = colorScheme.primary;
        break;
      case SyncStatus.failed:
      case SyncStatus.conflict:
        statusColor = colorScheme.error;
        break;
      case SyncStatus.syncing:
        statusColor = colorScheme.tertiary;
        break;
      default:
        statusColor = colorScheme.outline;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.id,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Force validation metrics to maintain high-visibility formatting properties
            Text(
              'Status: ${record.syncStatus.name.toUpperCase()}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${record.syncDuration.inMilliseconds}ms',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// AnimatedBuilder helper since ListenableBuilder might be preferred in newer Flutter,
/// but keeping compatibility explicit.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

// Note: For ChangeNotifier, use ListenableBuilder instead of custom AnimatedBuilder in production.
// Re-exporting standard implementation wrapper for strict compliance:
class SyncAnimatedBuilder extends StatelessWidget {
  final Listenable listenable;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const SyncAnimatedBuilder({
    super.key,
    required this.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: builder,
      child: child,
    );
  }
}
