// CRSSS-001 — Stateless Cloud Run Cold Start Progress Overlay & Offline Sync.
// Integrates Material 3 progress bars to capture cold start delays seamlessly.
// Employs non-blocking offline synchronization structures.

import 'dart:async';
import 'package:flutter/material.dart';

/// Overlay widget capturing container cold start latencies during scale events.
class ColdStartProgressOverlay extends StatelessWidget {
  const ColdStartProgressOverlay({
    super.key,
    required this.isColdStarting,
    required this.child,
    this.statusLabel = 'Scaling compute resources...',
  });

  final bool isColdStarting;
  final Widget child;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Stack(
      children: [
        child,
        if (isColdStarting)
          Positioned.fill(
            child: Container(
              color: cs.scrim.withOpacity(0.4),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          statusLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Material 3 Linear progress indicator for scaling progress
                        LinearProgressIndicator(
                          color: cs.primary,
                          backgroundColor: cs.surfaceContainerHighest,
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          'This may take a moment while the container boots.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Offline synchronization queue structure mapping non-blocking updates.
class OfflineSyncQueue {
  OfflineSyncQueue._();

  static final OfflineSyncQueue instance = OfflineSyncQueue._();

  final List<Map<String, dynamic>> _pendingQueue = [];
  final _syncController = StreamController<bool>.broadcast();

  /// Exposes streaming status updates of background synchronization runs
  Stream<bool> get isSyncing => _syncController.stream;

  /// Enqueue offline actions for processing later.
  void enqueue(Map<String, dynamic> payload) {
    _pendingQueue.add({
      ...payload,
      'queued_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Triggers background queue synchronization. Runs asynchronously.
  Future<void> triggerSync(Future<bool> Function(Map<String, dynamic> payload) syncer) async {
    if (_pendingQueue.isEmpty) return;
    _syncController.add(true);

    final queueCopy = List<Map<String, dynamic>>.from(_pendingQueue);
    _pendingQueue.clear();

    for (final payload in queueCopy) {
      try {
        final success = await syncer(payload);
        if (!success) {
          _pendingQueue.add(payload); // Re-queue if server fails
        }
      } catch (e) {
        _pendingQueue.add(payload); // Re-queue on connection failures
      }
    }

    _syncController.add(false);
  }

  int get pendingCount => _pendingQueue.length;
}
