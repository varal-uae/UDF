// DRVUT-009-A04 — High-Visibility 5-Minute Countdown Clock.
// Frame-loop countdown with lifecycle-aware deadline recalculation and Material 3 responsive typography.

import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Drvut009A04CountdownClock extends StatefulWidget {
  const Drvut009A04CountdownClock({
    super.key,
    this.duration = const Duration(minutes: 5),
    this.label = 'Countdown',
    this.onComplete,
    this.onTick,
  });

  final Duration duration;
  final String label;
  final VoidCallback? onComplete;
  final ValueChanged<Duration>? onTick;

  @override
  State<Drvut009A04CountdownClock> createState() => _Drvut009A04CountdownClockState();
}

class _Drvut009A04CountdownClockState extends State<Drvut009A04CountdownClock>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  late DateTime _deadline;
  Duration _remaining = Duration.zero;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = widget.duration;
    _deadline = DateTime.now().add(widget.duration);
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration _) {
    final now = DateTime.now();
    final next = _deadline.difference(now);
    if (next <= Duration.zero) {
      if (mounted) {
        setState(() => _remaining = Duration.zero);
      }
      if (!_completed) {
        _completed = true;
        widget.onComplete?.call();
      }
      _ticker.stop();
      return;
    }
    if (mounted && next.inMilliseconds != _remaining.inMilliseconds) {
      setState(() => _remaining = next);
      widget.onTick?.call(next);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_completed) {
      _onTick(Duration.zero);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    super.dispose();
  }

  String _formattedRemaining() {
    final totalSeconds = _remaining.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final text = _formattedRemaining();

    return Semantics(
      label: '${widget.label}: $text remaining',
      liveRegion: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: (textTheme.displayMedium ?? textTheme.headlineLarge)?.copyWith(
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
