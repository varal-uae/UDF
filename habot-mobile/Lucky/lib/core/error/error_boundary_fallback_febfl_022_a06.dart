// FEBFL-022-A06 — Error Boundary Fallback Component Implementation.
// Isolates localized component failures, sanitizes backend variables into plain language, tracks retry thresholds with human exception escalation, and renders Material 3 alert cards.

import 'package:flutter/material.dart';

/// Telemetry payload emitted when a component fault occurs or changes state.
class ErrorBoundaryTelemetry {
  const ErrorBoundaryTelemetry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.consecutiveFailures,
    this.sanitizedMessage,
  });

  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final int consecutiveFailures;
  final String? sanitizedMessage;

  Map<String, dynamic> toJson() => {
        'step_execution_id': stepExecutionId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
        'consecutive_failures': consecutiveFailures,
        'sanitized_message': sanitizedMessage,
      };
}

/// A resilient error boundary wrapper that prevents localized widget errors
/// from breaking workspace layouts, enforces error sanitization (Poka-Yoke),
/// and locks into a human exception queue after 3 consecutive failures.
class ErrorBoundaryFallback extends StatefulWidget {
  const ErrorBoundaryFallback({
    super.key,
    required this.child,
    this.userId = 'anonymous_user',
    this.stepExecutionId = 'FEBFL-022-A06-EXEC',
    this.customErrorMessage,
    this.onRetry,
    this.onEscalateToHumanQueue,
    this.onTelemetryLogged,
  });

  final Widget child;
  final String userId;
  final String stepExecutionId;
  final String? customErrorMessage;
  final Future<void> Function()? onRetry;
  final void Function(ErrorBoundaryTelemetry telemetry)? onEscalateToHumanQueue;
  final void Function(ErrorBoundaryTelemetry telemetry)? onTelemetryLogged;

  @override
  State<ErrorBoundaryFallback> createState() => _ErrorBoundaryFallbackState();
}

class _ErrorBoundaryFallbackState extends State<ErrorBoundaryFallback> {
  bool _hasError = false;
  int _consecutiveFailures = 0;
  bool _isLocked = false;
  bool _isRetrying = false;
  String _displayMessage = "Values don't match. Re-verify input.";

  static const int _maxRetriesAllowed = 3;

  @override
  void initState() {
    super.initState();
  }

  /// Sanitizes raw runtime errors into safe, plain-language guidance.
  String _sanitizeError(dynamic error) {
    if (widget.customErrorMessage != null &&
        widget.customErrorMessage!.trim().isNotEmpty) {
      return widget.customErrorMessage!;
    }

    final raw = error?.toString() ?? '';
    if (raw.toLowerCase().contains('format') ||
        raw.toLowerCase().contains('parse') ||
        raw.toLowerCase().contains('mismatch')) {
      return "Values don't match. Re-verify input.";
    }
    if (raw.toLowerCase().contains('network') ||
        raw.toLowerCase().contains('socket') ||
        raw.toLowerCase().contains('timeout')) {
      return 'Connection interrupted. Please re-verify input and try again.';
    }
    return "An unexpected issue occurred. Please re-verify input.";
  }

  void _recordTelemetry({
    required String status,
    required String outcome,
  }) {
    final telemetry = ErrorBoundaryTelemetry(
      stepExecutionId: widget.stepExecutionId,
      executionStatus: status,
      executionTimestamp: DateTime.now().toUtc(),
      stepOutcome: outcome,
      userId: widget.userId,
      consecutiveFailures: _consecutiveFailures,
      sanitizedMessage: _displayMessage,
    );

    widget.onTelemetryLogged?.call(telemetry);

    if (_isLocked) {
      widget.onEscalateToHumanQueue?.call(telemetry);
    }
  }

  void captureError(dynamic error, StackTrace? stackTrace) {
    setState(() {
      _hasError = true;
      _consecutiveFailures += 1;
      _displayMessage = _sanitizeError(error);

      if (_consecutiveFailures >= _maxRetriesAllowed) {
        _isLocked = true;
      }
    });

    _recordTelemetry(
      status: _isLocked ? 'Locked' : 'Failed',
      outcome: _isLocked ? 'EscalatedToHumanQueue' : 'CaughtAndRenderedFallback',
    );
  }

  Future<void> _handleRetry() async {
    if (_isLocked || _isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      if (widget.onRetry != null) {
        await widget.onRetry!();
      }
      if (mounted) {
        setState(() {
          _hasError = false;
          _consecutiveFailures = 0;
          _isRetrying = false;
        });
        _recordTelemetry(
          status: 'Recovered',
          outcome: 'Pass',
        );
      }
    } catch (e, stack) {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
        captureError(e, stack);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildMaterialFallbackCard(context);
    }

    return _CatchingBoundary(
      onError: captureError,
      child: widget.child,
    );
  }

  Widget _buildMaterialFallbackCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isLockedState = _isLocked;
    final cardBorderColor = isLockedState
        ? colorScheme.error
        : colorScheme.errorContainer.withValues(alpha: 0.8);
    final cardBgColor = isLockedState
        ? colorScheme.errorContainer.withValues(alpha: 0.15)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);

    return Semantics(
      container: true,
      alert: true,
      label: isLockedState
          ? 'Component pathway locked for review'
          : 'Component input warning',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: cardBorderColor,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isLockedState
                      ? Icons.lock_outline_rounded
                      : Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  size: 24.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLockedState
                            ? 'Pathway Locked for Human Review'
                            : 'Unable to Load Component',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        isLockedState
                            ? 'This section failed 3 consecutive times. Details have been safely routed to the human exception queue.'
                            : _displayMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isLockedState) ...[
                  FilledButton.tonalIcon(
                    onPressed: _isRetrying ? null : _handleRetry,
                    icon: _isRetrying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(_isRetrying ? 'Checking...' : 'Re-verify Input'),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.shield_outlined, size: 18),
                    label: const Text('Pending Review'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal error catching widget to trap render-phase exceptions.
class _CatchingBoundary extends StatelessWidget {
  const _CatchingBoundary({
    required this.child,
    required this.onError,
  });

  final Widget child;
  final void Function(dynamic error, StackTrace? stack) onError;

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onError(details.exception, details.stack);
      });
      return const SizedBox.shrink();
    };
    return child;
  }
}
