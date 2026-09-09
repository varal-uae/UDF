// BPTR-0422-A03 — Passive Failure Motion Curves.
// Defines standardized motion tokens and a pulsing lock widget for system-generated stops that require immediate user acknowledgment.

import 'package:flutter/material.dart';

/// Motion timing and curve tokens for passive failure events.
abstract final class Bptr0422A03MotionTokens {
  static const Duration passiveFailureDuration = Duration(milliseconds: 300);
  static const Duration pulseDuration = Duration(milliseconds: 1200);
  static const Curve failureCurve = Curves.easeInOutCubicEmphasized;
  static const Curve pulseCurve = Curves.easeInOutSine;
  static const double pulseMinOpacity = 0.45;
  static const double pulseMaxOpacity = 1.0;
}

/// Lightweight platform-specific JSON token payload for motion configuration.
class PassiveFailureMotionProfile {
  const PassiveFailureMotionProfile({
    this.durationMs = Bptr0422A03MotionTokens.passiveFailureDuration.inMilliseconds,
    this.pulseDurationMs = Bptr0422A03MotionTokens.pulseDuration.inMilliseconds,
    this.curve = 'easeInOutCubicEmphasized',
    this.pulseCurve = 'easeInOutSine',
    this.pulseMinOpacity = Bptr0422A03MotionTokens.pulseMinOpacity,
    this.pulseMaxOpacity = Bptr0422A03MotionTokens.pulseMaxOpacity,
    this.lockUntilAcknowledged = true,
  });

  final int durationMs;
  final int pulseDurationMs;
  final String curve;
  final String pulseCurve;
  final double pulseMinOpacity;
  final double pulseMaxOpacity;
  final bool lockUntilAcknowledged;

  Map<String, dynamic> toJson() => {
        'durationMs': durationMs,
        'pulseDurationMs': pulseDurationMs,
        'curve': curve,
        'pulseCurve': pulseCurve,
        'pulseMinOpacity': pulseMinOpacity,
        'pulseMaxOpacity': pulseMaxOpacity,
        'lockUntilAcknowledged': lockUntilAcknowledged,
      };

  factory PassiveFailureMotionProfile.fromJson(Map<String, dynamic> json) {
    return PassiveFailureMotionProfile(
      durationMs: json['durationMs'] as int? ?? Bptr0422A03MotionTokens.passiveFailureDuration.inMilliseconds,
      pulseDurationMs: json['pulseDurationMs'] as int? ?? Bptr0422A03MotionTokens.pulseDuration.inMilliseconds,
      curve: json['curve'] as String? ?? 'easeInOutCubicEmphasized',
      pulseCurve: json['pulseCurve'] as String? ?? 'easeInOutSine',
      pulseMinOpacity: (json['pulseMinOpacity'] as num?)?.toDouble() ?? Bptr0422A03MotionTokens.pulseMinOpacity,
      pulseMaxOpacity: (json['pulseMaxOpacity'] as num?)?.toDouble() ?? Bptr0422A03MotionTokens.pulseMaxOpacity,
      lockUntilAcknowledged: json['lockUntilAcknowledged'] as bool? ?? true,
    );
  }
}

/// A pulsing wrapper that locks the visual hierarchy until [acknowledged] becomes true.
class Bptr0422A03PassiveFailurePulse extends StatefulWidget {
  const Bptr0422A03PassiveFailurePulse({
    super.key,
    required this.child,
    this.acknowledged = false,
  });

  final Widget child;
  final bool acknowledged;

  @override
  State<Bptr0422A03PassiveFailurePulse> createState() =>
      _Bptr0422A03PassiveFailurePulseState();
}

class _Bptr0422A03PassiveFailurePulseState
    extends State<Bptr0422A03PassiveFailurePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Bptr0422A03MotionTokens.pulseDuration,
    );
    if (!widget.acknowledged) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant Bptr0422A03PassiveFailurePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.acknowledged && !oldWidget.acknowledged) {
      _controller.stop();
    } else if (!widget.acknowledged && oldWidget.acknowledged) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.acknowledged) {
      return widget.child;
    }
    return FadeTransition(
      opacity: Tween<double>(
        begin: Bptr0422A03MotionTokens.pulseMinOpacity,
        end: Bptr0422A03MotionTokens.pulseMaxOpacity,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Bptr0422A03MotionTokens.pulseCurve,
        ),
      ),
      child: widget.child,
    );
  }
}
