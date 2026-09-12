// FEBFL-018-A13 — Unified "Error Boundary" Fallback UI (Mobile).
// Provides a global ErrorWidget.builder replacement and a wrapper widget that catches render errors,
// displaying a branded, friendly fallback screen with telemetry dispatch and responsive layout.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Signature for telemetry dispatch on error.
typedef ErrorTelemetryCallback = void Function(Object error, StackTrace? stackTrace);

/// A widget that wraps the app and sets up a global error boundary.
class UnifiedErrorBoundary extends StatefulWidget {
  final Widget child;
  final ErrorTelemetryCallback? onError;
  final Widget Function(BuildContext, Object, StackTrace?)? fallbackBuilder;

  const UnifiedErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.fallbackBuilder,
  });

  @override
  State<UnifiedErrorBoundary> createState() => _UnifiedErrorBoundaryState();
}

class _UnifiedErrorBoundaryState extends State<UnifiedErrorBoundary> {
  @override
  void initState() {
    super.initState();
    // Set up global error widget builder.
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Dispatch telemetry.
      widget.onError?.call(details.exception, details.stack);
      // Return fallback UI.
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(context, details.exception, details.stack);
      }
      return FallbackErrorScreen(
        error: details.exception,
        stackTrace: details.stack,
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// A responsive, branded fallback screen shown when an error occurs.
class FallbackErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onReturnHome;

  const FallbackErrorScreen({
    super.key,
    required this.error,
    this.stackTrace,
    this.onReturnHome,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive gutter widths per breakpoint tier.
        final double horizontalPadding;
        if (constraints.maxWidth < 600) {
          horizontalPadding = 16.0; // mobile
        } else if (constraints.maxWidth < 900) {
          horizontalPadding = 24.0; // tablet
        } else {
          horizontalPadding = 32.0; // desktop
        }

        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Friendly, non-alarming illustration (placeholder icon).
                  Icon(
                    Icons.sentiment_dissatisfied_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  // Clear typography hierarchy for error codes.
                  Text(
                    'Oops! Something went wrong.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error code: ${error.runtimeType}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We encountered a technical issue. Please try again later.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Clear CTA to return home.
                  FilledButton.icon(
                    onPressed: onReturnHome ?? () {
                      // Default: pop to first route or restart.
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Return Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
