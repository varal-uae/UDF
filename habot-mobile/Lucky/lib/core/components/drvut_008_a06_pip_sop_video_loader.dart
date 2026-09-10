// DRVUT-008-A06 — Picture-in-Picture Under-60s Task SOP Micro-Video Loader.
// Loads short SOP training videos asynchronously for active repair tasks and gates form fields until playback completes.

import 'dart:async';
import 'package:flutter/material.dart';

enum SopVideoSyncStatus { pending, synced, conflict, failed }

class SopVideoTask {
  final String id;
  final String title;
  final Uri videoUri;
  final Duration duration;
  final SopVideoSyncStatus syncStatus;
  final DateTime? lastSyncDate;
  final Duration? syncDuration;
  final int syncConflicts;

  SopVideoTask({
    required this.id,
    required this.title,
    required this.videoUri,
    required this.duration,
    this.syncStatus = SopVideoSyncStatus.pending,
    this.lastSyncDate,
    this.syncDuration,
    this.syncConflicts = 0,
  });

  bool get isUnder60Seconds => duration <= const Duration(seconds: 60);
}

class SopVideoCompletionEvent {
  final String taskId;
  final DateTime completedAt;
  final Duration watchedDuration;

  SopVideoCompletionEvent({
    required this.taskId,
    required this.completedAt,
    required this.watchedDuration,
  });
}

typedef SopVideoTaskLoader = Future<SopVideoTask> Function(String activeTaskId);
typedef SopVideoCompletionCallback = void Function(SopVideoCompletionEvent event);

class SopMicroVideoLoader extends StatefulWidget {
  final String activeTaskId;
  final SopVideoTaskLoader loadTask;
  final Widget child;
  final SopVideoCompletionCallback? onCompletion;
  final double aspectRatio;

  const SopMicroVideoLoader({
    super.key,
    required this.activeTaskId,
    required this.loadTask,
    required this.child,
    this.onCompletion,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<SopMicroVideoLoader> createState() => _SopMicroVideoLoaderState();
}

class _SopMicroVideoLoaderState extends State<SopMicroVideoLoader> {
  late Future<SopVideoTask> _taskFuture;
  bool _playbackComplete = false;
  Timer? _progressTimer;
  Duration _watched = Duration.zero;

  @override
  void initState() {
    super.initState();
    _taskFuture = widget.loadTask(widget.activeTaskId);
  }

  @override
  void didUpdateWidget(covariant SopMicroVideoLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTaskId != widget.activeTaskId) {
      _playbackComplete = false;
      _watched = Duration.zero;
      _progressTimer?.cancel();
      _taskFuture = widget.loadTask(widget.activeTaskId);
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startPlayback(SopVideoTask task) {
    _progressTimer?.cancel();
    _playbackComplete = false;
    _watched = Duration.zero;
    const tick = Duration(milliseconds: 250);
    _progressTimer = Timer.periodic(tick, (timer) {
      if (!mounted) return;
      setState(() {
        _watched += tick;
      });
      if (_watched >= task.duration) {
        timer.cancel();
        _markComplete(task);
      }
    });
  }

  void _markComplete(SopVideoTask task) {
    if (_playbackComplete) return;
    setState(() {
      _playbackComplete = true;
      _progressTimer?.cancel();
    });
    widget.onCompletion?.call(
      SopVideoCompletionEvent(
        taskId: task.id,
        completedAt: DateTime.now(),
        watchedDuration: _watched,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SopVideoTask>(
      future: _taskFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShell(
            context,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return _buildShell(
            context,
            child: Text('Unable to load SOP video: ${snapshot.error}'),
          );
        }
        final task = snapshot.data!;
        if (!task.isUnder60Seconds) {
          return _buildShell(
            context,
            child: const Text('SOP video exceeds 60-second limit.'),
          );
        }
        return _buildLoaded(context, task);
      },
    );
  }

  Widget _buildShell(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, SopVideoTask task) {
    final theme = Theme.of(context);
    final double progress = task.duration.inMilliseconds == 0
        ? 0.0
        : (_watched.inMilliseconds / task.duration.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();

    return _buildShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SOP Micro-Video Loader',
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: theme.colorScheme.surface,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (!_playbackComplete)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: LinearProgressIndicator(value: progress),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _StatusChip(
                        label: '${task.duration.inSeconds}s',
                        color: theme.colorScheme.secondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              TextButton.icon(
                onPressed: _playbackComplete ? null : () => _startPlayback(task),
                icon: Icon(_playbackComplete ? Icons.check_circle : Icons.play_arrow),
                label: Text(_playbackComplete ? 'Completed' : 'Play'),
              ),
            ],
          ),
          if (!_playbackComplete) ...[
            const SizedBox(height: 8),
            Text(
              'Complete the SOP video to enable task fields.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 12),
          AbsorbPointer(
            absorbing: !_playbackComplete,
            child: AnimatedOpacity(
              opacity: _playbackComplete ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
