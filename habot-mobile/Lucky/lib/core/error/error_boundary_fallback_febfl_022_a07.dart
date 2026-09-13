// FEBFL-022-A07 — Error Boundary Fallback Component Implementation.
// Provides an isolated layout wrapper and fallback notification card with retry actions,
// raw backend/stack sanitization, and consecutive failure threshold escalation routing.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Telemetry payload dispatched when an isolated boundary captures an error
/// or when consecutive retries trigger the human exception escalation path.
@immutable
class ErrorBoundaryTelemetryData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String? userId;
  final String? sessionId;
  final String safeMessage;
  final int retryCount;
  final bool isEscalated;

  const ErrorBoundaryTelemetryData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    this.userId,
    this.sessionId,
    required this.safeMessage,
    required this.retryCount,
    required this.isEscalated,
  });

  Map<String, dynamic> toMap() => {
        'stepExecutionId': stepExecutionId,
        'executionStatus': executionStatus,
        'executionTimestamp': executionTimestamp.toIso8601String(),
        'stepOutcome': stepOutcome,
        'userId': userId ?? 'anonymous',
        'sessionId': sessionId ?? 'system_session',
        'safeMessage': safeMessage,
        'retryCount': retryCount,
        'isEscalated': isEscalated,
      };
}

/// Controller to track consecutive errors and trigger retry actions.
class ErrorBoundaryController extends ChangeNotifier {
  final int maxConsecutiveRetries;
  final ValueChanged<ErrorBoundaryTelemetryData>? onTelemetryLogged;
  final ValueChanged<ErrorBoundaryTelemetryData>? onEscalatedToHumanQueue;

  int _failureCount = 0;
  bool _isLockedOut = false;
  String? _sanitizedErrorMessage;
  Object? _rawError;
  StackTrace? _rawStackTrace;

  ErrorBoundaryController({
    this.maxConsecutiveRetries = 3,
    this.onTelemetryLogged,
    this.onEscalatedToHumanQueue,
  });

  int get failureCount => _failureCount;
  bool get isLockedOut => _isLockedOut;
  String? get sanitizedErrorMessage => _sanitizedErrorMessage;
  bool get hasError => _rawError != null || _sanitizedErrorMessage != null;

  void recordError(Object error, [StackTrace? stackTrace]) {
    _failureCount++;
    _rawError = error;
    _rawStackTrace = stackTrace;
    _sanitizedErrorMessage = _sanitizeError(error);

    if (_failureCount >= maxConsecutiveRetries) {
      _isLockedOut = true;
    }

    final telemetry = _buildTelemetry(outcome: _isLockedOut ? 'Locked' : 'Failed');
    onTelemetryLogged?.call(telemetry);

    if (_isLockedOut) {
      onEscalatedToHumanQueue?.call(telemetry);
    }

    notifyListeners();
  }

  void reset() {
    _failureCount = 0;
    _isLockedOut = false;
    _sanitizedErrorMessage = null;
    _rawError = null;
    _rawStackTrace = null;
    notifyListeners();
  }

  /// Mistake-Proofing (Poka-Yoke): Strips sensitive database columns, stack traces,
  /// server variables, or technical exception traces from the front-facing UI.
  static String _sanitizeError(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('mismatch') || text.contains('validation') || text.contains('format')) {
      return "Values don't match. Re-verify input.";
    }
    if (text.contains('timeout') || text.contains('socket') || text.contains('network') || text.contains('connection')) {
      return 'Network communication interrupted. Please re-verify input and try again.';
    }
    if (text.contains('unauthorized') || text.contains('forbidden') || text.contains('auth')) {
      return 'Verification credential expired. Re-authenticate or re-verify input.';
    }
    return 'Unable to process this section. Re-verify input or request assistance.';
  }

  ErrorBoundaryTelemetryData _buildTelemetry({required String outcome}) {
    return ErrorBoundaryTelemetryData(
      stepExecutionId: 'FEBFL-022-A07-${DateTime.now().millisecondsSinceEpoch}',
      executionStatus: _isLockedOut ? 'ESCALATED' : 'CAUGHT',
      executionTimestamp: DateTime.now().toUtc(),
      stepOutcome: outcome,
      safeMessage: _sanitizedErrorMessage ?? 'An unexpected error occurred.',
      retryCount: _failureCount,
      isEscalated: _isLockedOut,
    );
  }
}

/// Reusable component error boundary that protects the workspace layout
/// by trapping widget construction errors or manual operational exceptions.
class ComponentErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, VoidCallback onRetry)? fallbackBuilder;
  final String? sectionTitle;
  final FutureOr<void> Function()? onRetryAction;
  final ValueChanged<ErrorBoundaryTelemetryData>? onTelemetryLogged;
  final ValueChanged<ErrorBoundaryTelemetryData>? onEscalation;
  final int maxRetries;

  const ComponentErrorBoundary({
    super.key,
    required this.child,
    this.fallbackBuilder,
    this.sectionTitle,
    this.onRetryAction,
    this.onTelemetryLogged,
    this.onEscalation,
    this.maxRetries = 3,
  });

  @override
  State<ComponentErrorBoundary> createState() => _ComponentErrorBoundaryState();
}

class _ComponentErrorBoundaryState extends State<ComponentErrorBoundary> {
  late final ErrorBoundaryController _controller;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _controller = ErrorBoundaryController(
      maxConsecutiveRetries: widget.maxRetries,
      onTelemetryLogged: widget.onTelemetryLogged,
      onEscalatedToHumanQueue: widget.onEscalation,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_controller.isLockedOut || _isRetrying) return;

    setState(() => _isRetrying = true);
    try {
      if (widget.onRetryAction != null) {
        await widget.onRetryAction!();
      }
      _controller.reset();
    } catch (e, stack) {
      _controller.recordError(e, stack);
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.hasError) {
          if (widget.fallbackBuilder != null) {
            return widget.fallbackBuilder!(context, _handleRetry);
          }
          return ErrorBoundaryFallbackCard(
            title: widget.sectionTitle ?? 'Component Notice',
            message: _controller.sanitizedErrorMessage ?? "Values don't match. Re-verify input.",
            isLocked: _controller.isLockedOut,
            isRetrying: _isRetrying,
            retryCount: _controller.failureCount,
            maxRetries: widget.maxRetries,
            onRetry: _handleRetry,
          );
        }

        return _WidgetErrorCatcher(
          onError: (error, stackTrace) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _controller.recordError(error, stackTrace);
              }
            });
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Low-level widget tree assertion/layout crash interceptor.
class _WidgetErrorCatcher extends StatelessWidget {
  final Widget child;
  final void Function(Object error, StackTrace? stackTrace) onError;

  const _WidgetErrorCatcher({
    required this.child,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        try {
          return child;
        } catch (error, stack) {
          onError(error, stack);
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// Standardized Material 3 alert card adhering to workspace persistence rules.
/// Preserves grid layouts, cleans error texts, and renders the 'Re-verify Input' action.
class ErrorBoundaryFallbackCard extends StatelessWidget {
  final String title;
  final String message;
  final bool isLocked;
  final bool isRetrying;
  final int retryCount;
  final int maxRetries;
  final VoidCallback onRetry;
  final VoidCallback? onReportIssue;

  const ErrorBoundaryFallbackCard({
    super.key,
    this.title = 'Component Notice',
    required this.message,
    required this.isLocked,
    required this.isRetrying,
    required this.retryCount,
    required this.maxRetries,
    required this.onRetry,
    this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Standard alert styling palette indicating safe warning/error condition
    final containerColor = isLocked
        ? colorScheme.errorContainer.withOpacity(0.85)
        : colorScheme.surfaceContainerHighest;
    final outlineColor = isLocked ? colorScheme.error : colorScheme.outlineVariant;
    final primaryTextColor = isLocked ? colorScheme.onErrorContainer : colorScheme.onSurface;
    final accentColor = isLocked ? colorScheme.error : colorScheme.primary;

    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title: $message',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        elevation: 0,
        color: containerColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: outlineColor, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isLocked ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                    color: accentColor,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  if (retryCount > 0 && !isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Attempt $retryCount/$maxRetries',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: primaryTextColor,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              if (isLocked) ...[
                Text(
                  'Retry limit reached. This section has been locked and routed to the exception queue.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: onReportIssue ?? () {},
                      icon: const Icon(Icons.support_agent_rounded, size: 18),
                      label: const Text('Contact Support'),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: isRetrying ? null : onRetry,
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: isLocked ? colorScheme.onError : colorScheme.onPrimary,
                      ),
                      icon: isRetrying
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(isRetrying ? 'Re-verifying...' : 'Re-verify Input'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
