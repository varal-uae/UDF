// SSELC-023-A02 — Split-Screen Byt Deconstruction Mobile Stacking Component.
// Implements mobile-first single-action micro-task panels with countdown timer, elevation shifts, and constrained viewport bounds to prevent cognitive overload.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data representing atomic-level configuration parameters for the Byt task.
class _MockBytData {
  final String taskId;
  final String title;
  final String placeholderText;
  final String expectedFormat;
  final Duration initialDuration;

  const _MockBytData({
    required this.taskId,
    required this.title,
    required this.placeholderText,
    required this.expectedFormat,
    required this.initialDuration,
  });
}

const List<_MockBytData> _mockTasks = [
  _MockBytData(
    taskId: 'BYT-001',
    title: 'Verify Document ID',
    placeholderText: 'e.g., DOC-837492-X',
    expectedFormat: 'DOC-XXXXXX-X',
    initialDuration: Duration(minutes: 2),
  ),
  _MockBytData(
    taskId: 'BYT-002',
    title: 'Confirm Applicant Name',
    placeholderText: 'e.g., John A. Doe',
    expectedFormat: 'First M. Last',
    initialDuration: Duration(minutes: 1, seconds: 30),
  ),
];

/// Main deconstructed split-screen widget enforcing single-action constraints.
class SplitScreenBytDeconstruction extends StatefulWidget {
  const SplitScreenBytDeconstruction({super.key});

  @override
  State<SplitScreenBytDeconstruction> createState() => _SplitScreenBytDeconstructionState();
}

class _SplitScreenBytDeconstructionState extends State<SplitScreenBytDeconstruction> {
  int _currentTaskIndex = 0;
  bool _isLocked = false;

  void _onTaskCompleted() {
    if (_currentTaskIndex < _mockTasks.length - 1) {
      setState(() {
        _currentTaskIndex++;
        _isLocked = false;
      });
    } else {
      // All tasks completed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All micro-tasks completed successfully.')),
      );
    }
  }

  void _onTimerExpired() {
    setState(() {
      _isLocked = true;
    });
    // Auto-escalation logic would trigger here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Time expired. Task locked and auto-escalated.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTask = _mockTasks[_currentTaskIndex];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Observation Surface with sharp structural contrast
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 2.0,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task ${_currentTaskIndex + 1} of ${_mockTasks.length}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentTask.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Dynamic vertical shifting spacer
            const Spacer(flex: 1),
            // Action Card with distinct surface elevation shift
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 8.0,
                  surfaceTintColor: theme.colorScheme.surfaceTint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: _isLocked
                      ? const _LockedEscalationView()
                      : _BytActionPanel(
                          task: currentTask,
                          onCompleted: _onTaskCompleted,
                          onTimerExpired: _onTimerExpired,
                        ),
                ),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

class _BytActionPanel extends StatefulWidget {
  final _MockBytData task;
  final VoidCallback onCompleted;
  final VoidCallback onTimerExpired;

  const _BytActionPanel({
    required this.task,
    required this.onCompleted,
    required this.onTimerExpired,
  });

  @override
  State<_BytActionPanel> createState() => _BytActionPanelState();
}

class _BytActionPanelState extends State<_BytActionPanel> {
  late Duration _timeRemaining;
  Timer? _timer;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.task.initialDuration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.inSeconds <= 1) {
        timer.cancel();
        widget.onTimerExpired();
      } else {
        setState(() {
          _timeRemaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Enforce 360px mobile viewport constraint logic block
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Visible countdown timer
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _timeRemaining.inSeconds < 30
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _formatDuration(_timeRemaining),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: _timeRemaining.inSeconds < 30
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Thumb-friendly input with placeholder text illustrating expected format
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Input Data',
                hintText: widget.task.placeholderText,
                helperText: 'Expected format: ${widget.task.expectedFormat}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
              ),
              // Touch-locked bounds executing seamlessly
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 32),
            // Single thumb-friendly action button
            FilledButton.icon(
              onPressed: () {
                _timer?.cancel();
                widget.onCompleted();
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirm & Proceed'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedEscalationView extends StatelessWidget {
  const _LockedEscalationView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_clock,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Session Locked',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This task has been escalated due to inactivity.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
