// DRVUT-009-A09 — Pausable 5-Minute High-Visibility Countdown Clock.
// Provides a responsive Material 3 countdown widget that pauses/resumes with task state and reports timing telemetry.

import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PausableCountdownClock extends StatefulWidget {
  const PausableCountdownClock({
    super.key,
    this.totalDuration = const Duration(minutes: 5),
    this.paused = false,
    this.autoStart = true,
    this.onTick,
    this.onCompleted,
    this.onPause,
    this.onResume,
    this.semanticLabel = 'Task countdown timer',
  });

  final Duration totalDuration;
  final bool paused;
  final bool autoStart;
  final ValueChanged<Duration>? onTick;
  final VoidCallback? onCompleted;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final String semanticLabel;

  @override
  State<PausableCountdownClock> createState() => _PausableCountdownClockState();
}

class _PausableCountdownClockState extends State<PausableCountdownClock>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  final Stopwatch _stopwatch = Stopwatch();
  Duration _accumulated = Duration.zero;
  Duration _remaining = Duration.zero;
  bool _isRunning = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = widget.totalDuration;
    _ticker = createTicker(_handleTick);
    if (widget.autoStart && !widget.paused) {
      _start();
    }
  }

  @override
  void didUpdateWidget(covariant PausableCountdownClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalDuration != widget.totalDuration) {
      _accumulated = Duration.zero;
      _remaining = widget.totalDuration;
      _completed = false;
      _stopwatch.reset();
      if (_isRunning) {
        _stopwatch.start();
      }
    }
    if (oldWidget.paused != widget.paused) {
      if (widget.paused) {
        _pause();
      } else {
        _resume();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isRunning && !_ticker.isActive) {
        _ticker.start();
      }
      _handleTick(Duration.zero);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_ticker.isActive) {
        _ticker.stop();
      }
    }
  }

  void _start() {
    if (_completed || _isRunning) return;
    _stopwatch
      ..reset()
      ..start();
    _isRunning = true;
    if (!_ticker.isActive) {
      _ticker.start();
    }
    widget.onResume?.call();
    _handleTick(Duration.zero);
  }

  void _pause() {
    if (!_isRunning) return;
    _accumulated += _stopwatch.elapsed;
    _stopwatch
      ..stop()
      ..reset();
    _isRunning = false;
    if (_ticker.isActive) {
      _ticker.stop();
    }
    widget.onPause?.call();
    _handleTick(Duration.zero);
  }

  void _resume() {
    if (widget.paused || _completed || _isRunning) return;
    _start();
  }

  void _handleTick(Duration _) {
    if (!mounted || _completed) return;
    final elapsed = _accumulated + (_isRunning ? _stopwatch.elapsed : Duration.zero);
    final remaining = widget.totalDuration - elapsed;
    if (remaining <= Duration.zero) {
      _complete();
      return;
    }
    if (remaining != _remaining) {
      setState(() => _remaining = remaining);
    }
    widget.onTick?.call(remaining);
  }

  void _complete() {
    _completed = true;
    _isRunning = false;
    _remaining = Duration.zero;
    if (_ticker.isActive) {
      _ticker.stop();
    }
    _stopwatch
      ..stop()
      ..reset();
    if (mounted) {
      setState(() {});
    }
    widget.onCompleted?.call();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textStyle = theme.textTheme.displayLarge?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w800,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final progress = widget.totalDuration.inMilliseconds == 0
        ? 0.0
        : (_remaining.inMilliseconds / widget.totalDuration.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();

    return Semantics(
      liveRegion: true,
      label: '${widget.semanticLabel}: ${_formatDuration(_remaining)} remaining',
      child: Card(
        color: colorScheme.primaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Text(
                  _formatDuration(_remaining),
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.onPrimaryContainer.withOpacity(0.16),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
