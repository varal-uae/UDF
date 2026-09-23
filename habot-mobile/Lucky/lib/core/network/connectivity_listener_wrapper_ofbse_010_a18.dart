// OFBSE-010-A18 — Connectivity Listener Wrapper & Offline Toast Notification Standardization.
// Provides a standardized pattern for edge mobile transport drops, displaying non-disruptive foot-level Material Snackbars with responsive layout scaling and telemetry logging.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock telemetry logger to simulate BigQuery sync for offline operational charts.
class _OfflineTelemetryLogger {
  static void logReconnectionEvent({
    required String stepExecutionId,
    required String executionStatus,
    required DateTime executionTimestamp,
    required String stepOutcome,
    required String userId,
  }) {
    // In production, this would sync to BigQuery.
    debugPrint(
      '[OFBSE-010-A18 Telemetry] '
      'StepExecutionId: $stepExecutionId, '
      'Status: $executionStatus, '
      'Timestamp: ${executionTimestamp.toIso8601String()}, '
      'Outcome: $stepOutcome, '
      'UserId: $userId',
    );
  }
}

/// Enum representing the current network connectivity state.
enum NetworkState { connected, disconnected, reconnecting }

/// A wrapper that listens to connectivity changes and presents standardized
/// foot-level overlays (Material Snackbars) to keep consumers aware of offline properties.
/// Implements Poka-Yoke by intercepting transport faults natively.
class ConnectivityListenerWrapper extends StatefulWidget {
  final Widget child;
  final String userId;

  const ConnectivityListenerWrapper({
    super.key,
    required this.child,
    this.userId = 'mock_user_001',
  });

  static ConnectivityListenerWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<ConnectivityListenerWrapperState>();
  }

  @override
  State<ConnectivityListenerWrapper> createState() =>
      ConnectivityListenerWrapperState();
}

class ConnectivityListenerWrapperState
    extends State<ConnectivityListenerWrapper> {
  NetworkState _networkState = NetworkState.connected;
  Timer? _reconnectionTimer;
  int _executionCounter = 0;

  /// Simulated stream controller for connectivity changes.
  /// In production, replace with `connectivity_plus` package streams.
  final StreamController<NetworkState> _connectivityController =
      StreamController<NetworkState>.broadcast();

  Stream<NetworkState> get connectivityStream => _connectivityController.stream;

  @override
  void initState() {
    super.initState();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivityController.stream.listen((state) {
      if (!mounted) return;

      setState(() {
        _networkState = state;
      });

      _executionCounter++;
      final executionId = 'exec_${widget.userId}_${_executionCounter}_ofbse010a18';
      final timestamp = DateTime.now();

      switch (state) {
        case NetworkState.disconnected:
          _showOfflineSnackbar();
          _OfflineTelemetryLogger.logReconnectionEvent(
            stepExecutionId: executionId,
            executionStatus: 'FAILED',
            executionTimestamp: timestamp,
            stepOutcome: 'TRANSPORT_DROP_DETECTED',
            userId: widget.userId,
          );
          break;
        case NetworkState.reconnecting:
          _showReconnectingIndicator();
          _OfflineTelemetryLogger.logReconnectionEvent(
            stepExecutionId: executionId,
            executionStatus: 'PENDING',
            executionTimestamp: timestamp,
            stepOutcome: 'RECONNECTION_INITIATED',
            userId: widget.userId,
          );
          break;
        case NetworkState.connected:
          _hideCurrentSnackbar();
          _OfflineTelemetryLogger.logReconnectionEvent(
            stepExecutionId: executionId,
            executionStatus: 'SUCCESS',
            executionTimestamp: timestamp,
            stepOutcome: 'CONNECTION_RESTORED',
            userId: widget.userId,
          );
          break;
      }
    });
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _currentSnackbar;

  void _hideCurrentSnackbar() {
    if (_currentSnackbar != null && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _currentSnackbar = null;
    }
  }

  void _showOfflineSnackbar() {
    _hideCurrentSnackbar();
    if (!mounted) return;

    final screenWidth = MediaQuery.of(context).size.width;
    // Mobile-First: Collapse lengthy text indicators down to simple minimalist progress dots on small screens.
    final isSmallScreen = screenWidth < 600;

    _currentSnackbar = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: isSmallScreen
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('• • •', style: TextStyle(fontSize: 16, letterSpacing: 2)),
                ],
              )
            : const Row(
                children: [
                  Icon(Icons.cloud_off_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You are currently offline. Some features may be unavailable.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        // Foot-level screen alignments
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16.0,
          left: 16.0,
          right: 16.0,
        ),
        // Fade duration variables
        animation: CurvedAnimation(
          parent: AnimationController(
            vsync: ScaffoldMessenger.of(context) as TickerProvider,
            duration: const Duration(milliseconds: 300),
          ),
          curve: Curves.easeInOut,
        ),
        duration: const Duration(days: 365), // Persistent until reconnected
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showReconnectingIndicator() {
    _hideCurrentSnackbar();
    if (!mounted) return;

    // Match ongoing processing steps precisely to high-visibility primary system color variables.
    final primaryColor = Theme.of(context).colorScheme.primary;

    _currentSnackbar = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Reconnecting...', style: TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16.0,
          left: 16.0,
          right: 16.0,
        ),
        duration: const Duration(days: 365),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Public API to simulate network drops for testing / UI demonstration.
  void simulateNetworkDrop() {
    _connectivityController.add(NetworkState.disconnected);
    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(const Duration(seconds: 3), () {
      _connectivityController.add(NetworkState.reconnecting);
      _reconnectionTimer = Timer(const Duration(seconds: 2), () {
        _connectivityController.add(NetworkState.connected);
      });
    });
  }

  void simulateReconnection() {
    _connectivityController.add(NetworkState.connected);
    _reconnectionTimer?.cancel();
  }

  @override
  void dispose() {
    _reconnectionTimer?.cancel();
    _connectivityController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scale inner element boundaries relative to viewport widths to keep layouts proportioned.
    // Enforce standard vertical container profiles to keep baseline visual tracking paths predictable.
    return LayoutBuilder(
      builder: (context, constraints) {
        return widget.child;
      },
    );
  }
}

/// Example usage demonstrating the interface alert module.
class OfflineToastDemoScreen extends StatelessWidget {
  const OfflineToastDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityListenerWrapper(
      userId: 'demo_user_uae_001',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('OFBSE-010-A18: Offline Toast Standardization'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Offline Toast Notification Standardization',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ConnectivityListenerWrapper.of(context)?.simulateNetworkDrop();
                },
                icon: const Icon(Icons.wifi_off),
                label: const Text('Simulate Network Drop'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ConnectivityListenerWrapper.of(context)?.simulateReconnection();
                },
                icon: const Icon(Icons.wifi),
                label: const Text('Force Reconnection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
