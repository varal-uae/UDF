// FEBFL-022-A03 — Error Boundary Fallback Components Implementation.
// Provides an isolated error boundary wrapper that sanitizes raw stack traces, displays standard alert fallback cards, and escalates to an exception queue after three consecutive retry failures.

import 'dart:developer' as developer;
import 'package:flutter/material.dart';

/// Callback signature for dispatching captured exceptions to cloud telemetry / logging buckets.
typedef ErrorTelemetryLogger = void Function({
  required Object error,
  required StackTrace stackTrace,
  required int consecutiveFailures,
  required bool isLocked,
});

/// A secure error boundary wrapper designed to isolate localized component crashes
/// and replace raw error readouts with a clean, branded Material 3 fallback card.
class ErrorBoundaryFallback extends StatefulWidget {
  const ErrorBoundaryFallback({
    super.key,
    required this.child,
    this.fallbackTitle,
    this.fallbackMessage,
    this.onRetry,
    this.onLockedPathway,
    this.onTelemetryLogged,
    this.maxConsecutiveRetries = 3,
    this.isInline = true,
  });

  /// The primary UI widget to wrap and isolate.
  final Widget child;

  /// Optional custom title for the fallback notification card.
  final String? fallbackTitle;

  /// Optional safe instruction fallback message.
  final String? fallbackMessage;

  /// Optional custom callback invoked when the user clicks 'Re-verify Input'.
  final Future<void> Function()? onRetry;

  /// Callback invoked when consecutive retries reach [maxConsecutiveRetries] and the pathway locks.
  final VoidCallback? onLockedPathway;

  /// Optional telemetry dispatcher for cloud logging (GCP / BigQuery alignment).
  final ErrorTelemetryLogger? onTelemetryLogged;

  /// Maximum manual retries before the pathway locks into the human exception queue.
  final int maxConsecutiveRetries;

  /// If true, renders a compact card suitable for grid/form slots; if false, renders a full view.
  final bool isInline;

  @override
  State<ErrorBoundaryFallback> createState() => _ErrorBoundaryFallbackState();
}

class _ErrorBoundaryFallbackState extends State<ErrorBoundaryFallback> {
  bool _hasError = false;
  int _consecutiveFailures = 0;
  bool _isRetrying = false;
  String _safeDisplayMessage = 'Values do not match. Re-verify input.';

  @override
  void initState() {
    super.initState();
  }

  /// Sanitizes raw error details according to mistake-proofing (Poka-Yoke) specs.
  /// Hides raw backend variable names, database errors, and stack traces.
  String _sanitizeErrorMessage(Object error) {
    final errString = error.toString().toLowerCase();
    if (errString.contains('null') || errString.contains('type') || errString.contains('range')) {
      return 'Values do not match. Re-verify input.';
    } else if (errString.contains('timeout') || errString.contains('socket') || errString.contains('connection')) {
      return 'Connection timed out. Please re-verify network and input.';
    } else if (errString.contains('auth') || errString.contains('permission')) {
      return 'Authentication verification failed. Please re-verify credentials.';
    }
    return widget.fallbackMessage ?? 'Values do not match. Re-verify input.';
  }

  void _handleComponentError(Object error, StackTrace stackTrace) {
    final newFailureCount = _consecutiveFailures + 1;
    final isLocked = newFailureCount >= widget.maxConsecutiveRetries;

    developer.log(
      'ErrorBoundaryFallback caught component error (Failure: $newFailureCount)',
      name: 'ErrorBoundaryFallback',
      error: error,
      stackTrace: stackTrace,
    );

    widget.onTelemetryLogged?.call(
      error: error,
      stackTrace: stackTrace,
      consecutiveFailures: newFailureCount,
      isLocked: isLocked,
    );

    if (isLocked) {
      widget.onLockedPathway?.call();
    }

    setState(() {
      _hasError = true;
      _consecutiveFailures = newFailureCount;
      _safeDisplayMessage = _sanitizeErrorMessage(error);
    });
  }

  Future<void> _handleRetry() async {
    if (_consecutiveFailures >= widget.maxConsecutiveRetries) {
      return;
    }

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
          _isRetrying = false;
        });
      }
    } catch (e, st) {
      if (mounted) {
        _handleComponentError(e, st);
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasError) {
      // Use custom Flutter error boundary interception for child subtree
      return _CatchErrorWidget(
        onError: _handleComponentError,
        child: widget.child,
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLocked = _consecutiveFailures >= widget.maxConsecutiveRetries;

    final cardBackground = isLocked
        ? colorScheme.errorContainer.withValues(alpha: 0.85)
        : colorScheme.surfaceContainerHighest;
    final borderColor = isLocked ? colorScheme.error : colorScheme.outlineVariant;
    final iconColor = isLocked ? colorScheme.error : colorScheme.error;

    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isLocked ? Icons.lock_outline_rounded : Icons.warning_amber_rounded,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.fallbackTitle ?? (isLocked ? 'Pathway Locked' : 'Input Verification Warning'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isLocked
                ? 'Component failed $widget.maxConsecutiveRetries consecutive times. This action is locked and routed to the human exception queue.'
                : _safeDisplayMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isLocked) ...[
                FilledButton.tonalIcon(
                  onPressed: _isRetrying ? null : _handleRetry,
                  icon: _isRetrying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Re-verify Input'),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('Escalated to Support'),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    final fallbackCard = Card(
      elevation: 0,
      color: cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: borderColor, width: 1.0),
      ),
      child: content,
    );

    if (widget.isInline) {
      return fallbackCard;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: fallbackCard,
      ),
    );
  }
}

/// Internal helper widget to safely catch layout or build-phase exceptions.
class _CatchErrorWidget extends StatelessWidget {
  const _CatchErrorWidget({
    required this.child,
    required this.onError,
  });

  final Widget child;
  final void Function(Object error, StackTrace stackTrace) onError;

  @override
  Widget build(BuildContext context) {
    return _ErrorBoundaryElementWrapper(
      onError: onError,
      child: child,
    );
  }
}

class _ErrorBoundaryElementWrapper extends SingleChildRenderObjectWidget {
  const _ErrorBoundaryElementWrapper({
    required super.child,
    required this.onError,
  });

  final void Function(Object error, StackTrace stackTrace) onError;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderErrorBoundary(onError);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderErrorBoundary renderObject) {
    renderObject.onError = onError;
  }
}

class _RenderErrorBoundary extends RenderProxyBox {
  _RenderErrorBoundary(this.onError);

  void Function(Object error, StackTrace stackTrace) onError;

  @override
  void paint(PaintingContext context, Offset offset) {
    try {
      super.paint(context, offset);
    } catch (e, st) {
      onError(e, st);
    }
  }

  @override
  void performLayout() {
    try {
      super.performLayout();
    } catch (e, st) {
      onError(e, st);
    }
  }
}
