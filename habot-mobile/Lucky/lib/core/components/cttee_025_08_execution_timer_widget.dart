// CTTEE-025-08 — Visible 5-Minute Execution Timer Widget.
// Provides a pinned, accessible countdown clock for master layout containers; uses Material 3 badges, pulses under one minute, and transitions to error semantics near timeout.
import 'dart:async';
import 'package:flutter/material.dart';

class Cttee02508ExecutionTimer extends StatefulWidget {
  const Cttee02508ExecutionTimer({
    super.key,
    this.duration = const Duration(minutes: 5),
    this.onTimeout,
    this.autoStart = true,
  });

  final Duration duration;
  final VoidCallback? onTimeout;
  final bool autoStart;

  @override
  State<Cttee02508ExecutionTimer> createState() => _Cttee02508ExecutionTimerState();
}

class _Cttee02508ExecutionTimerState extends State<Cttee02508ExecutionTimer> with SingleTickerProviderStateMixin {
  late Duration _remaining;
  Timer? _ticker;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    if (widget.autoStart) _start();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _start() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds <= 0) {
          timer.cancel();
          widget.onTimeout?.call();
          return;
        }
        _remaining = _remaining - const Duration(seconds: 1);
        if (_remaining.inSeconds <= 60 && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrgent = _remaining.inSeconds <= 60;
    final isCritical = _remaining.inSeconds <= 10;
    final color = isCritical ? theme.colorScheme.error : isUrgent ? theme.colorScheme.tertiary : theme.colorScheme.primary;
    final text = _format(_remaining);

    return Semantics(
      label: 'Execution timer',
      value: text,
      liveRegion: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: ScaleTransition(
          scale: isUrgent ? _pulseAnimation : const AlwaysStoppedAnimation<double>(1.0),
          child: Badge(
            label: Text(text),
            backgroundColor: color,
            textColor: theme.colorScheme.onPrimary,
            child: Icon(Icons.timer_outlined, color: color, size: 24),
          ),
        ),
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
