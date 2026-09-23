// REF-046-A07 — ToastAlertDispatcher overlay card system for status updates.
// Implements a vertically stacking, non-overlapping notification dispatcher with auto-dismiss,
// pause-on-hover, explicit close button, responsive positioning, and WCAG-compliant semantic colors.

import 'dart:async';
import 'package:flutter/material.dart';

/// Execution status types mapped to semantic Material 3 colors.
enum ToastExecutionStatus { success, error, warning, info }

/// Atomic-level data model for step execution notifications.
class ToastNotificationData {
  final String stepExecutionId;
  final ToastExecutionStatus status;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const ToastNotificationData({
    required this.stepExecutionId,
    required this.status,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });
}

/// Internal state holder for active toast cards.
class _ToastEntry {
  final ToastNotificationData data;
  final VoidCallback onDismiss;
  bool isPaused;
  int remainingMs;
  Timer? timer;

  _ToastEntry({
    required this.data,
    required this.onDismiss,
    this.isPaused = false,
    this.remainingMs = 4000,
  });
}

/// Central system notification alert dispatcher.
/// Call [ToastAlertDispatcher.show] from anywhere with a valid [BuildContext].
class ToastAlertDispatcher {
  ToastAlertDispatcher._();

  static void show(
    BuildContext context,
    ToastNotificationData data, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    final toastEntry = _ToastEntry(
      data: data,
      onDismiss: () {
        entry.remove();
      },
      remainingMs: duration.inMilliseconds,
    );

    entry = OverlayEntry(
      builder: (context) => _ToastOverlayStack(
        toastEntry: toastEntry,
      ),
    );

    overlay.insert(entry);

    toastEntry.timer = Timer(duration, () {
      entry.remove();
    });
  }
}

class _ToastOverlayStack extends StatefulWidget {
  final _ToastEntry toastEntry;

  const _ToastOverlayStack({required this.toastEntry});

  @override
  State<_ToastOverlayStack> createState() => _ToastOverlayStackState();
}

class _ToastOverlayStackState extends State<_ToastOverlayStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    widget.toastEntry.timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _pauseTimer() {
    if (widget.toastEntry.isPaused) return;
    widget.toastEntry.isPaused = true;
    widget.toastEntry.timer?.cancel();
  }

  void _resumeTimer() {
    if (!widget.toastEntry.isPaused) return;
    widget.toastEntry.isPaused = false;
    widget.toastEntry.timer = Timer(
      Duration(milliseconds: widget.toastEntry.remainingMs),
      widget.toastEntry.onDismiss,
    );
  }

  Color _getBackgroundColor(BuildContext context, ToastExecutionStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case ToastExecutionStatus.success:
        return colorScheme.primaryContainer;
      case ToastExecutionStatus.error:
        return colorScheme.errorContainer;
      case ToastExecutionStatus.warning:
        return colorScheme.tertiaryContainer;
      case ToastExecutionStatus.info:
        return colorScheme.secondaryContainer;
    }
  }

  Color _getForegroundColor(BuildContext context, ToastExecutionStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case ToastExecutionStatus.success:
        return colorScheme.onPrimaryContainer;
      case ToastExecutionStatus.error:
        return colorScheme.onErrorContainer;
      case ToastExecutionStatus.warning:
        return colorScheme.onTertiaryContainer;
      case ToastExecutionStatus.info:
        return colorScheme.onSecondaryContainer;
    }
  }

  IconData _getStatusIcon(ToastExecutionStatus status) {
    switch (status) {
      case ToastExecutionStatus.success:
        return Icons.check_circle_outline_rounded;
      case ToastExecutionStatus.error:
        return Icons.error_outline_rounded;
      case ToastExecutionStatus.warning:
        return Icons.warning_amber_rounded;
      case ToastExecutionStatus.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isWideScreen = mediaQuery.size.width > 600;

    // Positioning: lower right on widescreen, full width bottom on narrow mobile
    final alignment = isWideScreen
        ? Alignment.bottomRight
        : Alignment.bottomCenter;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: mediaQuery.viewPadding.bottom + 16.0,
              left: isWideScreen ? 0.0 : 16.0,
              right: 16.0,
            ),
            child: MouseRegion(
              onEnter: (_) => _pauseTimer(),
              onExit: (_) => _resumeTimer(),
              child: GestureDetector(
                onLongPressStart: (_) => _pauseTimer(),
                onLongPressEnd: (_) => _resumeTimer(),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Semantics(
                      liveRegion: true,
                      label: 'Status Notification',
                      child: _buildCard(context, isWideScreen),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, bool isWideScreen) {
    final data = widget.toastEntry.data;
    final bgColor = _getBackgroundColor(context, data.status);
    final fgColor = _getForegroundColor(context, data.status);
    final icon = _getStatusIcon(data.status);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isWideScreen ? 380 : double.infinity,
        minWidth: isWideScreen ? 320 : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: Card(
          elevation: 6.0,
          color: bgColor,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: fgColor, size: 24.0),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.stepOutcome,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: fgColor,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      // High-contrast helper text
                      Text(
                        'ID: ${data.stepExecutionId} • ${_formatTime(data.executionTimestamp)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: fgColor.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                // Explicit close "X" button on every notification card
                InkWell(
                  onTap: () {
                    widget.toastEntry.timer?.cancel();
                    widget.toastEntry.onDismiss();
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close_rounded,
                      color: fgColor,
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// MOCK DATA & DEMO USAGE
// ============================================================================

/// Mock repository simulating server task telemetry events.
class MockTelemetryRepository {
  static List<ToastNotificationData> getMockEvents(String userId) {
    return [
      ToastNotificationData(
        stepExecutionId: 'EXEC-001',
        status: ToastExecutionStatus.success,
        executionTimestamp: DateTime.now(),
        stepOutcome: 'Draft saved successfully.',
        userId: userId,
      ),
      ToastNotificationData(
        stepExecutionId: 'EXEC-002',
        status: ToastExecutionStatus.info,
        executionTimestamp: DateTime.now(),
        stepOutcome: 'Cloud calculation completed.',
        userId: userId,
      ),
      ToastNotificationData(
        stepExecutionId: 'EXEC-003',
        status: ToastExecutionStatus.warning,
        executionTimestamp: DateTime.now(),
        stepOutcome: 'Network latency detected. Retrying...',
        userId: userId,
      ),
      ToastNotificationData(
        stepExecutionId: 'EXEC-004',
        status: ToastExecutionStatus.error,
        executionTimestamp: DateTime.now(),
        stepOutcome: 'Failed to sync telemetry logs.',
        userId: userId,
      ),
    ];
  }
}

/// Example integration widget to demonstrate the ToastAlertDispatcher.
class ToastDispatcherDemoWidget extends StatelessWidget {
  const ToastDispatcherDemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mockEvents = MockTelemetryRepository.getMockEvents('USER-99');

    return Scaffold(
      appBar: AppBar(title: const Text('REF-046-A07 Dispatcher Demo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Trigger mock status notifications:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mockEvents.map((event) {
                return FilledButton.tonal(
                  onPressed: () => ToastAlertDispatcher.show(context, event),
                  child: Text(event.stepOutcome.split('.').first),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
