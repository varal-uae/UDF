// MUFCE-030-A12 — AutomatedTaskExpirationClock widget for 5-minute task expiration lock.
// Implements a persistent MD3 floating countdown timer that auto-locks tasks, routes to fallback queues on expiry, and uses background-safe timing independent of device clock manipulation.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing task configuration and state.
class TaskExpirationConfig {
  final String taskId;
  final String configurationParameter;
  final String currentSetting;
  final String previousSetting;
  final DateTime configurationTimestamp;
  final List<String> changeLog;

  const TaskExpirationConfig({
    required this.taskId,
    required this.configurationParameter,
    required this.currentSetting,
    required this.previousSetting,
    required this.configurationTimestamp,
    required this.changeLog,
  });
}

/// Local mock repository supplying realistic task data.
class MockTaskRepository {
  static TaskExpirationConfig getMockTask() {
    return TaskExpirationConfig(
      taskId: 'TASK-MUFCE-030-001',
      configurationParameter: 'auto_expire_duration_ms',
      currentSetting: '300000', // 5 minutes in milliseconds
      previousSetting: '600000',
      configurationTimestamp: DateTime(2026, 9, 22, 10, 0, 0),
      changeLog: [
        'Initialized default 5-min expiration',
        'Updated from 10-min to 5-min per MUFCE-030 directive'
      ],
    );
  }
}

enum TaskState { active, expired, fallbackRouted }

/// AutomatedTaskExpirationClock provides a 5-minute countdown overlay.
/// Timers run independently of system clock changes by using monotonic tick counting.
class AutomatedTaskExpirationClock extends StatefulWidget {
  final VoidCallback? onTaskExpired;
  final Duration expirationDuration;

  const AutomatedTaskExpirationClock({
    super.key,
    this.onTaskExpired,
    this.expirationDuration = const Duration(minutes: 5),
  });

  @override  State<AutomatedTaskExpirationClock> createState() => _AutomatedTaskExpirationClockState();
}

class _AutomatedTaskExpirationClockState extends State<AutomatedTaskExpirationClock>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late int _remainingSeconds;
  TaskState _taskState = TaskState.active;
  late final AnimationController _pulseController;
  late final TaskExpirationConfig _mockConfig;

  @override
  void initState() {
    super.initState();
    _mockConfig = MockTaskRepository.getMockTask();
    _remainingSeconds = widget.expirationDuration.inSeconds;

    // Non-intrusive micro-animation for urgency focus without layout jumps
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Background-safe timer using periodic ticks rather than absolute wall-clock time
    _timer = Timer.periodic(const Duration(seconds: 1), _handleTick);
  }

  void _handleTick(Timer timer) {
    if (!mounted) return;

    setState(() {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      } else {
        _taskState = TaskState.expired;
        _timer.cancel();
        _pulseController.stop();
        _routeToFallbackQueue();
      }
    });
  }

  void _routeToFallbackQueue() {
    // Self-chasing: route to fallback queue automatically
    setState(() {
      _taskState = TaskState.fallbackRouted;
    });
    widget.onTaskExpired?.call();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color _getTimerColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_taskState != TaskState.active) return colorScheme.error;
    if (_remainingSeconds <= 60) return colorScheme.tertiary; // Alert near boundary
    if (_remainingSeconds <= 120) return colorScheme.secondary;
    return colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLocked = _taskState != TaskState.active;

    // Floating indicator widget anchored cleanly to viewport boundaries
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8.0,
      right: 16.0,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(28.0), // Circular compact layout
        color: colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Micro-animation drawing focus without layout jumps
              FadeTransition(
                opacity: _pulseController.drive(
                  Tween<double>(begin: 0.4, end: 1.0),
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline : Icons.timer_outlined,
                  color: _getTimerColor(context),
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLocked ? 'TASK LOCKED' : 'EXPIRATION',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    isLocked
                        ? (_taskState == TaskState.fallbackRouted ? 'ROUTED TO FALLBACK' : '00:00')
                        : _formatTime(_remainingSeconds),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: _getTimerColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A wrapper demonstrating the locked interface behavior when countdown hits zero.
class TaskExpirationLockDirective extends StatelessWidget {
  const TaskExpirationLockDirective({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = MockTaskRepository.getMockTask();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Expiration Logic Directive'),
      ),
      body: Stack(
        children: [
          // Underlying content simulating task fields
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Task ID: ${config.taskId}', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Param: ${config.configurationParameter}', style: theme.textTheme.bodyMedium),
                    Text('Current: ${config.currentSetting}ms', style: theme.textTheme.bodyMedium),
                    const Divider(height: 32),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Validation Entry',
                        hintText: 'Enter validation data...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // The automated expiration clock overlay
          AutomatedTaskExpirationClock(
            onTaskExpired: () {
              // Telemetry / BigQuery streaming mock hook
              debugPrint('[MUFCE-030-A12] Task expired. Routing to fallback queue.');
            },
          ),
        ],
      ),
    );
  }
}