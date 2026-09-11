// FCSES-013-A08 — Frontend Error Mapping Boundaries: component-level error boundary, backend error code mapping, retry UI, and standardized Snackbar handling.
// Wraps child widgets to isolate failures, provides Material retry actions, and auto-retries when connectivity is restored.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class BackendErrorMapper {
  static String messageFor(String? code) {
    switch (code) {
      case 'TIMEOUT':
        return 'The request timed out. Please retry.';
      case 'NETWORK':
        return 'No network connection. Check your settings.';
      case 'UNAUTHORIZED':
        return 'Your session expired. Please sign in again.';
      case 'SERVER':
        return 'Service is temporarily unavailable.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.errorCode,
    this.autoRetryOnReconnect = true,
  });

  final Widget child;
  final Future<void> Function()? onRetry;
  final String? errorCode;
  final bool autoRetryOnReconnect;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoRetryOnReconnect) {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
        final hasConnection = results.any((r) => r != ConnectivityResult.none);
        if (hasConnection && _error != null) {
          _retry();
        }
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _retry() async {
    if (_retrying || widget.onRetry == null) return;
    setState(() => _retrying = true);
    try {
      await widget.onRetry!.call();
      if (!mounted) return;
      setState(() {
        _error = null;
        _stackTrace = null;
      });
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _stackTrace = stackTrace;
      });
      _showSnackBar(BackendErrorMapper.messageFor(widget.errorCode));
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'Retry', onPressed: _retry),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorFallback(
        message: BackendErrorMapper.messageFor(widget.errorCode),
        onRetry: widget.onRetry == null ? null : _retry,
        isRetrying: _retrying,
      );
    }
    return widget.child;
  }
}

class _ErrorFallback extends StatelessWidget {
  const _ErrorFallback({
    required this.message,
    this.onRetry,
    required this.isRetrying,
  });

  final String message;
  final Future<void> Function()? onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isRetrying ? null : onRetry,
              icon: isRetrying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(isRetrying ? 'Retrying...' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
