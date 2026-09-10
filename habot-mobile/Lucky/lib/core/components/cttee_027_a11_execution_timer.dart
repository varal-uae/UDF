// CTTEE-027-A11 — Un-bypassable execution countdown overlay for specialized micro-task screens.
// Enforces a non-pausable five-minute visual timer, blocks submissions at expiry, and exposes a Material 3 overlay.

import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

class Cttee027A11ExecutionTimer extends StatefulWidget {
  const Cttee027A11ExecutionTimer({
    super.key,
    this.duration = const Duration(minutes: 5),
    required this.child,
    this.onExpired,
    this.onTick,
  });

  final Duration duration;
  final Widget child;
  final VoidCallback? onExpired;
  final ValueChanged<Duration>? onTick;

  @override
  State<Cttee027A11ExecutionTimer> createState() => _Cttee027A11ExecutionTimerState();
}

class _Cttee027A11ExecutionTimerState extends State<Cttee027A11ExecutionTimer>
    with WidgetsBindingObserver {
  Timer? _timer;
  late DateTime _endTime;
  late Duration _remaining;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = widget.duration;
    _endTime = DateTime.now().add(widget.duration);
    _start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sync();
    }
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _sync());
  }

  void _sync() {
    if (!mounted) return;
    final next = _endTime.difference(DateTime.now());
    if (next <= Duration.zero) {
      setState(() {
        _remaining = Duration.zero;
        _expired = true;
      });
      _timer?.cancel();
      widget.onExpired?.call();
      return;
    }
    setState(() => _remaining = next);
    widget.onTick?.call(_remaining);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    final timerLabel = '$minutes:$seconds';

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _expired,
          child: widget.child,
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_expired,
            child: AnimatedOpacity(
              opacity: _expired ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: ColoredBox(
                color: theme.colorScheme.scrim.withOpacity(0.72),
                child: Center(
                  child: Semantics(
                    liveRegion: true,
                    label: 'Execution timer expired. Submissions are locked.',
                    child: Card(
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_clock, color: theme.colorScheme.onErrorContainer, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Time-box expired',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Task submissions are locked at the five-minute threshold.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(999),
            color: _expired ? theme.colorScheme.error : theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                timerLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: _expired ? theme.colorScheme.onError : theme.colorScheme.onPrimaryContainer,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
