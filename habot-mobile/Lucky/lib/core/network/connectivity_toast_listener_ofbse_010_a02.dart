// OFBSE-010-A02 — Offline Toast Notification Standardization & Connectivity Listener Wrapper.
// Provides a standardized Material 3 SnackBar toast component for offline/online status changes with responsive scaling and local error interception.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data representing atomic-level definition fields required by the specification.
class Ofbse010A02MockData {
  static const String definitionName = 'OfflineToastNotificationStandardization';
  static const Map<String, dynamic> definitionParameters = {
    'fadeDurationMs': 300,
    'snackBarDurationSec': 4,
    'footerAlignment': true,
    'usePrimaryColorForOnline': true,
  };
  static const String definitionType = 'UI_COMPONENT';
  static const String validationStatus = 'Pass';
  static const String definitionId = 'OFBSE-010-A02-DEF-001';
}

/// Enum representing the current network connectivity state.
enum NetworkState { online, offline, connecting }

/// A wrapper that listens to network connectivity changes and displays
/// non-disruptive, foot-level Material 3 SnackBars.
class ConnectivityListenerWrapper extends StatefulWidget {
  final Widget child;
  final ValueChanged<NetworkState>? onStateChanged;

  const ConnectivityListenerWrapper({
    super.key,
    required this.child,
    this.onStateChanged,
  });

  @override
  State<ConnectivityListenerWrapper> createState() => _ConnectivityListenerWrapperState();
}

class _ConnectivityListenerWrapperState extends State<ConnectivityListenerWrapper> {
  NetworkState _currentState = NetworkState.online;
  Timer? _mockConnectionTimer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startMockConnectivityListener();
  }

  @override
  void dispose() {
    _mockConnectionTimer?.cancel();
    super.dispose();
  }

  /// Simulates edge mobile transport drops for demonstration and testing.
  void _startMockConnectivityListener() {
    // In production, replace this mock timer with actual connectivity_plus or similar listener.
    _mockConnectionTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted) return;
      
      // Local error wrappers intercept transport faults natively
      try {
        final nextIsOffline = timer.tick % 3 == 0; 
        final newState = nextIsOffline ? NetworkState.offline : NetworkState.online;
        
        if (newState != _currentState) {
          setState(() {
            _currentState = newState;
            // State-lock mechanism preventing submission while unbalanced/offline
            if (_currentState == NetworkState.offline) {
              _isSubmitting = false;
            }
          });
          widget.onStateChanged?.call(_currentState);
          _showConnectivityToast(newState);
        }
      } catch (e) {
        // Poka-Yoke: present clean notifications instead of code drops
        _showErrorToast('Failed to process network state.');
      }
    });
  }

  void _showConnectivityToast(NetworkState state) {
    if (!mounted) return;

    final theme = Theme.of(context);
    final isOnline = state == NetworkState.online;
    final screenWidth = MediaQuery.sizeOf(context).width;
    
    // Mobile-First: Scale inner element boundaries relative to viewport widths
    final horizontalPadding = screenWidth * 0.04;
    final fontSize = screenWidth < 360 ? 12.0 : 14.0;

    // Match ongoing processing steps precisely to high-visibility primary system color variables
    final backgroundColor = isOnline 
        ? theme.colorScheme.primaryContainer 
        : theme.colorScheme.errorContainer;
    final foregroundColor = isOnline 
        ? theme.colorScheme.onPrimaryContainer 
        : theme.colorScheme.onErrorContainer;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              color: foregroundColor,
              size: 20.0,
            ),
            SizedBox(width: horizontalPadding / 2),
            Expanded(
              child: Text(
                isOnline ? 'Back online' : 'No internet connection',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Collapse lengthy text indicators down to simple minimalist progress dots on small device screens
            if (!isOnline && screenWidth < 400)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: CircleAvatar(
                      radius: 2.5,
                      backgroundColor: foregroundColor.withOpacity(0.7),
                    ),
                  )),
                ),
              ),
          ],
        ),
        backgroundColor: backgroundColor,
        // Enforce standard vertical container profiles to keep baseline visual tracking paths predictable
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16.0,
          left: horizontalPadding,
          right: horizontalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        duration: Duration(
          seconds: Ofbse010A02MockData.definitionParameters['snackBarDurationSec'] as int,
        ),
        animation: CurvedAnimation(
          parent: AnimationController(
            vsync: this,
            duration: Duration(
              milliseconds: Ofbse010A02MockData.definitionParameters['fadeDurationMs'] as int,
            ),
          ),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  void _showErrorToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Validates if an action can proceed based on current connection state.
  /// Implements the state-lock mechanism preventing submission while unbalanced.
  bool validateSubmissionReady() {
    if (_currentState == NetworkState.offline) {
      _showErrorToast('Cannot submit while offline. Please restore connection.');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Standalone UI Component for manual invocation if needed outside the wrapper.
class OfflineToastComponent {
  static void show(BuildContext context, {required bool isOnline}) {
    final state = isOnline ? NetworkState.online : NetworkState.offline;
    final wrapperState = context.findAncestorStateOfType<_ConnectivityListenerWrapperState>();
    wrapperState?._showConnectivityToast(state);
  }
}