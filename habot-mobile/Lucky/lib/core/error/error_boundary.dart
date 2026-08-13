import 'package:flutter/material.dart';
import 'error_telemetry.dart';
import 'error_fallback_screen.dart';

/// FEBFL-018-A01 — Unified Error Boundary wrapper.
/// Wraps any widget subtree; catches render errors and shows [ErrorFallbackScreen].
/// Place around every major feature module in the widget tree.
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.module = 'unknown',
  });

  final Widget child;

  /// Identifies which Byt module this boundary wraps — used in telemetry.
  final String module;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (FlutterErrorDetails details) {
      _captureError(details.exception, details.stack ?? StackTrace.current);
      return ErrorFallbackScreen(
        module: widget.module,
        onRetry: _reset,
      );
    };
  }

  void _captureError(Object error, StackTrace stack) {
    ErrorTelemetry.dispatch(
      error: error,
      stackTrace: stack,
      module: widget.module,
    );
    if (mounted) {
      setState(() => _error = error);
    }
  }

  void _reset() => setState(() => _error = null);

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorFallbackScreen(module: widget.module, onRetry: _reset);
    }
    return widget.child;
  }
}
