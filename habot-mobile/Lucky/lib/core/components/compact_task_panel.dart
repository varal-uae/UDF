// EDEBS-034-12 — Least-to-Most Micro-Task Atomization Layout.
// Renders micro-tasks in a compact form to fit 6-inch screens without scrolling.
// Features a pinned top app bar timer that pulses when remaining time is < 1 minute.

import 'package:flutter/material.dart';

/// Renders compact micro-tasks with status indicators and a pinned countdown timer.
class CompactTaskPanel extends StatefulWidget {
  const CompactTaskPanel({
    super.key,
    required this.taskName,
    required this.microTasks,
    required this.durationLimit,
    required this.onTimerExpired,
  });

  final String taskName;
  final List<String> microTasks;
  final Duration durationLimit;
  final VoidCallback onTimerExpired;

  @override
  State<CompactTaskPanel> createState() => _CompactTaskPanelState();
}

class _CompactTaskPanelState extends State<CompactTaskPanel> with SingleTickerProviderStateMixin {
  late int _secondsRemaining;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationLimit.inSeconds;
    
    // Config pulse animations for countdown alerts (< 60s)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          widget.onTimerExpired();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isCriticalTime = _secondsRemaining < 60;

    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    final String timerText = '$minutes:$seconds';

    return Scaffold(
      appBar: AppBar(
        pinned: true,
        backgroundColor: cs.surfaceContainerLow,
        title: Text(widget.taskName, style: theme.textTheme.titleMedium),
        actions: [
          // Pinned Timer with optional Pulsing Alert
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: isCriticalTime
                  ? ScaleTransition(
                      scale: _pulseAnimation,
                      child: Badge(
                        label: Text(timerText),
                        backgroundColor: cs.error,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    )
                  : Badge(
                      label: Text(timerText),
                      backgroundColor: cs.secondaryContainer,
                      textColor: cs.onSecondaryContainer,
                    ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        // Enforces compact height bounding to fit 6-inch displays without overflow scrolling
        constraints: const BoxConstraints(maxHeight: 450),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Micro-Task Atomization Progress',
              style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(), // Blocks secondary scrolling
                shrinkWrap: true,
                itemCount: widget.microTasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return Container(
                    height: 52, // Safe 48dp+ tap bound
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: cs.primaryContainer,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.microTasks[index],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.check_circle_outline, color: cs.primary, size: 20),
                      ],
                    ),
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
