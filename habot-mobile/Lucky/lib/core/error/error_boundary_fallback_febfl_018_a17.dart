// FEBFL-018-A17 — Unified Error Boundary Fallback UI (Mobile).
// Catches build/render exceptions and network crashes, rendering a graceful, non-alarming fallback
// screen with typography hierarchy for error codes, telemetry dispatch, and a clear return-home CTA.

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Telemetry metadata gathered upon error boundary trigger.
class ErrorBoundaryTelemetryData {
  final String mobilePlatform;
  final String osVersion;
  final String deviceType;
  final Size screenDimensions;
  final String mobileConfiguration;
  final String completionStatus;
  final DateTime timestamp;
  final String? errorCode;
  final String errorMessage;
  final StackTrace? stackTrace;

  const ErrorBoundaryTelemetryData({
    required this.mobilePlatform,
    required this.osVersion,
    required this.deviceType,
    required this.screenDimensions,
    required this.mobileConfiguration,
    required this.completionStatus,
    required this.timestamp,
    required this.errorMessage,
    this.errorCode,
    this.stackTrace,
  });

  Map<String, dynamic> toMap() => {
        'mobilePlatform': mobilePlatform,
        'osVersion': osVersion,
        'deviceType': deviceType,
        'screenDimensions': {
          'width': screenDimensions.width,
          'height': screenDimensions.height,
        },
        'mobileConfiguration': mobileConfiguration,
        'completionStatus': completionStatus,
        'timestamp': timestamp.toIso8601String(),
        'errorCode': errorCode ?? 'ERR_UNHANDLED_EXCEPTION',
        'errorMessage': errorMessage,
        'stackTrace': stackTrace?.toString(),
      };
}

/// Global / Local Error Boundary wrapper for graceful failure recovery.
class UnifiedErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(
    BuildContext context,
    FlutterErrorDetails errorDetails,
    VoidCallback resetError,
  )? fallbackBuilder;
  final void Function(ErrorBoundaryTelemetryData telemetry)? onTelemetryDispatch;
  final VoidCallback? onNavigateHome;

  const UnifiedErrorBoundary({
    super.key,
    required this.child,
    this.fallbackBuilder,
    this.onTelemetryDispatch,
    this.onNavigateHome,
  });

  @override
  State<UnifiedErrorBoundary> createState() => _UnifiedErrorBoundaryState();
}

class _UnifiedErrorBoundaryState extends State<UnifiedErrorBoundary> {
  FlutterErrorDetails? _errorDetails;
  bool _hasLoggedTelemetry = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleError(FlutterErrorDetails details) {
    if (_errorDetails != null) return;
    setState(() {
      _errorDetails = details;
    });
  }

  void _resetError() {
    setState(() {
      _errorDetails = null;
      _hasLoggedTelemetry = false;
    });
  }

  void _dispatchTelemetry(BuildContext context, FlutterErrorDetails details) {
    if (_hasLoggedTelemetry) return;
    _hasLoggedTelemetry = true;

    final mediaQuery = MediaQuery.maybeOf(context);
    final size = mediaQuery?.size ?? Size.zero;

    String platformName = 'Unknown';
    String osVersion = 'Unknown';
    if (!kIsWeb) {
      platformName = Platform.operatingSystem;
      osVersion = Platform.operatingSystemVersion;
    } else {
      platformName = 'Web';
    }

    final telemetry = ErrorBoundaryTelemetryData(
      mobilePlatform: platformName,
      osVersion: osVersion,
      deviceType: size.shortestSide >= 600 ? 'Tablet' : 'Mobile Phone',
      screenDimensions: size,
      mobileConfiguration: kReleaseMode ? 'Release' : (kProfileMode ? 'Profile' : 'Debug'),
      completionStatus: 'Complete',
      timestamp: DateTime.now().toUtc(),
      errorCode: 'FEBFL-018-ERR',
      errorMessage: details.exceptionAsString(),
      stackTrace: details.stack,
    );

    widget.onTelemetryDispatch?.call(telemetry);
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _errorDetails != null) {
          _dispatchTelemetry(context, _errorDetails!);
        }
      });

      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(context, _errorDetails!, _resetError);
      }

      return UnifiedErrorFallbackView(
        errorDetails: _errorDetails!,
        onRetry: _resetError,
        onNavigateHome: widget.onNavigateHome,
      );
    }

    return _ErrorBoundaryScope(
      onError: _handleError,
      child: widget.child,
    );
  }
}

/// Internal widget that intercepts child build errors.
class _ErrorBoundaryScope extends StatelessWidget {
  final Widget child;
  final void Function(FlutterErrorDetails details) onError;

  const _ErrorBoundaryScope({
    required this.child,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      onError(details);
      return const SizedBox.shrink();
    };
    return child;
  }
}

/// Standardized Material 3 Fallback UI meeting WCAG 2.1 AA accessibility and UX hierarchy.
class UnifiedErrorFallbackView extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  final VoidCallback onRetry;
  final VoidCallback? onNavigateHome;
  final String? customTitle;
  final String? customSubtitle;
  final String errorCode;

  const UnifiedErrorFallbackView({
    super.key,
    required this.errorDetails,
    required this.onRetry,
    this.onNavigateHome,
    this.customTitle,
    this.customSubtitle,
    this.errorCode = 'FEBFL-018-A17',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Semantics(
              label: 'Application Error State View',
              container: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Friendly non-alarming illustration indicator
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                        color: colorScheme.error,
                        semanticLabel: 'Connection or processing issue illustration',
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Primary Heading
                    Text(
                      customTitle ?? 'Something Went Unexpectedly',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle / User Message
                    Text(
                      customSubtitle ??
                          'We encountered an issue displaying this screen. Our engineering team has been notified. You can retry or head back home safely.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Code Chip / Badge (Clear Typography Hierarchy)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest ?? colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Reference ID: $errorCode',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Action CTAs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Secondary CTA: Try Again
                        OutlinedButton.icon(
                          onPressed: onRetry,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Try Again'),
                        ),
                        const SizedBox(width: 12),

                        // Primary CTA: Return Home
                        FilledButton.icon(
                          onPressed: () {
                            if (onNavigateHome != null) {
                              onNavigateHome!();
                            } else if (Navigator.of(context).canPop()) {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.home_rounded, size: 18),
                          label: const Text('Return Home'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
