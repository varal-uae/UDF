// FLADE-011-11 — Shakti Alert Panel (Critical System Breach UI).
// High-priority, un-ignorable top-level alert banner alerting users of P1 architectural
// breaches or manual overrides, with synchronized acoustic/haptic hardware triggers and telemetry tracking.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Telemetry payload required for logging Shakti critical breach events.
class ShaktiAlertTelemetryData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String? sessionId;
  final String breachReason;

  const ShaktiAlertTelemetryData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    this.sessionId,
    required this.breachReason,
  });

  Map<String, dynamic> toMap() => {
        'stepExecutionId': stepExecutionId,
        'executionStatus': executionStatus,
        'executionTimestamp': executionTimestamp.toIso8601String(),
        'stepOutcome': stepOutcome,
        'userId': userId,
        'sessionId': sessionId,
        'breachReason': breachReason,
      };
}

/// Shakti Alert Panel configuration options.
class ShaktiAlertConfig {
  final String breachCode;
  final String message;
  final String? subtext;
  final VoidCallback? onAcknowledge;
  final bool allowDismissal;
  final bool triggerHaptics;
  final bool triggerAcousticAlert;

  const ShaktiAlertConfig({
    required this.breachCode,
    required this.message,
    this.subtext,
    this.onAcknowledge,
    this.allowDismissal = false,
    this.triggerHaptics = true,
    this.triggerAcousticAlert = true,
  });
}

/// Overlay controller to display un-ignorable Shakti alert panels globally.
class ShaktiAlertManager {
  static OverlayEntry? _activeEntry;

  /// Triggers the critical breach alert banner and activates hardware feedback.
  static void show({
    required BuildContext context,
    required ShaktiAlertConfig config,
    required ShaktiAlertTelemetryData telemetryData,
    void Function(ShaktiAlertTelemetryData data)? onTelemetryLog,
  }) {
    dismiss();

    // Trigger acoustic and vibrational hardware feedback simultaneously
    if (config.triggerHaptics) {
      HapticFeedback.heavyImpact();
      HapticFeedback.vibrate();
    }
    if (config.triggerAcousticAlert) {
      SystemSound.play(SystemSoundType.alert);
    }

    // Record telemetry event
    onTelemetryLog?.call(telemetryData);

    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) return;

    _activeEntry = OverlayEntry(
      builder: (ctx) => ShaktiAlertPanel(
        config: config,
        onDismiss: dismiss,
      ),
    );

    overlayState.insert(_activeEntry!);
  }

  /// Dismisses any active critical alert entry.
  static void dismiss() {
    _activeEntry?.remove();
    _activeEntry = null;
  }
}

/// Full-width critical alert banner displayed at the very top of the screen hierarchy.
class ShaktiAlertPanel extends StatefulWidget {
  final ShaktiAlertConfig config;
  final VoidCallback onDismiss;

  const ShaktiAlertPanel({
    super.key,
    required this.config,
    required this.onDismiss,
  });

  @override
  State<ShaktiAlertPanel> createState() => _ShaktiAlertPanelState();
}

class _ShaktiAlertPanelState extends State<ShaktiAlertPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose({
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final isM3 = theme.useMaterial3;

    // Critical breach colors conforming to WCAG 2.1 AA standards for high-contrast alerts
    const criticalColor = Color(0xFFB00020);
    const darkSurfaceColor = Color(0xFF1E0004);
    const onAlertColor = Colors.white;
    const secondaryAlertTextColor = Color(0xFFFFCDD2);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        type: MaterialType.transparency,
        child: SlideTransition(
          position: _slideAnimation,
          child: Semantics(
            liveRegion: true,
            alert: true,
            namesRoute: false,
            label: 'Critical System Alert: ${widget.config.message}',
            child: Container(
              width: mediaQuery.size.width,
              padding: EdgeInsets.only(
                top: mediaQuery.padding.top + 8.0,
                bottom: 12.0,
                left: 16.0,
                right: 16.0,
              ),
              decoration: BoxDecoration(
                color: criticalColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 12.0,
                    offset: Offset(0, 6),
                  ),
                ],
                border: Border(
                  bottom: BorderSide(
                    color: Colors.amber.shade400,
                    width: 3.0,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: const BoxDecoration(
                          color: darkSurfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amberAccent,
                          size: 24.0,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'P1 ARCHITECTURAL BREACH [${widget.config.breachCode}]',
                              style: (isM3
                                      ? theme.textTheme.labelMedium
                                      : theme.textTheme.bodySmall)
                                  ?.copyWith(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              widget.config.message,
                              style: (isM3
                                      ? theme.textTheme.titleSmall
                                      : theme.textTheme.titleMedium)
                                  ?.copyWith(
                                color: onAlertColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.config.subtext != null) ...[
                              const SizedBox(height: 4.0),
                              Text(
                                widget.config.subtext!,
                                style: (isM3
                                        ? theme.textTheme.bodySmall
                                        : theme.textTheme.bodyMedium)
                                    ?.copyWith(
                                  color: secondaryAlertTextColor,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.config.allowDismissal) ...[
                        IconButton(
                          icon: const Icon(Icons.close, color: onAlertColor),
                          tooltip: 'Dismiss Breach Notification',
                          onPressed: () {
                            widget.config.onAcknowledge?.call();
                            widget.onDismiss();
                          },
                        ),
                      ],
                    ],
                  ),
                  if (!widget.config.allowDismissal &&
                      widget.config.onAcknowledge != null) ...[
                    const SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: criticalColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                        onPressed: () {
                          widget.config.onAcknowledge?.call();
                          widget.onDismiss();
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text(
                          'ACKNOWLEDGE OVERRIDE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
