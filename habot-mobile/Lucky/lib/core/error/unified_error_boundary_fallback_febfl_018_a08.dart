// FEBFL-018-A08 — Unified 'Error Boundary' Fallback UI (Mobile).
// Provides a branded, centered fallback screen with illustration, warning note, and Reload Module action; installs Flutter global error hooks and dispatches telemetry.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

typedef ErrorTelemetryCallback = void Function(Object error, StackTrace? stackTrace);

class UnifiedErrorBoundary extends StatefulWidget {
  const UnifiedErrorBoundary({
    super.key,
    required this.child,
    this.onTelemetry,
    this.onReloadModule,
  });

  final Widget child;
  final ErrorTelemetryCallback? onTelemetry;
  final VoidCallback? onReloadModule;

  static void installGlobalHandlers({ErrorTelemetryCallback? onTelemetry}) {
    final previous = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      onTelemetry?.call(details.exception, details.stack);
      if (previous != null) {
        previous(details);
      } else {
        FlutterError.presentError(details);
      }
    };

    ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      onTelemetry?.call(error, stack);
      return true;
    };
  }

  @override
  State<UnifiedErrorBoundary> createState() => _UnifiedErrorBoundaryState();
}

class _UnifiedErrorBoundaryState extends State<UnifiedErrorBoundary> {
  late final ErrorWidgetBuilder _previousErrorWidgetBuilder;

  @override
  void initState() {
    super.initState();
    _previousErrorWidgetBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      widget.onTelemetry?.call(details.exception, details.stack);
      return UnifiedErrorFallback(
        error: details.exception,
        onReloadModule: widget.onReloadModule,
      );
    };
  }

  @override
  void dispose() {
    ErrorWidget.builder = _previousErrorWidgetBuilder;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class UnifiedErrorFallback extends StatelessWidget {
  const UnifiedErrorFallback({
    super.key,
    this.error,
    this.onReloadModule,
  });

  final Object? error;
  final VoidCallback? onReloadModule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 56,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Something went wrong',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We encountered a technical issue. Please reload the module to continue.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${error.toString()}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: onReloadModule ?? () {},
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reload Module'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
