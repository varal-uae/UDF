// REF-061-A07 — NetworkStatusShield global connectivity monitor and UI overlay.
// Tracks network state, displays a non-blocking Material 3 banner, grays out interactive elements, queues telemetry locally, and auto-reconnects.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

/// Global state variable to track the current network status.
enum NetworkState { connected, disconnected }

class NetworkStatusShield extends ChangeNotifier {
  NetworkStatusShield._();
  static final NetworkStatusShield instance = NetworkStatusShield._();

  NetworkState _state = NetworkState.connected;
  NetworkState get state => _state;
  bool get isConnected => _state == NetworkState.connected;

  final List<Map<String, dynamic>> _telemetryQueue = [];
  Timer? _uptimeListenerLoop;

  void init() {
    _startUptimeListenerLoop();
  }

  void _startUptimeListenerLoop() {
    // Simulated uptime listener loop polling every 2 seconds (Optimal Target)
    _uptimeListenerLoop?.cancel();
    _uptimeListenerLoop = Timer.periodic(const Duration(seconds: 2), (_) {
      _simulateNetworkCheck();
    });
  }

  void _simulateNetworkCheck() {
    // In production, replace with connectivity_plus checks.
    // Mocking logic for demonstration of state sync latency targets.
  }

  /// Public method to manually update status or simulate drops
  void updateConnectivity(NetworkState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();

      if (newState == NetworkState.connected) {
        _flushTelemetryQueue();
      }
    }
  }

  /// Mistake-Proofing (Poka-Yoke): Intercept and block clicks while disconnected.
  bool interceptAction(Map<String, dynamic> actionPayload) {
    if (!isConnected) {
      queueTelemetry(actionPayload);
      return false; // Blocked
    }
    return true; // Allowed
  }

  void queueTelemetry(Map<String, dynamic> payload) {
    final record = {
      'creationDate': DateTime.now().toIso8601String(),
      'createdBy': 'System',
      'creationMethod': 'AutoQueue',
      'initialConfiguration': jsonEncode(payload),
      'objectId': UniqueKey().toString(),
      'actionTimestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _telemetryQueue.add(record);
  }

  void _flushTelemetryQueue() {
    if (_telemetryQueue.isEmpty) return;
    // Simulate background upload resuming automatically
    debugPrint('[NetworkStatusShield] Flushing ${_telemetryQueue.length} queued requests to cloud servers.');
    _telemetryQueue.clear();
  }

  @override
  void dispose() {
    _uptimeListenerLoop?.cancel();
    super.dispose();
  }
}

/// A clean notification banner that slides down from the header.
/// Never interrupts work with jarring full-screen error popups.
class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NetworkStatusShield.instance,
      builder: (context, child) {
        final isDisconnected = !NetworkStatusShield.instance.isConnected;
        
        return AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: isDisconnected ? Offset.zero : const Offset(0, -1.5),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isDisconnected ? 1.0 : 0.0,
            child: Material(
              elevation: 4.0,
              color: Theme.of(context).colorScheme.errorContainer,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        size: 20.0,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          'No connection. Your data is safe.',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Manual Retry Connection Now link inside desktop/mobile status blocks
                      TextButton(
                        onPressed: () {
                          NetworkStatusShield.instance.updateConnectivity(NetworkState.connected);
                        },
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
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
}

/// Wrapper widget that transitions online buttons to locked gray styles when disconnected.
/// Explicit layout bounds prevent unexpected shift bugs during rendering.
class ShieldedAction extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Map<String, dynamic>? telemetryPayload;

  const ShieldedAction({
    super.key,
    required this.onPressed,
    required this.child,
    this.telemetryPayload,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NetworkStatusShield.instance,
      builder: (context, _) {
        final isConnected = NetworkStatusShield.instance.isConnected;
        
        return AbsorbPointer(
          absorbing: !isConnected,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isConnected ? 1.0 : 0.4, // Locked gray style transition
            child: GestureDetector(
              onTap: () {
                if (isConnected) {
                  onPressed?.call();
                } else if (telemetryPayload != null) {
                  NetworkStatusShield.instance.interceptAction(telemetryPayload!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Action queued. Will sync when online.'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Helper class to provide AnimatedBuilder functionality without external packages
/// mimicking standard Flutter ListenableBuilder patterns.
class AnimatedBuilder extends StatelessWidget {
  final Listenable animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilderInternal(
      listenable: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilderInternal extends StatefulWidget {
  final Listenable listenable;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilderInternal({
    super.key,
    required this.listenable,
    required this.builder,
    this.child,
  });

  @override
  State<AnimatedBuilderInternal> createState() => _AnimatedBuilderInternalState();
}

class _AnimatedBuilderInternalState extends State<AnimatedBuilderInternal> {
  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_onUpdate);
  }

  @override
  void didUpdateWidget(covariant AnimatedBuilderInternal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onUpdate);
      widget.listenable.addListener(_onUpdate);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.child);
  }
}

/// Example integration demonstrating the Mobile-First & Responsive UX Implementation.
/// Base layouts on verified Material Design patterns with fixed spacing properties.
class NetworkResilienceDemoScreen extends StatelessWidget {
  const NetworkResilienceDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize mock shield
    NetworkStatusShield.instance.init();

    return Scaffold(
      appBar: AppBar(
        title: const Text('UDF Network Shield'),
      ),
      body: Stack(
        children: [
          // Main Content Area
          Padding(
            padding: const EdgeInsets.all(24.0), // Fixed style values lock element spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Active Data Table',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AnimatedBuilder(
                      animation: NetworkStatusShield.instance,
                      builder: (context, _) {
                        final isConnected = NetworkStatusShield.instance.isConnected;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Live Telemetry Feed'),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: isConnected ? Colors.green.shade100 : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                isConnected ? 'LIVE' : 'FROZEN',
                                style: TextStyle(
                                  color: isConnected ? Colors.green.shade800 : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                ShieldedAction(
                  telemetryPayload: {'action': 'submit_form', 'formId': 'UDF-001'},
                  onPressed: () {
                    debugPrint('Form submitted successfully to server.');
                  },
                  child: FilledButton.icon(
                    onPressed: () {}, // Handled by ShieldedAction wrapper
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Submit Data'),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Toggle simulation for testing
                    final next = NetworkStatusShield.instance.isConnected 
                        ? NetworkState.disconnected 
                        : NetworkState.connected;
                    NetworkStatusShield.instance.updateConnectivity(next);
                  },
                  child: const Text('Toggle Network Status (Simulate Drop/Reconnect)'),
                ),
              ],
            ),
          ),
          
          // Pinned status alert row slipping below mobile headers
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NetworkStatusBanner(),
          ),
        ],
      ),
    );
  }
}
