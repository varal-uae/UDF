// FEBFL-037-A07 — Reusable Action Modal and Confirmation Templates.
// Implements fluid responsive modal dialogs adapting from centered M3 dialogs on wider screens
// to full-screen safe sheets on compact mobile viewports, featuring scale-up transitions, tonal containers, and poka-yoke safety toggles.

import 'package:flutter/material.dart';

/// Priority level for modal actions governing tonal styling and safety mechanics.
enum ModalAlertLevel {
  standard,
  medium,
  highPriorityDestructive,
}

/// Audit and telemetry payload tracking modal interactions.
class ModalAuditData {
  final String configurationParameter;
  final String currentSetting;
  final String previousSetting;
  final String changeLog;
  final DateTime configurationTimestamp;

  const ModalAuditData({
    required this.configurationParameter,
    required this.currentSetting,
    required this.previousSetting,
    required this.changeLog,
    required this.configurationTimestamp,
  });
}

/// Configuration object for responsive action modals.
class ActionModalConfig {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final ModalAlertLevel alertLevel;
  final IconData? icon;
  final String? pokaYokeAcknowledgeLabel;
  final ModalAuditData? auditData;
  final VoidCallback? onConfirmed;
  final VoidCallback? onCancelled;

  const ActionModalConfig({
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.alertLevel = ModalAlertLevel.standard,
    this.icon,
    this.pokaYokeAcknowledgeLabel,
    this.auditData,
    this.onConfirmed,
    this.onCancelled,
  });
}

/// Entry point helper class to open modals responsively.
class ActionModal {
  static Future<bool?> show({
    required BuildContext context,
    required ActionModalConfig config,
  }) {
    final isCompactPhone = MediaQuery.of(context).size.width < 600;

    if (isCompactPhone) {
      return showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => ActionModalSheetFEBFL037A07(config: config),
      );
    }

    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (ctx, anim, secondaryAnim) => Center(
        child: ActionModalDialogFEBFL037A07(config: config),
      ),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.90, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }
}

/// Modal content container containing Material 3 layout, Poka-Yoke confirmation, and tonal surfaces.
class ActionModalContentFEBFL037A07 extends StatefulWidget {
  final ActionModalConfig config;
  final bool isFullScreenSheet;

  const ActionModalContentFEBFL037A07({
    super.key,
    required this.config,
    this.isFullScreenSheet = false,
  });

  @override
  State<ActionModalContentFEBFL037A07> createState() =>
      _ActionModalContentFEBFL037A07State();
}

class _ActionModalContentFEBFL037A07State
    extends State<ActionModalContentFEBFL037A07> {
  bool _pokaYokeConfirmed = false;

  @override
  void initState() {
    super.initState();
    // If no poka-yoke label is defined and not high-alert, confirm defaults to unlocked
    _pokaYokeConfirmed = widget.config.alertLevel != ModalAlertLevel.highPriorityDestructive &&
        widget.config.pokaYokeAcknowledgeLabel == null;
  }

  Color _getTonalContainerColor(ThemeData theme) {
    switch (widget.config.alertLevel) {
      case ModalAlertLevel.highPriorityDestructive:
        return theme.colorScheme.errorContainer;
      case ModalAlertLevel.medium:
        return theme.colorScheme.tertiaryContainer;
      case ModalAlertLevel.standard:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _getTonalOnColor(ThemeData theme) {
    switch (widget.config.alertLevel) {
      case ModalAlertLevel.highPriorityDestructive:
        return theme.colorScheme.onErrorContainer;
      case ModalAlertLevel.medium:
        return theme.colorScheme.onTertiaryContainer;
      case ModalAlertLevel.standard:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighAlert = widget.config.alertLevel == ModalAlertLevel.highPriorityDestructive;
    final hasPokaYokeToggle =
        widget.config.pokaYokeAcknowledgeLabel != null || isHighAlert;

    final toggleLabel = widget.config.pokaYokeAcknowledgeLabel ??
        'I acknowledge this critical action cannot be reversed.';

    final tonalColor = _getTonalContainerColor(theme);
    final onTonalColor = _getTonalOnColor(theme);

    return Column(
      mainAxisSize: widget.isFullScreenSheet ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Optional Mobile Handle Bar for sheets
        if (widget.isFullScreenSheet)
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

        // Header block with Tonal Alert highlight
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: tonalColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            children: [
              Icon(
                widget.config.icon ??
                    (isHighAlert ? Icons.warning_rounded : Icons.info_outline_rounded),
                color: onTonalColor,
                size: 28.0,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  widget.config.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onTonalColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Body description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Text(
            widget.config.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ),

        // Audit & Settings change log (if provided)
        if (widget.config.auditData != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Audit Details',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Parameter: ${widget.config.auditData!.configurationParameter}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Previous: ${widget.config.auditData!.previousSetting} -> Current: ${widget.config.auditData!.currentSetting}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Log: ${widget.config.auditData!.changeLog}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],

        // Poka-Yoke safety confirmation toggle
        if (hasPokaYokeToggle) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: CheckboxListTile(
              dense: true,
              activeColor: isHighAlert ? theme.colorScheme.error : theme.colorScheme.primary,
              value: _pokaYokeConfirmed,
              title: Text(
                toggleLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _pokaYokeConfirmed = val ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ],

        if (widget.isFullScreenSheet) const Spacer(),

        const SizedBox(height: 12.0),

        // Action Buttons Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.config.onCancelled?.call();
                    Navigator.of(context).pop(false);
                  },
                  child: Text(widget.config.cancelLabel),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: FilledButton(
                  style: isHighAlert
                      ? FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        )
                      : null,
                  onPressed: _pokaYokeConfirmed
                      ? () {
                          widget.config.onConfirmed?.call();
                          Navigator.of(context).pop(true);
                        }
                      : null,
                  child: Text(widget.config.confirmLabel),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Centered scaled Dialog for Desktop & Tablet viewports.
class ActionModalDialogFEBFL037A07 extends StatelessWidget {
  final ActionModalConfig config;

  const ActionModalDialogFEBFL037A07({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth.clamp(380.0, 520.0);

    return Dialog(
      shape: RoundedRectangleManager.roundedRectangleBorder,
      elevation: 6,
      backgroundColor: Theme.of(context).colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: modalWidth),
        child: ActionModalContentFEBFL037A07(
          config: config,
          isFullScreenSheet: false,
        ),
      ),
    );
  }
}

/// Full-screen safe bottom overlay for mobile screens.
class ActionModalSheetFEBFL037A07 extends StatelessWidget {
  final ActionModalConfig config;

  const ActionModalSheetFEBFL037A07({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SafeArea(
        child: ActionModalContentFEBFL037A07(
          config: config,
          isFullScreenSheet: true,
        ),
      ),
    );
  }
}

/// Shared shapes for Material 3 Dialog standardization.
class RoundedRectangleManager {
  static const RoundedRectangleBorder roundedRectangleBorder =
      RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(28.0)),
  );
}
