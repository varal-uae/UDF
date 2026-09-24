// REF-197-A04 — Safe Error-Handling UI Rollback Handler.
// Intercepts HTTP 4xx/5xx errors, strips technical details for security, and presents Material 3 dialogs with retry options.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents a sanitized error ready for UI presentation.
class SanitizedError {
  final String userMessage;
  final String? recoveryAction;
  final int? statusCode;

  const SanitizedError({
    required this.userMessage,
    this.recoveryAction,
    this.statusCode,
  });
}

/// Poka-Yoke: Catch-all code structures strip out server-specific error language
/// automatically before messages reach the UI layer.
class ErrorSanitizer {
  static const List<String> _sensitivePatterns = [
    r'sql',
    r'database',
    r'table',
    r'column',
    r'stack trace',
    r'exception at',
    r'internal server error details',
    r'null pointer',
    r'syntax error',
  ];

  /// Strips technical system logs to prevent exposing database structure details.
  static SanitizedError sanitize(dynamic error, {int? statusCode}) {
    String rawMessage = error.toString();
    String lowerMessage = rawMessage.toLowerCase();

    bool containsSensitiveInfo = false;
    for (final pattern in _sensitivePatterns) {
      if (lowerMessage.contains(pattern)) {
        containsSensitiveInfo = true;
        break;
      }
    }

    if (containsSensitiveInfo || (statusCode != null && statusCode >= 500)) {
      return SanitizedError(
        userMessage: 'Something went wrong. Please try again later.',
        recoveryAction: 'Retry',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return SanitizedError(
        userMessage: 'The request could not be completed. Please check your input and try again.',
        recoveryAction: 'Fix & Retry',
        statusCode: statusCode,
      );
    }

    return SanitizedError(
      userMessage: 'An unexpected issue occurred. Please try again.',
      recoveryAction: 'Retry',
      statusCode: statusCode,
    );
  }
}

/// Mock interceptor simulating HTTP 4xx and 5xx error responses.
/// In production, this integrates with Dio or http interceptors.
class MockHttpInterceptor {
  static Future<T> executeWithInterception<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      // Simulate extracting status code from an HTTP exception
      int? statusCode;
      if (e.toString().contains('404')) statusCode = 404;
      if (e.toString().contains('500')) statusCode = 500;
      
      final sanitized = ErrorSanitizer.sanitize(e, statusCode: statusCode);
      throw sanitized;
    }
  }
}

/// A resilient error boundary widget that manages transaction exceptions cleanly.
/// Wraps any data-aware component layout to provide safe rollback handling.
class ErrorRollbackBoundary extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRetry;
  final String? customErrorMessage;

  const ErrorRollbackBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.customErrorMessage,
  });

  @override
  State<ErrorRollbackBoundary> createState() => _ErrorRollbackBoundaryState();
}

class _ErrorRollbackBoundaryState extends State<ErrorRollbackBoundary> {
  bool _hasError = false;
  SanitizedError? _sanitizedError;

  void triggerError(dynamic error, {int? statusCode}) {
    setState(() {
      _hasError = true;
      _sanitizedError = ErrorSanitizer.sanitize(error, statusCode: statusCode);
    });
  }

  void resetError() {
    setState(() {
      _hasError = false;
      _sanitizedError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _sanitizedError != null) {
      return _buildErrorFallback(context);
    }
    return widget.child;
  }

  Widget _buildErrorFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              widget.customErrorMessage ?? _sanitizedError!.userMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                resetError();
                widget.onRetry?.call();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(_sanitizedError!.recoveryAction ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Presents simple, text-based error alerts fitting mobile screens well
/// without breaking complex UI layouts.
class ErrorDialogPresenter {
  static Future<void> show({
    required BuildContext context,
    required dynamic error,
    int? statusCode,
    VoidCallback? onRetry,
  }) async {
    final sanitized = ErrorSanitizer.sanitize(error, statusCode: statusCode);
    final theme = Theme.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            size: 48,
          ),
          title: const Text('Action Required'),
          content: Text(
            sanitized.userMessage,
            style: theme.textTheme.bodyMedium,
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Dismiss'),
            ),
            if (onRetry != null)
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onRetry();
                },
                child: Text(sanitized.recoveryAction ?? 'Retry'),
              ),
          ],
        );
      },
    );
  }
}

/// Global error handler that can be attached to runZonedGuarded or FlutterError.onError.
/// Streams detailed engineering error logs to centralized monitoring tools conceptually.
class GlobalErrorHandler {
  static void handleFlutterError(FlutterErrorDetails details) {
    // In production: Sentry.captureException(details.exception, stackTrace: details.stack);
    debugPrint('[Error Framework] Caught: ${details.exception}');
    
    // Poka-Yoke: Self-chasing code review rule enforced here.
    // Never pass raw server error text directly to UI components.
    final sanitized = ErrorSanitizer.sanitize(details.exception);
    debugPrint('[Error Framework] Sanitized for UI: ${sanitized.userMessage}');
  }

  static void handlePlatformError(Object error, StackTrace stack) {
    // In production: Sentry.captureException(error, stackTrace: stack);
    debugPrint('[Error Framework] Platform Error: $error');
    final sanitized = ErrorSanitizer.sanitize(error);
    debugPrint('[Error Framework] Sanitized for UI: ${sanitized.userMessage}');
  }
}

/// Keyboard push-up avoidance behavior for the input panel.
/// Aligns with Mobile-First & Responsive UX Google Material Design Decision.
class KeyboardAvoidingWrapper extends StatelessWidget {
  final Widget child;

  const KeyboardAvoidingWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside input fields
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
