// FEBFL-037-A10 — Centralized Reusable Action Modal & Confirmation Templates.
// Implements responsive Material 3 dialogs and overlay sheets with fluid phone viewport scaling, scale-up entrance animations, backdrop dismissal safety, tonal alert containers, and poka-yoke confirmation toggles.

import 'package:flutter/material.dart';

/// Alert severity tier for styling confirmation overlays.
enum ModalAlertTier {
  standard,
  informational,
  warning,
  highAlert,
}

/// Execution telemetry payload captured on modal interaction.
class ModalExecutionAudit {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const ModalExecutionAudit({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });
}

/// Displays an animated scale-up modal overlay configured for responsive mobile & tablet displays.
Future<T?> showActionModalFEBFL037A10<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  String? confirmLabel,
  String? cancelLabel,
  ModalAlertTier alertTier = ModalAlertTier.standard,
  bool requirePokaYokeToggle = false,
  String pokaYokeText = 'I confirm this action and understand its permanent impact.',
  bool barrierDismissible = true,
  String userId = 'system_user',
  void Function(ModalExecutionAudit audit)? onAuditLog,
  Future<bool> Function()? onConfirm,
}) {
  final String stepExecutionId = 'EXE-${DateTime.now().millisecondsSinceEpoch}';

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.54),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return ActionModalDialogFEBFL037A10(
        stepExecutionId: stepExecutionId,
        userId: userId,
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        alertTier: alertTier,
        requirePokaYokeToggle: requirePokaYokeToggle,
        pokaYokeText: pokaYokeText,
        barrierDismissible: barrierDismissible,
        onAuditLog: onAuditLog,
        onConfirm: onConfirm,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(curvedAnimation),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

/// Reusable responsive action modal dialog widget supporting M3 tonal cards, fluid screen boundaries, and poka-yoke gates.
class ActionModalDialogFEBFL037A10 extends StatefulWidget {
  final String stepExecutionId;
  final String userId;
  final String title;
  final Widget content;
  final String? confirmLabel;
  final String? cancelLabel;
  final ModalAlertTier alertTier;
  final bool requirePokaYokeToggle;
  final String pokaYokeText;
  final bool barrierDismissible;
  final void Function(ModalExecutionAudit audit)? onAuditLog;
  final Future<bool> Function()? onConfirm;

  const ActionModalDialogFEBFL037A10({
    super.key,
    required this.stepExecutionId,
    required this.userId,
    required this.title,
    required this.content,
    this.confirmLabel,
    this.cancelLabel,
    this.alertTier = ModalAlertTier.standard,
    this.requirePokaYokeToggle = false,
    this.pokaYokeText = 'I confirm this action and understand its permanent impact.',
    this.barrierDismissible = true,
    this.onAuditLog,
    this.onConfirm,
  });

  @override
  State<ActionModalDialogFEBFL037A10> createState() => _ActionModalDialogFEBFL037A10State();
}

class _ActionModalDialogFEBFL037A10State extends State<ActionModalDialogFEBFL037A10> {
  bool _isPokaYokeUnlocked = false;
  bool _isProcessing = false;

  @override
  void initState()
  {
    super.initState();
    // Automatically unlocked if poka-yoke is not requested.
    _isPokaYokeUnlocked = !widget.requirePokaYokeToggle && widget.alertTier != ModalAlertTier.highAlert;
  }

  void _emitAudit(String status, String outcome) {
    if (widget.onAuditLog != null) {
      widget.onAuditLog!(
        ModalExecutionAudit(
          stepExecutionId: widget.stepExecutionId,
          executionStatus: status,
          executionTimestamp: DateTime.now().toUtc(),
          stepOutcome: outcome,
          userId: widget.userId,
        ),
      );
    }
  }

  Color _resolveTonalBackground(ThemeData theme) {
    switch (widget.alertTier) {
      case ModalAlertTier.highAlert:
        return theme.colorScheme.errorContainer.withOpacity(0.96);
      case ModalAlertTier.warning:
        return theme.colorScheme.tertiaryContainer.withOpacity(0.94);
      case ModalAlertTier.informational:
        return theme.colorScheme.surfaceVariant.withOpacity(0.92);
      case ModalAlertTier.standard:
      default:
        return theme.colorScheme.surface;
    }
  }

  Color _resolveTextColor(ThemeData theme) {
    switch (widget.alertTier) {
      case ModalAlertTier.highAlert:
        return theme.colorScheme.onErrorContainer;
      case ModalAlertTier.warning:
        return theme.colorScheme.onTertiaryContainer;
      case ModalAlertTier.informational:
        return theme.colorScheme.onSurfaceVariant;
      case ModalAlertTier.standard:
      default:
        return theme.colorScheme.onSurface;
    }
  }

  Future<void> _handleConfirm() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    _emitAudit('In_Progress', 'Confirm_Initiated');

    try {
      bool success = true;
      if (widget.onConfirm != null) {
        success = await widget.onConfirm!();
      }
      if (mounted) {
        if (success) {
          _emitAudit('Complete', 'Confirmed');
          Navigator.of(context).pop(true);
        } else {
          _emitAudit('Partial', 'Confirm_Verification_Failed');
        }
      }
    } catch (error) {
      _emitAudit('Failed', 'Error: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handleDismiss(String dismissReason) {
    _emitAudit('Cancelled', dismissReason);
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isCompactPhone = mediaQuery.size.width < 600;
    final tonalBg = _resolveTonalBackground(theme);
    final textColor = _resolveTextColor(theme);

    final modalBox = Container(
      width: isCompactPhone ? double.infinity : 480,
      margin: EdgeInsets.all(isCompactPhone ? 12.0 : 24.0),
      decoration: BoxDecoration(
        color: tonalBg,
        borderRadius: BorderRadius.circular(isCompactPhone ? 24.0 : 28.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (widget.alertTier == ModalAlertTier.highAlert) ...[
                    Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 28),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                    onPressed: () => _handleDismiss('Close_Button_Tapped'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: DefaultTextStyle(
                    style: theme.textTheme.bodyMedium?.copyWith(color: textColor.withOpacity(0.85)) ??
                        TextStyle(color: textColor),
                    child: widget.content,
                  ),
                ),
              ),
              if (widget.requirePokaYokeToggle || widget.alertTier == ModalAlertTier.highAlert) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: _isPokaYokeUnlocked,
                    onChanged: _isProcessing
                        ? null
                        : (val) {
                            setState(() => _isPokaYokeUnlocked = val ?? false);
                          },
                    title: Text(
                      widget.pokaYokeText,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isProcessing ? null : () => _handleDismiss('Cancel_Button_Tapped'),
                    child: Text(
                      widget.cancelLabel ?? 'Cancel',
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: widget.alertTier == ModalAlertTier.highAlert
                        ? FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                          )
                        : null,
                    onPressed: (!_isPokaYokeUnlocked || _isProcessing) ? null : _handleConfirm,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.confirmLabel ?? 'Confirm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.barrierDismissible
          ? () => _handleDismiss('Backdrop_Tap_Dismiss')
          : null,
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () {},
          child: modalBox,
        ),
      ),
    );
  }
}
