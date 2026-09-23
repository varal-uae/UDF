// REF-046-A08 — ToastAlertDispatcher & Overlay Notification Card System.
// Provides a configurable, auto-dismissing overlay card system for status updates with pause-on-hover/tap, explicit close button, responsive positioning, and Material 3 styling.

import 'dart:async';
import 'package:flutter/material.dart';

/// Atomic-level data model for notification execution tracking.
class ToastExecutionData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const ToastExecutionData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });
}

/// Semantic status types mapping to Material 3 color schemes.
enum ToastStatus { success, error, warning, info }

/// Internal entry representing a single active toast card.
class _ToastEntry {
  final String id;
  final String message;
  final ToastStatus status;
  final ToastExecutionData? telemetryData;
  final OverlayEntry overlayEntry;
  final Duration timeout;
  bool isPaused;
  int elapsedMs;
  Timer? timer;

  _ToastEntry({
    required this.id,
    required this.message,
    required this.status,
    required this.telemetryData,
    required this.overlayEntry,
    required this.timeout,
    this.isPaused = false,
    this.elapsedMs = 0,
    this.timer,
  });
}

/// Central system notification alert dispatcher.
/// Renders floating notification cards over all content layers.
/// Auto-cleans expired memory logs after blocks slide off-screen.
class ToastAlertDispatcher {
  ToastAlertDispatcher._();
  static final ToastAlertDispatcher instance = ToastAlertDispatcher._();

  final List<_ToastEntry> _activeToasts = [];
  static const Duration _staggerDelay = Duration(milliseconds: 80);
  static const double _cardHeight = 64.0;
  static const double _cardSpacing = 12.0;

  /// Displays a status notification box.
  /// [timeout] configures the auto-dismiss duration.
  void show({
    required BuildContext context,
    required String message,
    ToastStatus status = ToastStatus.info,
    Duration timeout = const Duration(seconds: 4),
    ToastExecutionData? telemetryData,
  }) {
    final overlay = Overlay.of(context);
    final isWideScreen = MediaQuery.of(context).size.width >= 600;

    late OverlayEntry entry;
    final entryId = UniqueKey().toString();

    entry = OverlayEntry(
      builder: (context) => _ToastOverlayCard(
        message: message,
        status: status,
        isWideScreen: isWideScreen,
        index: _activeToasts.length,
        onClose: () => dismiss(entryId),
        onHoverEnter: () => _pauseTimer(entryId),
        onHoverExit: () => _resumeTimer(entryId),
      ),
    );

    final toastEntry = _ToastEntry(
      id: entryId,
      message: message,
      status: status,
      telemetryData: telemetryData ?? _getMockTelemetry(),
      overlayEntry: entry,
      timeout: timeout,
    );

    _activeToasts.add(toastEntry);
    overlay.insert(entry);
    _startDismissTimer(toastEntry);
  }

  void _startDismissTimer(_ToastEntry entry) {
    entry.timer?.cancel();
    entry.timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!entry.isPaused) {
        entry.elapsedMs += 100;
        if (entry.elapsedMs >= entry.timeout.inMilliseconds) {
          dismiss(entry.id);
        }
      }
    });
  }

  void _pauseTimer(String id) {
    final entry = _activeToasts.where((e) => e.id == id).firstOrNull;
    if (entry != null) entry.isPaused = true;
  }

  void _resumeTimer(String id) {
    final entry = _activeToasts.where((e) => e.id == id).firstOrNull;
    if (entry != null) entry.isPaused = false;
  }

  /// Dismisses a specific notification card and cleans up memory logs.
  void dismiss(String id) {
    final index = _activeToasts.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final entry = _activeToasts[index];
    entry.timer?.cancel();
    entry.overlayEntry.remove();
    _activeToasts.removeAt(index);

    // Rebuild remaining overlays to update vertical stacking positions
    for (var i = 0; i < _activeToasts.length; i++) {
      _activeToasts[i].overlayEntry.markNeedsBuild();
    }
  }

  /// Cleans up all active toasts (used for self-chasing memory cleanup).
  void disposeAll() {
    for (final entry in List.from(_activeToasts)) {
      dismiss(entry.id);
    }
  }

  ToastExecutionData _getMockTelemetry() {
    return const ToastExecutionData(
      stepExecutionId: 'STEP-EXEC-9999',
      executionStatus: 'Pass',
      executionTimestamp: null as dynamic,
      stepOutcome: 'Auto-cleanup of UI.',
      userId: 'USER-MOCK-001',
    );
  }
}

class _ToastOverlayCard extends StatefulWidget {
  final String message;
  final ToastStatus status;
  final bool isWideScreen;
  final int index;
  final VoidCallback onClose;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;

  const _ToastOverlayCard({
    required this.message,
    required this.status,
    required this.isWideScreen,
    required this.index,
    required this.onClose,
    required this.onHoverEnter,
    required this.onHoverExit,
  });

  @override
  State<_ToastOverlayCard> createState() => _ToastOverlayCardState();
}

class _ToastOverlayCardState extends State<_ToastOverlayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Slide up from screen borders quietly
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.index * ToastAlertDispatcher._staggerDelay.inMilliseconds), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor(ColorScheme colors) {
    switch (widget.status) {
      case ToastStatus.success:
        return colors.primary;
      case ToastStatus.error:
        return colors.error;
      case ToastStatus.warning:
        return colors.tertiary;
      case ToastStatus.info:
        return colors.secondary;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
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
    final colors = theme.colorScheme;
    final statusColor = _getStatusColor(colors);

    // Responsive UX/UI Design: full width on narrow mobile grids, lower right on widescreen layouts
    return Positioned(
      bottom: 24.0 + (widget.index * (ToastAlertDispatcher._cardHeight + ToastAlertDispatcher._cardSpacing)),
      left: widget.isWideScreen ? null : 16.0,
      right: 16.0,
      child: widget.isWideScreen
          ? Align(
              alignment: Alignment.bottomRight,
              child: _buildCard(theme, colors, statusColor),
            )
          : _buildCard(theme, colors, statusColor),
    );
  }

  Widget _buildCard(ThemeData theme, ColorScheme colors, Color statusColor) {
    return MouseRegion(
      onEnter: (_) => widget.onHoverEnter(),
      onExit: (_) => widget.onHoverExit(),
      child: GestureDetector(
        onTapDown: (_) => widget.onHoverEnter(),
        onTapUp: (_) => widget.onHoverExit(),
        onTapCancel: () => widget.onHoverExit(),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: widget.isWideScreen ? 360 : double.infinity,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(), color: statusColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Standardized Must Be Done: Small, explicit close "X" button
                    InkWell(
                      onTap: widget.onClose,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: colors.onSurfaceVariant.withOpacity(0.7),
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
}