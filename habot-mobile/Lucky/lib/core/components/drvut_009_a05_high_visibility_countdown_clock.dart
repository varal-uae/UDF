// DRVUT-009-A05 — High-Visibility 5-Minute Countdown Clock UI.
// Implements a prominent Material 3 countdown with responsive typography tokens,
// battery-conscious one-second updates, and accurate elapsed-time recalculation.

import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

class Drvut009A05HighVisibilityCountdownClock extends StatefulWidget {
  const Drvut009A05HighVisibilityCountdownClock({
    super.key,
    this.duration = const Duration(minutes: 5),
    this.onTick,
    this.onCompleted,
  });

  final Duration duration;
  final ValueChanged<Duration>? onTick;
  final VoidCallback? onCompleted;

  @override
  State<Drvut009A05HighVisibilityCountdownClock> createState() =>
      _Drvut009A05HighVisibilityCountdownClockState();
}

class _Drvut009A05HighVisibilityCountdownClockState
    extends State<Drvut009A05HighVisibilityCountdownClock> {
  Timer? _timer;
  late DateTime _endTime;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant Drvut009A05HighVisibilityCountdownClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _endTime = DateTime.now().add(widget.duration);
    _remaining = widget.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final next = _endTime.difference(now);
    final clamped = next.isNegative ? Duration.zero : next;
    if (!mounted) return;
    setState(() {
      _remaining = clamped;
    });
    widget.onTick?.call(clamped);
    if (clamped == Duration.zero) {
      _timer?.cancel();
      widget.onCompleted?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 360;
    final displayStyle = theme.textTheme.displayLarge?.copyWith(
      fontSize: isCompact ? 56 : 72,
      fontWeight: FontWeight.w800,
      letterSpacing: 2,
      color: colorScheme.onPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: colorScheme.onPrimary.withOpacity(0.85),
      fontWeight: FontWeight.w600,
    );

    return Semantics(
      label: 'High visibility countdown timer',
      value: _format(_remaining),
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('TIME REMAINING', style: labelStyle),
            const SizedBox(height: 8),
            Text(_format(_remaining), style: displayStyle),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: widget.duration.inSeconds == 0
                  ? 0.0
                  : _remaining.inSeconds / widget.duration.inSeconds,
              backgroundColor: colorScheme.onPrimary.withOpacity(0.24),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}
