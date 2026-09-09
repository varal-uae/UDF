// BDAE-017-A16 — Biometric Status Feedback Bridge & Layout Flow.
// Renders centered biometric verification dialogs with animated circular rings, max elevation overlays, baseline typography, and clear error animations on failed checks.

import 'dart:math' as math;
import 'package:flutter/material.dart';

enum BiometricVerificationStatus { idle, verifying, success, failure }

/// Registers a mobile viewport error boundary for biometric status overlays.
void configureBiometricViewportErrorBoundary() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const BiometricViewportErrorFallback();
  };
}

class BiometricViewportErrorFallback extends StatelessWidget {
  const BiometricViewportErrorFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Color(0xFFFEE8E6),
      child: Center(
        child: Text(
          'Biometric viewport failed to render',
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }
}

class BiometricStatusFeedbackBridge extends StatefulWidget {
  const BiometricStatusFeedbackBridge({
    super.key,
    this.status = BiometricVerificationStatus.idle,
    this.onRetry,
    this.title = 'Biometric Verification',
    this.message,
  });

  final BiometricVerificationStatus status;
  final VoidCallback? onRetry;
  final String title;
  final String? message;

  @override
  State<BiometricStatusFeedbackBridge> createState() =>
      _BiometricStatusFeedbackBridgeState();
}

class _BiometricStatusFeedbackBridgeState
    extends State<BiometricStatusFeedbackBridge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;
  late final Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringAnimation =
        CurvedAnimation(parent: _ringController, curve: Curves.easeInOutCubic);
    if (widget.status == BiometricVerificationStatus.verifying) {
      _ringController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant BiometricStatusFeedbackBridge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == BiometricVerificationStatus.verifying &&
        !_ringController.isAnimating) {
      _ringController.repeat();
    } else if (widget.status != BiometricVerificationStatus.verifying &&
        _ringController.isAnimating) {
      _ringController.stop();
    }
    if (widget.status == BiometricVerificationStatus.failure &&
        oldWidget.status != BiometricVerificationStatus.failure) {
      _ringController.reset();
      _ringController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bool isVerifying =
        widget.status == BiometricVerificationStatus.verifying;
    final bool isSuccess =
        widget.status == BiometricVerificationStatus.success;
    final bool isFailure =
        widget.status == BiometricVerificationStatus.failure;

    final Color accentColor = isFailure
        ? colorScheme.error
        : isSuccess
            ? colorScheme.primary
            : colorScheme.primary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Material(
          color: colorScheme.surface,
          elevation: 24, // Maximum system elevation for overlay sheets.
          shadowColor: colorScheme.shadow,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: _semanticLabel(),
                  liveRegion: true,
                  child: AnimatedBuilder(
                    animation: _ringAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size.square(96),
                        painter: _VerificationRingPainter(
                          progress: isVerifying
                              ? _ringAnimation.value
                              : (isSuccess || isFailure ? 1 : 0),
                          color: accentColor,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          isError: isFailure,
                        ),
                        child: Center(
                          child: Icon(
                            isSuccess
                                ? Icons.lock_open_rounded
                                : isFailure
                                    ? Icons.lock_rounded
                                    : Icons.fingerprint_rounded,
                            size: 40,
                            color: accentColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontFamily: 'Roboto', // Baseline system typography token; replace with theme token if available.
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message ?? _defaultMessage(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isFailure && widget.onRetry != null) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel() {
    switch (widget.status) {
      case BiometricVerificationStatus.idle:
        return 'Biometric verification idle';
      case BiometricVerificationStatus.verifying:
        return 'Biometric verification in progress';
      case BiometricVerificationStatus.success:
        return 'Biometric verification successful';
      case BiometricVerificationStatus.failure:
        return 'Biometric verification failed';
    }
  }

  String _defaultMessage() {
    switch (widget.status) {
      case BiometricVerificationStatus.idle:
        return 'Touch the sensor to continue.';
      case BiometricVerificationStatus.verifying:
        return 'Validating your identity securely…';
      case BiometricVerificationStatus.success:
        return 'Identity verified. Opening task queue.';
      case BiometricVerificationStatus.failure:
        return 'Verification failed. Please try again.';
    }
  }
}

class _VerificationRingPainter extends CustomPainter {
  const _VerificationRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.isError,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final bool isError;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    const strokeWidth = 8.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    if (isError) {
      final indicatorPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      final innerRadius = radius * 0.65;
      canvas.drawLine(
        Offset(center.dx - innerRadius, center.dy - innerRadius),
        Offset(center.dx + innerRadius, center.dy + innerRadius),
        indicatorPaint,
      );
      canvas.drawLine(
        Offset(center.dx + innerRadius, center.dy - innerRadius),
        Offset(center.dx - innerRadius, center.dy + innerRadius),
        indicatorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VerificationRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.isError != isError;
  }
}
