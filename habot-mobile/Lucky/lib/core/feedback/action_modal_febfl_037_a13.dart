// FEBFL-037-A13 — Centralized Action Modal and Confirmation Block Templates.
// Implements Material 3 responsive overlay dialogs and adaptive modal sheets with smooth scale-up animations, poka-yoke toggle safeguards, and distinct tonal container styling for high-alert confirmations.

import 'package:flutter/material.dart';

/// Priority level for modal dialog confirmation workflows.
enum ModalAlertLevel {
  standard,
  warning,
  highAlert,
}

/// Audit and telemetry tracking metadata for modal invocations.
class ActionModalMetadata {
  final String objectId;
  final DateTime creationDate;
  final String createdBy;
  final String creationMethod;
  final Map<String, dynamic>? initialConfiguration;

  ActionModalMetadata({
    required this.objectId,
    DateTime? creationDate,
    this.createdBy = 'System',
    this.creationMethod = 'UserTriggered',
    this.initialConfiguration,
  }) : creationDate = creationDate ?? DateTime.now();
}

/// Centered adaptive confirmation dialog with Poka-Yoke safety guard.
class ActionConfirmationModal extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final ModalAlertLevel alertLevel;
  final String? pokaYokePrompt;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final ActionModalMetadata? metadata;
  final Widget? customContent;

  const ActionConfirmationModal({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.alertLevel = ModalAlertLevel.standard,
    this.pokaYokePrompt,
    required this.onConfirm,
    this.onCancel,
    this.metadata,
    this.customContent,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    ModalAlertLevel alertLevel = ModalAlertLevel.standard,
    String? pokaYokePrompt,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    ActionModalMetadata? metadata,
    Widget? customContent,
  }) {
    final isCompactPhone = MediaQuery.of(context).size.width < 600;

    if (isCompactPhone && alertLevel == ModalAlertLevel.highAlert) {
      return showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) => _FullScreenModalSheet(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          alertLevel: alertLevel,
          pokaYokePrompt: pokaYokePrompt,
          onConfirm: onConfirm,
          onCancel: onCancel,
          customContent: customContent,
        ),
      );
    }

    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: alertLevel != ModalAlertLevel.highAlert,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: ActionConfirmationModal(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            alertLevel: alertLevel,
            pokaYokePrompt: pokaYokePrompt,
            onConfirm: onConfirm,
            onCancel: onCancel,
            metadata: metadata,
            customContent: customContent,
          ),
        );
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ActionConfirmationModal> createState() => _ActionConfirmationModalState();
}

class _ActionConfirmationModalState extends State<ActionConfirmationModal> {
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _isUnlocked = widget.alertLevel != ModalAlertLevel.highAlert && widget.pokaYokePrompt == null;
  }

  Color _getTonalContainer(ThemeData theme) {
    switch (widget.alertLevel) {
      case ModalAlertLevel.highAlert:
        return theme.colorScheme.errorContainer;
      case ModalAlertLevel.warning:
        return theme.colorScheme.tertiaryContainer;
      case ModalAlertLevel.standard:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _getTonalOnContainer(ThemeData theme) {
    switch (widget.alertLevel) {
      case ModalAlertLevel.highAlert:
        return theme.colorScheme.onErrorContainer;
      case ModalAlertLevel.warning:
        return theme.colorScheme.onTertiaryContainer;
      case ModalAlertLevel.standard:
        return theme.colorScheme.onSurface;
    }
  }

  IconData _getHeaderIcon() {
    switch (widget.alertLevel) {
      case ModalAlertLevel.highAlert:
        return Icons.warning_amber_rounded;
      case ModalAlertLevel.warning:
        return Icons.info_outline_rounded;
      case ModalAlertLevel.standard:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tonalBg = _getTonalContainer(theme);
    final tonalFg = _getTonalOnContainer(theme);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 480 ? 440.0 : (screenWidth * 0.9);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      backgroundColor: theme.colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Distinct tonal header for high-alert/warning actions
            Container(
              color: tonalBg,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(_getHeaderIcon(), color: tonalFg, size: 28.0),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tonalFg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  if (widget.customContent != null) ...[
                    const SizedBox(height: 16.0),
                    widget.customContent!,
                  ],
                  if (widget.pokaYokePrompt != null || widget.alertLevel == ModalAlertLevel.highAlert) ...[
                    const SizedBox(height: 18.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Switch.adaptive(
                            value: _isUnlocked,
                            activeColor: widget.alertLevel == ModalAlertLevel.highAlert
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                            onChanged: (val) => setState(() => _isUnlocked = val),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              widget.pokaYokePrompt ?? 'I understand and confirm this action',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onCancel?.call();
                      Navigator.of(context).pop(false);
                    },
                    child: Text(widget.cancelLabel),
                  ),
                  const SizedBox(width: 12.0),
                  FilledButton(
                    onPressed: _isUnlocked
                        ? () {
                            widget.onConfirm();
                            Navigator.of(context).pop(true);
                          }
                        : null,
                    style: widget.alertLevel == ModalAlertLevel.highAlert
                        ? FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                          )
                        : null,
                    child: Text(widget.confirmLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen or adaptive expanded sheet block for compact phone screens.
class _FullScreenModalSheet extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final ModalAlertLevel alertLevel;
  final String? pokaYokePrompt;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Widget? customContent;

  const _FullScreenModalSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.alertLevel,
    this.pokaYokePrompt,
    required this.onConfirm,
    this.onCancel,
    this.customContent,
  });

  @override
  State<_FullScreenModalSheet> createState() => _FullScreenModalSheetState();
}

class _FullScreenModalSheetState extends State<_FullScreenModalSheet> {
  bool _isUnlocked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighAlert = widget.alertLevel == ModalAlertLevel.highAlert;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grab handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              width: 36.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          // Header banner
          Container(
            color: isHighAlert ? theme.colorScheme.errorContainer : theme.colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              children: [
                Icon(
                  isHighAlert ? Icons.warning_amber_rounded : Icons.shield_outlined,
                  color: isHighAlert ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSurfaceVariant,
                  size: 26.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isHighAlert ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                if (widget.customContent != null) ...[
                  const SizedBox(height: 16.0),
                  widget.customContent!,
                ],
                const SizedBox(height: 24.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Switch.adaptive(
                        value: _isUnlocked,
                        activeColor: isHighAlert ? theme.colorScheme.error : theme.colorScheme.primary,
                        onChanged: (val) => setState(() => _isUnlocked = val),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          widget.pokaYokePrompt ?? 'Acknowledge critical action before proceeding',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28.0),
                FilledButton(
                  onPressed: _isUnlocked
                      ? () {
                          widget.onConfirm();
                          Navigator.of(context).pop(true);
                        }
                      : null,
                  style: isHighAlert
                      ? FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        )
                      : FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                  child: Text(widget.confirmLabel),
                ),
                const SizedBox(height: 12.0),
                OutlinedButton(
                  onPressed: () {
                    widget.onCancel?.call();
                    Navigator.of(context).pop(false);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  child: Text(widget.cancelLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
