// REF-046-A15 — ToastAlertDispatcher Overlay Card System.
// Provides a centralized notification dispatcher that renders animated, color-coded status cards over all content layers without interrupting active workflows. Supports pause-on-hover, auto-dismiss with memory cleanup, full-width mobile layout, and bottom-right desktop positioning.

import 'dart:async';
import 'package:flutter/material.dart';

/// Represents the semantic state of a toast notification.
enum ToastStatus {
  success,
  error,
  warning,
  info,
}

/// Data model for a single toast notification.
class ToastNotification {
  final String id;
  final String message;
  final ToastStatus status;
  final DateTime timestamp;

  const ToastNotification({
    required this.id,
    required this.message,
    required this.status,
    required this.timestamp,
  });
}

/// Central system notification alert dispatcher.
/// Integrates into the main application layout via [ToastAlertDispatcher.wrap].
class ToastAlertDispatcher extends StatefulWidget {
  final Widget child;

  const ToastAlertDispatcher({
    super.key,
    required this.child,
  });

  /// Wraps the root application widget to provide global overlay access.
  static Widget wrap({required Widget child}) {
    return ToastAlertDispatcher(child: child);
  }

  /// Shows a toast notification from anywhere in the widget tree.
  static void show(
    BuildContext context, {
    required String message,
    ToastStatus status = ToastStatus.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final state = context.findAncestorStateOfType<_ToastAlertDispatcherState>();
    if (state != null) {
      final notification = ToastNotification(
        id: UniqueKey().toString(),
        message: message,
        status: status,
        timestamp: DateTime.now(),
      );
      state._addNotification(notification, duration);
    }
  }

  @override
  State<ToastAlertDispatcher> createState() => _ToastAlertDispatcherState();
}

class _ToastAlertDispatcherState extends State<ToastAlertDispatcher> {
  final List<_ActiveToast> _activeToasts = [];

  void _addNotification(ToastNotification notification, Duration duration) {
    setState(() {
      _activeToasts.add(_ActiveToast(
        notification: notification,
        duration: duration,
        onDismiss: () => _removeNotification(notification.id),
      ));
    });
  }

  void _removeNotification(String id) {
    if (!mounted) return;
    setState(() {
      // Self-chasing: clean up expired notification card memory logs automatically
      _activeToasts.removeWhere((toast) => toast.notification.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;
                  return _ToastOverlay(
                    toasts: _activeToasts,
                    isWideScreen: isWideScreen,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveToast {
  final ToastNotification notification;
  final Duration duration;
  final VoidCallback onDismiss;

  _ActiveToast({
    required this.notification,
    required this.duration,
    required this.onDismiss,
  });
}

class _ToastOverlay extends StatelessWidget {
  final List<_ActiveToast> toasts;
  final bool isWideScreen;

  const _ToastOverlay({
    required this.toasts,
    required this.isWideScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (toasts.isEmpty) return const SizedBox.shrink();

    // Responsive UX/UI Design:
    // Mobile: stretch full width across narrow display grids (bottom center).
    // Widescreen/Desktop: position inside lower right screen zones, stack vertically.
    return Align(
      alignment: isWideScreen ? Alignment.bottomRight : Alignment.bottomCenter,
      child: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWideScreen ? 380 : double.infinity,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isWideScreen ? CrossAxisAlignment.end : CrossAxisAlignment.stretch,
            children: toasts.map((toast) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _ToastCard(
                  activeToast: toast,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatefulWidget {
  final _ActiveToast activeToast;

  const _ToastCard({required this.activeToast});

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;
  bool _isPaused = false;
  Duration _remainingDuration = Duration.zero;
  Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _remainingDuration = widget.activeToast.duration;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Elegant status blocks slide up from screen borders quietly
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
    _startTimer();
  }

  void _startTimer() {
    _stopwatch = Stopwatch()..start();
    _dismissTimer = Timer(_remainingDuration, _triggerDismiss);
  }

  void _pauseTimer() {
    if (_isPaused || _dismissTimer == null) return;
    setState(() => _isPaused = true);
    _dismissTimer?.cancel();
    _stopwatch.stop();
    _remainingDuration -= _stopwatch.elapsed;
    if (_remainingDuration.isNegative) _remainingDuration = Duration.zero;
  }

  void _resumeTimer() {
    if (!_isPaused) return;
    setState(() => _isPaused = false);
    if (_remainingDuration > Duration.zero) {
      _startTimer();
    } else {
      _triggerDismiss();
    }
  }

  void _triggerDismiss() {
    _dismissTimer?.cancel();
    _animController.reverse().then((_) {
      if (mounted) {
        widget.activeToast.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _stopwatch.stop();
    _animController.dispose();
    super.dispose();
  }

  Color _getStatusColor(ThemeData theme) {
    switch (widget.activeToast.notification.status) {
      case ToastStatus.success:
        return theme.colorScheme.primary;
      case ToastStatus.error:
        return theme.colorScheme.error;
      case ToastStatus.warning:
        return theme.colorScheme.tertiary;
      case ToastStatus.info:
        return theme.colorScheme.secondary;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.activeToast.notification.status) {
      case ToastStatus.success:
        return Icons.check_circle_outline;
      case ToastStatus.error:
        return Icons.error_outline;
      case ToastStatus.warning:
        return Icons.warning_amber_rounded;
      case ToastStatus.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(theme);

    // Mistake-Proofing (Poka-Yoke):
    // Pause the automatic countdown timer loop if a user holds their finger or hovers over notification cards.
    return MouseRegion(
      onEnter: (_) => _pauseTimer(),
      onExit: (_) => _resumeTimer(),
      child: GestureDetector(
        onLongPressStart: (_) => _pauseTimer(),
        onLongPressEnd: (_) => _resumeTimer(),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border(left: BorderSide(color: statusColor, width: 4.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _getStatusIcon(),
                      color: statusColor,
                      size: 24.0,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // High-contrast helper text / Material TextFields standards applied to typography
                          Text(
                            widget.activeToast.notification.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            _formatTimestamp(widget.activeToast.notification.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Always include a small, explicit close "X" button on every notification card.
                    InkWell(
                      onTap: _triggerDismiss,
                      borderRadius: BorderRadius.circular(12.0),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          size: 18.0,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

// --- MOCK DATA & DEMONSTRATION USAGE ---

/// Mock repository simulating server task tools linking to client layouts.
class MockServerTaskRepository {
  static Future<void> simulateDraftSave(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      ToastAlertDispatcher.show(
        context,
        message: 'Draft saved successfully to cloud.',
        status: ToastStatus.success,
      );
    }
  }

  static Future<void> simulateComplexCalculation(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 4));
    if (context.mounted) {
      ToastAlertDispatcher.show(
        context,
        message: 'GCP BigQuery calculation finished. Results updated.',
        status: ToastStatus.info,
        duration: const Duration(seconds: 6),
      );
    }
  }

  static void simulateError(BuildContext context) {
    ToastAlertDispatcher.show(
      context,
      message: 'Failed to sync telemetry data. Please retry.',
      status: ToastStatus.error,
    );
  }

  static void simulateWarning(BuildContext context) {
    ToastAlertDispatcher.show(
      context,
      message: 'Network connection is unstable.',
      status: ToastStatus.warning,
    );
  }
}
