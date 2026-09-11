// ERMWD-008 — Global error handling interceptor and M3 Elevated Card error surface.
// Captures passive failures, logs them through an injectable BigQuery-compatible sink,
// and renders human-readable Material 3 elevated cards for mobile error states.

import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef Ermwd008BigQueryLogSink = Future<void> Function(Map<String, Object?> event);

class Ermwd008GlobalErrorInterceptor {
  Ermwd008GlobalErrorInterceptor({
    required Ermwd008BigQueryLogSink logSink,
    this.sessionId,
  }) : _logSink = logSink;

  final Ermwd008BigQueryLogSink _logSink;
  final String? sessionId;

  void install() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      unawaited(_logPassiveFailure(details));
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      unawaited(_logError(error, stack, source: 'PlatformDispatcher'));
      return true;
    };
  }

  Future<void> _logPassiveFailure(FlutterErrorDetails details) {
    return _logError(
      details.exception,
      details.stack ?? StackTrace.current,
      source: 'FlutterError',
    );
  }

  Future<void> _logError(
    Object error,
    StackTrace stack, {
    required String source,
  }) async {
    final event = <String, Object?>{
      'atomicId': 'ERMWD-008',
      'eventType': 'PassiveFailure',
      'source': source,
      'message': error.toString(),
      'stackTrace': stack.toString(),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'sessionId': sessionId,
      'completionStatus': 'Complete',
    };

    try {
      await _logSink(event);
    } catch (_) {
      // Swallow logging failures to avoid recursive passive-failure loops.
    }
  }
}

void installErmwd008ErrorWidgetBoundary() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: Ermwd008ErrorCard(
          title: 'Something went wrong',
          message: 'The screen could not be displayed safely.',
          details: kDebugMode ? details.exceptionAsString() : null,
        ),
      ),
    );
  };
}

class Ermwd008ErrorCard extends StatelessWidget {
  const Ermwd008ErrorCard({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.onRetry,
  });

  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      color: colorScheme.surface,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Ermwd008LoadingProgress extends StatelessWidget {
  const Ermwd008LoadingProgress({super.key, this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(value: value),
    );
  }
}