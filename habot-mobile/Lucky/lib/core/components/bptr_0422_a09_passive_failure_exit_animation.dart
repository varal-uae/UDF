// BPTR-0422-A09 — Passive Failure Exit Motion Curve & Pulse.
// Provides Material 3 motion tokens and reusable widgets for passive failure exits (200–300ms)
// and continuous pulse until the quarantined failure is acknowledged.

import 'package:flutter/material.dart';

/// Standardized micro-interaction durations for passive failure motion.
class PassiveFailureMotionTokens {
  PassiveFailureMotionTokens._();

  static const Duration floorDuration = Duration(milliseconds: 100);
  static const Duration optimalDuration = Duration(milliseconds: 250);
  static const Duration ceilingDuration = Duration(milliseconds: 400);
  static const Curve exitCurve = Curves.easeInOutCubic;
  static const Curve pulseCurve = Curves.easeInOutSine;
}

/// Animates item removal using a standardized passive-failure-exit motion curve.
class PassiveFailureExitAnimation extends StatefulWidget {
  const PassiveFailureExitAnimation({
    super.key,
    required this.child,
    required this.removed,
    this.onDismissed,
    this.duration = PassiveFailureMotionTokens.optimalDuration,
    this.curve = PassiveFailureMotionTokens.exitCurve,
  });

  final Widget child;
  final bool removed;
  final VoidCallback? onDismissed;
  final Duration duration;
  final Curve curve;

  @override
  State<PassiveFailureExitAnimation> createState() =>
      _PassiveFailureExitAnimationState();
}

class _PassiveFailureExitAnimationState
    extends State<PassiveFailureExitAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.04),
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.addStatusListener(_handleStatus);
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isRemoving) {
      widget.onDismissed?.call();
    }
  }

  @override
  void didUpdateWidget(covariant PassiveFailureExitAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.removed && !oldWidget.removed && !_isRemoving) {
      _isRemoving = true;
      _controller.forward(from: 0);
    } else if (!widget.removed && oldWidget.removed && _isRemoving) {
      _isRemoving = false;
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Pulses a failed element until it is acknowledged.
class PassiveFailurePulse extends StatefulWidget {
  const PassiveFailurePulse({
    super.key,
    required this.child,
    required this.active,
    this.pulseDuration = const Duration(milliseconds: 600),
    this.curve = PassiveFailureMotionTokens.pulseCurve,
    this.minOpacity = 0.7,
    this.minScale = 0.98,
  });

  final Widget child;
  final bool active;
  final Duration pulseDuration;
  final Curve curve;
  final double minOpacity;
  final double minScale;

  @override
  State<PassiveFailurePulse> createState() => _PassiveFailurePulseState();
}

class _PassiveFailurePulseState extends State<PassiveFailurePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _opacityPulse;
  late final Animation<double> _scalePulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    );
    _opacityPulse = Tween<double>(
      begin: 1.0,
      end: widget.minOpacity,
    ).animate(CurvedAnimation(parent: _pulseController, curve: widget.curve));
    _scalePulse = Tween<double>(
      begin: 1.0,
      end: widget.minScale,
    ).animate(CurvedAnimation(parent: _pulseController, curve: widget.curve));
    if (widget.active) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PassiveFailurePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.active && oldWidget.active) {
      _pulseController.stop();
      _pulseController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityPulse.value,
          child: ScaleTransition(
            scale: _scalePulse,
            child: child,
          ),
        );
      },
    );
  }
}