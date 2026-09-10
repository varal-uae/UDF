// DRVUT-009-A14 — High-Visibility 5-Minute requestAnimationFrame Countdown Clock.
// Flutter Ticker-based countdown panel with responsive M3 typography, accessible semantics, and lifecycle-aware deadline accuracy.
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Drvut009A14CountdownClock extends StatefulWidget {
  const Drvut009A14CountdownClock({
    super.key,
    this.duration = const Duration(minutes: 5),
    this.autoStart = true,
    this.onCompleted,
  });

  final Duration duration;
  final bool autoStart;
  final VoidCallback? onCompleted;

  @override
  State<Drvut009A14CountdownClock> createState() => _Drvut009A14CountdownClockState();
}

class _Drvut009A14CountdownClockState extends State<Drvut009A14CountdownClock>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  late DateTime _deadline;
  Duration _remaining = Duration.zero;
  bool _isRunning = false;
  bool _completedNotified = false;
  int _lastRenderedSecond = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = widget.duration;
    _deadline = DateTime.now().add(widget.duration);
    _ticker = createTicker(_onTick);
    if (widget.autoStart) {
      _start();
    }
  }

  void _start() {
    if (_isRunning) return;
    _deadline = DateTime.now().add(_remaining);
    _isRunning = true;
    _completedNotified = false;
    _ticker.start();
  }

  void _pause() {
    if (!_isRunning) return;
    _remaining = _deadline.difference(DateTime.now());
    if (_remaining.isNegative) {
      _remaining = Duration.zero;
    }
    _isRunning = false;
    _ticker.stop();
  }

  void _reset() {
    _ticker.stop();
    setState(() {
      _remaining = widget.duration;
      _deadline = DateTime.now().add(widget.duration);
      _isRunning = false;
      _completedNotified = false;
      _lastRenderedSecond = -1;
    });
    if (widget.autoStart) {
      _start();
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final now = DateTime.now();
    final remaining = _deadline.difference(now);
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    final second = clamped.inSeconds;
    if (second != _lastRenderedSecond) {
      _lastRenderedSecond = second;
      setState(() {
        _remaining = clamped;
      });
    }
    if (clamped == Duration.zero && !_completedNotified) {
      _completedNotified = true;
      _isRunning = false;
      _ticker.stop();
      widget.onCompleted?.call();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRunning) {
      _onTick(Duration.zero);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
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
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isUrgent = _remaining <= const Duration(seconds: 30);
    final timeText = _format(_remaining);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth >= 720 ? 2.2 : 2.6,
          children: [
            _CountdownLane(
              title: '5-Minute Request Window',
              child: Semantics(
                liveRegion: true,
                label: 'Countdown timer',
                value: timeText,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: textTheme.displayLarge?.copyWith(
                        color: isUrgent ? colorScheme.error : colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ) ??
                      const TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
                  child: Text(timeText),
                ),
              ),
            ),
            _CountdownLane(
              title: 'Controls',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _isRunning ? _pause : _start,
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_isRunning ? 'Pause' : 'Start'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CountdownLane extends StatelessWidget {
  const _CountdownLane({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(child: Center(child: child)),
          ],
        ),
      ),
    );
  }
}
