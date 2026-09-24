// REF-287-A06 — Fail-Closed Layout Guard for Sensitive UI Views.
// Wraps transactional workflows inside automated fallback data safety modules, blocking interaction during network drops or validation failures.

import 'package:flutter/material.dart';

/// Enum representing the current safety state of the layout guard.
enum SafetyGateState {
  secure,
  networkUnstable,
  validationFailed,
  processingError,
}

/// Mock telemetry model to satisfy atomic-level data collection requirements.
class StepExecutionTelemetry {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;
  final DateTime actionTimestamp;
  final String sessionId;

  const StepExecutionTelemetry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'stepExecutionId': stepExecutionId,
        'executionStatus': executionStatus,
        'executionTimestamp': executionTimestamp.toIso8601String(),
        'stepOutcome': stepOutcome,
        'userId': userId,
        'completionStatus': completionStatus,
        'actionTimestamp': actionTimestamp.toIso8601String(),
        'sessionId': sessionId,
      };
}

/// A pluggable layout guard that locks entry functions down safely if processing issues arise.
/// Implements a fail-closed operational baseline to protect data track pipelines.
class FailClosedLayoutGuard extends StatefulWidget {
  /// The sensitive UI view to protect.
  final Widget child;

  /// The current safety gate state determining if interaction is allowed.
  final SafetyGateState gateState;

  /// Callback triggered when the user attempts a safe retry operation.
  final VoidCallback? onRetry;

  /// Optional callback for logging telemetry data.
  final void Function(StepExecutionTelemetry)? onTelemetryLogged;

  const FailClosedLayoutGuard({
    super.key,
    required this.child,
    required this.gateState,
    this.onRetry,
    this.onTelemetryLogged,
  });

  @override
  State<FailClosedLayoutGuard> createState() => _FailClosedLayoutGuardState();
}

class _FailClosedLayoutGuardState extends State<FailClosedLayoutGuard>
    with SingleTickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    );

    if (widget.gateState != SafetyGateState.secure) {
      _overlayController.forward();
      _logTelemetry('BLOCKED', widget.gateState.name);
    }
  }

  @override
  void didUpdateWidget(covariant FailClosedLayoutGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gateState == SafetyGateState.secure) {
      _overlayController.reverse();
    } else if (oldWidget.gateState == SafetyGateState.secure) {
      _overlayController.forward();
      _logTelemetry('BLOCKED', widget.gateState.name);
    }
  }

  void _logTelemetry(String status, String outcome) {
    final telemetry = StepExecutionTelemetry(
      stepExecutionId: 'REF-287-A06-EXEC-${DateTime.now().millisecondsSinceEpoch}',
      executionStatus: status,
      executionTimestamp: DateTime.now(),
      stepOutcome: outcome,
      userId: 'MOCK_USER_001',
      completionStatus: status == 'BLOCKED' ? 'Fail' : 'Pass',
      actionTimestamp: DateTime.now(),
      sessionId: 'MOCK_SESSION_001',
    );
    widget.onTelemetryLogged?.call(telemetry);
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  String _getWarningMessage() {
    switch (widget.gateState) {
      case SafetyGateState.networkUnstable:
        return 'Connection unstable. Form controls are locked to prevent corrupted data submission.';
      case SafetyGateState.validationFailed:
        return 'Data validation failed. Please verify your inputs before retrying.';
      case SafetyGateState.processingError:
        return 'A processing error occurred. Interaction is temporarily disabled.';
      case SafetyGateState.secure:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // The protected child view
        IgnorePointer(
          ignoring: widget.gateState != SafetyGateState.secure,
          child: AnimatedOpacity(
            opacity: widget.gateState == SafetyGateState.secure ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 300),
            child: widget.child,
          ),
        ),

        // Native verification prompt overlay screen layer
        FadeTransition(
          opacity: _fadeAnimation,
          child: Visibility(
            visible: widget.gateState != SafetyGateState.secure,
            child: Container(
              color: theme.colorScheme.scrim.withOpacity(0.6),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 8.0,
                color: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 48.0,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Safety Gate Active',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        _getWarningMessage(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24.0),
                      if (widget.onRetry != null)
                        FilledButton.icon(
                          onPressed: () {
                            _logTelemetry('RETRY_ATTEMPT', 'USER_INITIATED');
                            widget.onRetry!();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Safely'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
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

/// A convenience wrapper to apply the fail-closed guard around any sensitive route or widget.
class SafetyGateBoundary extends StatelessWidget {
  final Widget child;
  final bool isConnected;
  final bool isValidated;
  final VoidCallback? onRetry;

  const SafetyGateBoundary({
    super.key,
    required this.child,
    required this.isConnected,
    required this.isValidated,
    this.onRetry,
  });

  SafetyGateState _evaluateState() {
    if (!isConnected) return SafetyGateState.networkUnstable;
    if (!isValidated) return SafetyGateState.validationFailed;
    return SafetyGateState.secure;
  }

  @override
  Widget build(BuildContext context) {
    return FailClosedLayoutGuard(
      gateState: _evaluateState(),
      onRetry: onRetry,
      child: child,
    );
  }
}