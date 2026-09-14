// FEBFL-037-A11 — Reusable Action Modal & Confirmation Blocks with Keyboard Focus Trapping.
// Implements responsive Material 3 dialog overlays, full-screen adaptive phone presentation,
// smooth scale-up transitions, trapped focus navigation, and Poka-Yoke verification safety toggles.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Priority level for modal actions.
enum ModalAlertLevel {
  info,
  warning,
  highAlert,
}

/// Execution tracking payload for compliance and telemetry logging.
class ModalExecutionLog {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const ModalExecutionLog({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'stepExecutionId': stepExecutionId,
        'executionStatus': executionStatus,
        'executionTimestamp': executionTimestamp.toIso8601String(),
        'stepOutcome': stepOutcome,
        'userId': userId,
      };
}

/// Centralized reusable confirmation and action modal.
class ActionModalFEBFL037A11 extends StatefulWidget {
  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final ModalAlertLevel alertLevel;
  final bool requireVerificationToggle;
  final String toggleVerificationText;
  final Widget? content;
  final String userId;
  final String stepExecutionId;
  final void Function(ModalExecutionLog log)? onExecutionLogged;

  const ActionModalFEBFL037A11({
    super.key,
    required this.title,
    required this.description,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.alertLevel = ModalAlertLevel.info,
    this.requireVerificationToggle = false,
    this.toggleVerificationText = 'I acknowledge and verify this high-priority action',
    this.content,
    this.userId = 'system_user',
    this.stepExecutionId = 'FEBFL-037-A11-INIT',
    this.onExecutionLogged,
  });

  /// Helper to launch the modal as a responsive focus-trapped dialog.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String description,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    ModalAlertLevel alertLevel = ModalAlertLevel.info,
    bool requireVerificationToggle = false,
    String toggleVerificationText = 'I acknowledge and verify this high-priority action',
    Widget? content,
    String userId = 'system_user',
    String stepExecutionId = 'FEBFL-037-A11-EXEC',
    void Function(ModalExecutionLog log)? onExecutionLogged,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ActionModalFEBFL037A11(
          title: title,
          description: description,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          onConfirm: onConfirm,
          onCancel: onCancel,
          alertLevel: alertLevel,
          requireVerificationToggle: requireVerificationToggle,
          toggleVerificationText: toggleVerificationText,
          content: content,
          userId: userId,
          stepExecutionId: stepExecutionId,
          onExecutionLogged: onExecutionLogged,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ActionModalFEBFL037A11> createState() => _ActionModalFEBFL037A11State();
}

class _ActionModalFEBFL037A11State extends State<ActionModalFEBFL037A11> {
  late final FocusScopeNode _modalFocusScopeNode;
  bool _isVerificationToggled = false;

  @override
  void initState({
    super.initState();
    _modalFocusScopeNode = FocusScopeNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _modalFocusScopeNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _modalFocusScopeNode.dispose();
    super.dispose();
  }

  void _emitLog(String status, String outcome) {
    final log = ModalExecutionLog(
      stepExecutionId: widget.stepExecutionId,
      executionStatus: status,
      executionTimestamp: DateTime.now().toUtc(),
      stepOutcome: outcome,
      userId: widget.userId,
    );
    widget.onExecutionLogged?.call(log);
  }

  Color _getTonalContainerColor(ThemeData theme) {
    switch (widget.alertLevel) {
      case ModalAlertLevel.highAlert:
        return theme.colorScheme.errorContainer.withOpacity(0.4);
      case ModalAlertLevel.warning:
        return theme.colorScheme.tertiaryContainer.withOpacity(0.35);
      case ModalAlertLevel.info:
        return theme.colorScheme.surfaceVariant.withOpacity(0.35);
    }
  }

  Color _getPrimaryAccentColor(ThemeData theme) {
    switch (widget.alertLevel) {
      case ModalAlertLevel.highAlert:
        return theme.colorScheme.error;
      case ModalAlertLevel.warning:
        return theme.colorScheme.tertiary;
      case ModalAlertLevel.info:
        return theme.colorScheme.primary;
    }
  }

  IconData _getHeaderIcon() {
    switch (widget.alertLevel) {
      case ModalAlertLevel.highAlert:
        return Icons.warning_rounded;
      case ModalAlertLevel.warning:
        return Icons.report_problem_outlined;
      case ModalAlertLevel.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isCompactPhone = mediaQuery.size.width < 600;

    final bool isConfirmEnabled =
        !widget.requireVerificationToggle || _isVerificationToggled;

    final dialogContent = Material(
      color: theme.colorScheme.surface,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: isCompactPhone
            ? BorderRadius.zero
            : BorderRadius.circular(24.0),
      ),
      child: SafeArea(
        top: isCompactPhone,
        bottom: isCompactPhone,
        child: Container(
          width: isCompactPhone ? double.infinity : 480,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: _getTonalContainerColor(theme),
            borderRadius: isCompactPhone
                ? BorderRadius.zero
                : BorderRadius.circular(24.0),
          ),
          child: Column(
            mainAxisSize: isCompactPhone ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    _getHeaderIcon(),
                    color: _getPrimaryAccentColor(theme),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                fit: isCompactPhone ? FlexFit.tight : FlexFit.loose,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      if (widget.content != null) ...[
                        const SizedBox(height: 16),
                        widget.content!,
                      ],
                      if (widget.requireVerificationToggle) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            children: [
                              Switch.adaptive(
                                value: _isVerificationToggled,
                                activeColor: _getPrimaryAccentColor(theme),
                                onChanged: (val) {
                                  setState(() {
                                    _isVerificationToggled = val;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.toggleVerificationText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _emitLog('Complete', 'Cancelled');
                      widget.onCancel?.call();
                      Navigator.of(context).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(widget.cancelLabel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: isConfirmEnabled
                        ? () {
                            _emitLog('Complete', 'Confirmed');
                            widget.onConfirm?.call();
                            Navigator.of(context).pop(true);
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _getPrimaryAccentColor(theme),
                      foregroundColor: theme.colorScheme.onError,
                      disabledBackgroundColor: theme.colorScheme.onSurface
                          .withOpacity(0.12),
                      disabledForegroundColor: theme.colorScheme.onSurface
                          .withOpacity(0.38),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(widget.confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Keyboard Focus Trapping wrapper preventing escape from the modal container
    return FocusScope(
      node: _modalFocusScopeNode,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            _emitLog('Complete', 'DismissedByEscape');
            widget.onCancel?.call();
            Navigator.of(context).pop(false);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: isCompactPhone
            ? SizedBox.expand(child: dialogContent)
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: dialogContent,
                ),
              ),
      ),
    );
  }
}
