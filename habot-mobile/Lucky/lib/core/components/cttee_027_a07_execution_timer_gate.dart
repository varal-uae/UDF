// CTTEE-027-A07 — Un-bypassable visual countdown gate for specialized micro-task screens.
// Locks task interactions when the persistent timer reaches 0:00 and fires an expiry callback.

import 'dart:async';
import 'package:flutter/material.dart';

class ExecutionTimerGate extends StatefulWidget {
  const ExecutionTimerGate({
    super.key,
    required this.duration,
    required this.child,
    this.onExpired,
    this.expiredMessage = 'Task time has expired. Submissions are locked.',
  });

  final Duration duration;
  final Widget child;
  final VoidCallback? onExpired;
  final String expiredMessage;

  @override
  State<ExecutionTimerGate> createState() => _ExecutionTimerGateState();
}

class _ExecutionTimerGateState extends State<ExecutionTimerGate> {
  late Duration _remaining;
  Timer? _timer;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ExecutionTimerGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _remaining = widget.duration;
      _expired = false;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _expired) return;
      setState(() {
        final next = _remaining - const Duration(seconds: 1);
        if (next <= Duration.zero) {
          _remaining = Duration.zero;
          _expired = true;
          _timer?.cancel();
          widget.onExpired?.call();
        } else {
          _remaining = next;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final label = _expired ? 'Time expired' : '${_format(_remaining)} remaining';

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _expired,
          child: widget.child,
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Semantics(
            liveRegion: true,
            label: label,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _expired ? colorScheme.errorContainer : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _expired ? colorScheme.error : colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _expired ? Icons.lock_clock : Icons.timer_outlined,
                    size: 18,
                    color: _expired ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _format(_remaining),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _expired ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expired)
          Positioned.fill(
            child: ColoredBox(
              color: colorScheme.scrim.withAlpha(166),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_clock, size: 40, color: colorScheme.error),
                        const SizedBox(height: 12),
                        Text(
                          widget.expiredMessage,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
