// DRVUT-010-A01 — Reactive Red Hurry-Up Warning Pulse Trigger at 240s Mark.
// Implements a Material 3 emergency warning theme scope with semantic error-container transitions and a 240-second pulse trigger for task execution layouts.

import 'dart:async';

import 'package:flutter/material.dart';

class Drvut010A01HurryUpWarningPulse extends StatefulWidget {
  const Drvut010A01HurryUpWarningPulse({
    super.key,
    required this.child,
    this.triggerAfter = const Duration(seconds: 240),
    this.onWarningStarted,
  });

  final Widget child;
  final Duration triggerAfter;
  final VoidCallback? onWarningStarted;

  @override
  State<Drvut010A01HurryUpWarningPulse> createState() =>
      _Drvut010A01HurryUpWarningPulseState();
}

class _Drvut010A01HurryUpWarningPulseState
    extends State<Drvut010A01HurryUpWarningPulse>
    with SingleTickerProviderStateMixin {
  Timer? _warningTimer;
  late final AnimationController _pulseController;
  bool _isWarningActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _warningTimer = Timer(widget.triggerAfter, _activateWarning);
  }

  void _activateWarning() {
    if (!mounted) return;
    setState(() => _isWarningActive = true);
    widget.onWarningStarted?.call();
  }

  @override
  void dispose() {
    _warningTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final baseScheme = baseTheme.colorScheme;
    final warningTheme = baseTheme.copyWith(
      colorScheme: baseScheme.copyWith(
        errorContainer: baseScheme.error,
        onErrorContainer: baseScheme.onError,
      ),
    );

    return AnimatedTheme(
      data: _isWarningActive ? warningTheme : baseTheme,
      duration: const Duration(milliseconds: 240),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseColor = _isWarningActive
              ? Color.lerp(
                  baseScheme.errorContainer,
                  baseScheme.error,
                  _pulseController.value,
                )!
              : Colors.transparent;

          return DecoratedBox(
            decoration: BoxDecoration(color: pulseColor),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
