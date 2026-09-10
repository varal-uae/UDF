// CPNCA-022 — Error Dictionary Translation Layer and Generic Business Error Banner.
// Maps backend rejection codes to clean, generic business error copy and renders
// Material 3 compliant full-width banners/snackbars for mobile breakpoints.

import 'package:flutter/material.dart';

class ErrorDictionaryEntry {
  final String code;
  final String title;
  final String message;
  const ErrorDictionaryEntry({required this.code, required this.title, required this.message});
}

class ErrorDictionaryTranslator {
  ErrorDictionaryTranslator._();

  static const Map<String, ErrorDictionaryEntry> _entries = {
    'VALIDATION_FAILED': ErrorDictionaryEntry(code: 'VALIDATION_FAILED', title: 'System check failed', message: 'System check failed. Re-verify values.'),
    'UNAUTHORIZED': ErrorDictionaryEntry(code: 'UNAUTHORIZED', title: 'Access denied', message: 'Your session is no longer valid. Please sign in again.'),
    'FORBIDDEN': ErrorDictionaryEntry(code: 'FORBIDDEN', title: 'Action not allowed', message: 'You do not have clearance for this action.'),
    'TIMEOUT': ErrorDictionaryEntry(code: 'TIMEOUT', title: 'Request timed out', message: 'The service took too long to respond. Try again.'),
    'NETWORK': ErrorDictionaryEntry(code: 'NETWORK', title: 'Connection issue', message: 'Check your network connection and retry.'),
    'CONFLICT': ErrorDictionaryEntry(code: 'CONFLICT', title: 'Update conflict', message: 'The record changed. Refresh and re-verify values.'),
    'RATE_LIMITED': ErrorDictionaryEntry(code: 'RATE_LIMITED', title: 'Too many attempts', message: 'Please wait a moment before trying again.'),
    'SERVER': ErrorDictionaryEntry(code: 'SERVER', title: 'Service unavailable', message: 'System check failed. Re-verify values.'),
  };

  static const ErrorDictionaryEntry _fallback = ErrorDictionaryEntry(
    code: 'UNKNOWN',
    title: 'System check failed',
    message: 'System check failed. Re-verify values.',
  );

  static ErrorDictionaryEntry translate(String? backendCode) {
    if (backendCode == null || backendCode.isEmpty) return _fallback;
    final normalized = backendCode.trim().toUpperCase();
    return _entries[normalized] ?? _fallback;
  }
}

class BusinessErrorBanner extends StatelessWidget {
  final String backendCode;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool fullWidth;

  const BusinessErrorBanner({
    super.key,
    required this.backendCode,
    this.onRetry,
    this.onDismiss,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final entry = ErrorDictionaryTranslator.translate(backendCode);
    final theme = Theme.of(context);
    final banner = Material(
      color: theme.colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close),
                color: theme.colorScheme.onErrorContainer,
                tooltip: 'Dismiss',
              ),
          ],
        ),
      ),
    );

    return Semantics(
      liveRegion: true,
      container: true,
      label: '${entry.title}. ${entry.message}',
      child: fullWidth ? SizedBox(width: double.infinity, child: banner) : banner,
    );
  }
}

class BusinessErrorSnackbar {
  BusinessErrorSnackbar._();

  static void show(BuildContext context, String backendCode, {VoidCallback? onRetry}) {
    final entry = ErrorDictionaryTranslator.translate(backendCode);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width - 32,
        content: Semantics(
          liveRegion: true,
          child: Text('${entry.title}: ${entry.message}'),
        ),
        action: onRetry == null
            ? null
            : SnackBarAction(
                label: 'Retry',
                onPressed: onRetry,
              ),
      ),
    );
  }
}
