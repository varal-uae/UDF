// CTTEE-027-A06 — Un-bypassable execution timer overlay for specialized micro-task screens.
// Displays a persistent countdown, locks manual pause controls, and cancels at the configured threshold.

import 'dart:async';

import 'package:flutter/material.dart';

class Cttee027A06ExecutionTimer extends StatefulWidget {
  const Cttee027A06ExecutionTimer({
    super.key,
    required this.duration,
    required this.onExpired,
    this.child,
    this.initialRemaining,
  });

  final Duration duration;
  final VoidCallback onExpired;
  final Widget? child;
  final Duration? initialRemaining;

  @override
  State<Cttee027A06ExecutionTimer> createState() =>
      _Cttee027A06ExecutionTimerState();
}

class _Cttee027A06ExecutionTimerState extends State<Cttee027A06ExecutionTimer> {
  Timer? _ticker;
  late Duration _remaining;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialRemaining ?? widget.duration;
    _start();
  }

  void _start() {
    _ticker?.cancel();
    if (_remaining <= Duration.zero) {
      _handleExpiry();
      return;
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _expired) {
        return;
      }

      setState(() {
        _remaining -= const Duration(seconds: 1);
        if (_remaining <= Duration.zero) {
          _remaining = Duration.zero;
          _expired = true;
        }
      });

      if (_expired) {
        _ticker?.cancel();
        widget.onExpired();
      }
    });
  }

  void _handleExpiry() {
    if (_expired) {
      return;
    }
    _expired = true;
    widget.onExpired();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _formatted {
    final minutes =
        _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Semantics(
              liveRegion: true,
              label: 'Task countdown $_formatted remaining',
              child: Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.all(16),
                child: Material(
                  color: theme.colorScheme.errorContainer,
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatted,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
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
      ],
    );
  }
}
