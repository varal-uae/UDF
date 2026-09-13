// FEBFL-036-A08 — Real-Time Interface Crash Monitor & Fallback Boundary.
// Provides defensive execution fallbacks and crash telemetry wrappers around unmapped dynamic component blocks,
// delivering friendly conversational recovery options with WCAG 2.1 AA compliant 48dp touch targets.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Telemetry payload recording atomic layout failure telemetry for real-time analytics.
class CrashMonitorTelemetryData {
  final String lockType;
  final String lockStatus;
  final String lockedBy;
  final DateTime lockTimestamp;
  final String lockReason;
  final String completionStatus; // 'Complete', 'Partial', or 'Not Complete'
  final DateTime eventTimestamp;
  final String userSessionId;
  final String? errorSummary;
  final String? stackTrace;
  final String? componentTag;

  const CrashMonitorTelemetryData({
    required this.lockType,
    required this.lockStatus,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
    required this.completionStatus,
    required this.eventTimestamp,
    required this.userSessionId,
    this.errorSummary,
    this.stackTrace,
    this.componentTag,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Lock Type': lockType,
      'Lock Status': lockStatus,
      'Locked By': lockedBy,
      'Lock Timestamp': lockTimestamp.toIso8601String(),
      'Lock Reason': lockReason,
      'Completion Status': completionStatus,
      'Action/Event Timestamp': eventTimestamp.toIso8601String(),
      'User/Session ID': userSessionId,
      'Error Summary': errorSummary,
      'Stack Trace': stackTrace,
      'Component Tag': componentTag,
    };
  }
}

/// Signature for reporting crash telemetry to analytical gateways (e.g., BigQuery log streams).
typedef CrashTelemetryReporter = void Function(CrashMonitorTelemetryData telemetry);

/// A robust real-time crash monitor boundary widget designed for dynamic UI component trees.
class DynamicCrashMonitorBoundary extends StatefulWidget {
  final Widget child;
  final String componentTag;
  final String userSessionId;
  final String lockType;
  final String lockedBy;
  final CrashTelemetryReporter? onTelemetryLogged;
  final Future<void> Function()? onRetry;

  const DynamicCrashMonitorBoundary({
    super.key,
    required this.child,
    required this.componentTag,
    required this.userSessionId,
    this.lockType = 'DynamicBlockLayout',
    this.lockedBy = 'FrontEndEngine',
    this.onTelemetryLogged,
    this.onRetry,
  });

  @override
  State<DynamicCrashMonitorBoundary> createState() => _DynamicCrashMonitorBoundaryState();
}

class _DynamicCrashMonitorBoundaryState extends State<DynamicCrashMonitorBoundary> {
  bool _hasError = false;
  Object? _caughtError;
  StackTrace? _caughtStackTrace;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
  }

  void _reportCrash(Object error, StackTrace stackTrace) {
    final telemetry = CrashMonitorTelemetryData(
      lockType: widget.lockType,
      lockStatus: 'Active',
      lockedBy: widget.lockedBy,
      lockTimestamp: DateTime.now().toUtc(),
      lockReason: 'Dynamic component rendering failed: ${error.toString()}',
      completionStatus: 'Not Complete',
      eventTimestamp: DateTime.now().toUtc(),
      userSessionId: widget.userSessionId,
      errorSummary: error.toString(),
      stackTrace: stackTrace.toString(),
      componentTag: widget.componentTag,
    );

    if (widget.onTelemetryLogged != null) {
      widget.onTelemetryLogged!(telemetry);
    } else {
      debugPrint('[Telemetry Crash Log] => ${telemetry.toMap()}');
    }
  }

  Future<void> _handleRetry() async {
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
          _caughtError = null;
          _caughtStackTrace = null;
          _isRetrying = false;
        });
      }
    } catch (retryError, retryStackTrace) {
      if (mounted) {
        _reportCrash(retryError, retryStackTrace);
        setState(() {
          _caughtError = retryError;
          _caughtStackTrace = retryStackTrace;
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildFallbackView(context);
    }

    // Wrap child in a custom error catcher for layout generation errors.
    return _DynamicComponentCatcher(
      onError: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _reportCrash(error, stack);
            setState(() {
              _hasError = true;
              _caughtError = error;
              _caughtStackTrace = stack;
            });
          }
        });
      },
      child: widget.child,
    );
  }

  Widget _buildFallbackView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.stream_rounded,
                size: 44,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                "We're refreshing this section",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This layout temporarily paused to protect your progress. You can easily reload it without losing your session data.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode && _caughtError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _caughtError.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Accessible touch target: 48dp x 48dp minimum per WCAG AA
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 48.0,
                  minHeight: 48.0,
                ),
                child: FilledButton.icon(
                  onPressed: _isRetrying ? null : _handleRetry,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(120, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  icon: _isRetrying
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(
                    _isRetrying ? 'Reconnecting...' : 'Reload Section',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget that captures layout building errors inside component trees.
class _DynamicComponentCatcher extends StatelessWidget {
  final Widget child;
  final void Function(Object error, StackTrace stack) onError;

  const _DynamicComponentCatcher({
    required this.child,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return child;
    } catch (e, st) {
      onError(e, st);
      return const SizedBox.shrink();
    }
  }
}
