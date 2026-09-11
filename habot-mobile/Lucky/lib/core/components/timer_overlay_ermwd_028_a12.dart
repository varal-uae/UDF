// ERMWD-028-A12 — Timer Overlay Component for task timeout visibility.
// Fixed top, full-width 4px progress bar with smooth 1s linear transitions and red depletion near 0:00.

import 'dart:async';
import 'package:flutter/material.dart';

class TimerOverlay extends StatefulWidget {
  const TimerOverlay({
    super.key,
    required this.duration,
    this.onTimeout,
    this.height = 4.0,
  });

  final Duration duration;
  final VoidCallback? onTimeout;
  final double height;

  @override
  State<TimerOverlay> createState() => _TimerOverlayState();
}

class _TimerOverlayState extends State<TimerOverlay> {
  Timer? _timer;
  late Duration _remaining;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _start();
  }

  void _start() {
    _timer?.cancel();
    const tick = Duration(milliseconds: 100);
    _timer = Timer.periodic(tick, (timer) {
      if (!mounted) return;
      setState(() {
        final next = _remaining - tick;
        _remaining = next.isNegative ? Duration.zero : next;
        if (_remaining == Duration.zero && !_timedOut) {
          _timedOut = true;
          timer.cancel();
          widget.onTimeout?.call();
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant TimerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _remaining = widget.duration;
      _timedOut = false;
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalMs = widget.duration.inMilliseconds;
    final remainingMs = _remaining.inMilliseconds.clamp(0, totalMs).toInt();
    final progress = totalMs == 0 ? 0.0 : remainingMs / totalMs;
    final displayProgress = progress.clamp(0.0, 1.0).toDouble();
    final isCritical = displayProgress <= 0.2;
    final color = isCritical ? scheme.error : scheme.primary;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: scheme.surfaceContainerHighest),
            Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: displayProgress),
                duration: const Duration(seconds: 1),
                curve: Curves.linear,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: ColoredBox(color: color),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
