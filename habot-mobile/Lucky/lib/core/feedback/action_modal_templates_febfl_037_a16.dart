// FEBFL-037-A16 — Reusable Action Modal Templates and Confirmation Blocks.
// Implements Material 3 responsive dialogs and full-screen overlays with WCAG 2.2 AA focus trapping,
// scale-up entry animations, Poka-Yoke safety toggle switches, and atomic validation event logging.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Audit record capturing modal interaction and validation telemetry.
class ModalValidationRecord {
  final String validationType;
  final String validationResult;
  final List<String> errorMessages;
  final DateTime validationTimestamp;
  final String validationLog;
  final String completionStatus; // 'Pass' or 'Fail'
  final DateTime actionTimestamp;
  final String? userSessionId;

  const ModalValidationRecord({
    required this.validationType,
    required this.validationResult,
    required this.errorMessages,
    required this.validationTimestamp,
    required this.validationLog,
    required this.completionStatus,
    required this.actionTimestamp,
    this.userSessionId,
  });

  Map<String, dynamic> toMap() => {
        'validationType': validationType,
        'validationResult': validationResult,
        'errorMessages': errorMessages,
        'validationTimestamp': validationTimestamp.toIso8601String(),
        'validationLog': validationLog,
        'completionStatus': completionStatus,
        'actionTimestamp': actionTimestamp.toIso8601String(),
        'userSessionId': userSessionId,
      };
}

/// Priority level determining container tonality and verification flows.
enum ModalAlertLevel {
  standard,
  informational,
  highAlertCritical,
}

/// Centralized repository for displaying responsive, accessible modals and sheets.
class ActionModalRepository {
  /// Shows an accessible, responsive confirmation modal with optional Poka-Yoke toggle
  /// for high-alert confirmation actions.
  static Future<T?> showActionModal<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    ModalAlertLevel alertLevel = ModalAlertLevel.standard,
    String? pokaYokeAcknowledgePrompt,
    bool isDismissible = true,
    String? userSessionId,
    void Function(ModalValidationRecord record)? onValidationLog,
  }) {
    final isCompactScreen = MediaQuery.of(context).size.width < 600;

    if (isCompactScreen && alertLevel != ModalAlertLevel.highAlertCritical) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        isDismissible: isDismissible,
        enableDrag: isDismissible,
        backgroundColor: Colors.transparent,
        builder: (modalCtx) => _ActionBottomSheetWrapper<T>(
          title: title,
          content: content,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          alertLevel: alertLevel,
          pokaYokePrompt: pokaYokeAcknowledgePrompt,
          userSessionId: userSessionId,
          onValidationLog: onValidationLog,
        ),
      );
    } else {
      return showGeneralDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (dialogCtx, anim1, anim2) {
          return _ActionDialogWrapper<T>(
            title: title,
            content: content,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            alertLevel: alertLevel,
            pokaYokePrompt: pokaYokeAcknowledgePrompt,
            userSessionId: userSessionId,
            onValidationLog: onValidationLog,
          );
        },
        transitionBuilder: (dialogCtx, anim, secondaryAnim, child) {
          final curvedValue = Curves.easeOutBack.transform(anim.value);
          return Transform.scale(
            scale: 0.9 + (curvedValue * 0.1),
            child: Opacity(
              opacity: anim.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
      );
    }
  }
}

/// Centered Material 3 Action Dialog with WCAG 2.2 focus lock & escape triggers.
class _ActionDialogWrapper<T> extends StatefulWidget {
  final String title;
  final Widget content;
  final String confirmLabel;
  final String cancelLabel;
  final ModalAlertLevel alertLevel;
  final String? pokaYokePrompt;
  final String? userSessionId;
  final void Function(ModalValidationRecord record)? onValidationLog;

  const _ActionDialogWrapper({
    Key? key,
    required this.title,
    required this.content,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.alertLevel,
    this.pokaYokePrompt,
    this.userSessionId,
    this.onValidationLog,
  }) : super(key: key);

  @override
  State<_ActionDialogWrapper<T>> createState() => _ActionDialogWrapperState<T>();
}

class _ActionDialogWrapperState<T> extends State<_ActionDialogWrapper<T>> {
  final FocusScopeNode _dialogFocusScope = FocusScopeNode();
  bool _isAcknowledged = false;

  @override
  void initState() {
    super.initState();
    // Poka-Yoke requirement: high-alert actions require explicit toggle to unlock execution
    _isAcknowledged = widget.alertLevel != ModalAlertLevel.highAlertCritical;
  }

  @override
  void dispose() {
    _dialogFocusScope.dispose();
    super.dispose();
  }

  void _emitLog(bool isConfirmed) {
    final now = DateTime.now();
    final record = ModalValidationRecord(
      validationType: 'ModalAction_${widget.alertLevel.name}',
      validationResult: isConfirmed ? 'ActionConfirmed' : 'ActionDismissed',
      errorMessages: [],
      validationTimestamp: now,
      validationLog: 'User ${isConfirmed ? "accepted" : "declined"} modal: ${widget.title}',
      completionStatus: isConfirmed ? 'Pass' : 'Fail',
      actionTimestamp: now,
      userSessionId: widget.userSessionId,
    );
    widget.onValidationLog?.call(record);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Distinct tonal container for high-alert confirmation actions
    final isHighAlert = widget.alertLevel == ModalAlertLevel.highAlertCritical;
    final containerColor = isHighAlert
        ? colorScheme.errorContainer
        : colorScheme.surfaceContainerHigh;
    final onContainerColor = isHighAlert
        ? colorScheme.onErrorContainer
        : colorScheme.onSurface;

    return FocusScope(
      node: _dialogFocusScope,
      autofocus: true,
      onKey: (node, event) {
        // WCAG 2.2 keyboard exit triggers: escape dismisses modal
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _emitLog(false);
          Navigator.of(context).pop(false);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        modal: true,
        label: '${widget.title} dialog window',
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, minWidth: 280),
            child: Card(
              elevation: isHighAlert ? 8.0 : 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
                side: isHighAlert
                    ? BorderSide(color: colorScheme.error, width: 1.5)
                    : BorderSide.none,
              ),
              color: containerColor,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (isHighAlert)
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Icon(Icons.warning_amber_rounded,
                                color: colorScheme.error, size: 28),
                          ),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: onContainerColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: DefaultTextStyle(
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: onContainerColor,
                              ) ??
                              TextStyle(color: onContainerColor),
                          child: widget.content,
                        ),
                      ),
                    ),
                    if (isHighAlert) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Switch.adaptive(
                              value: _isAcknowledged,
                              activeColor: colorScheme.error,
                              onChanged: (val) {
                                setState(() => _isAcknowledged = val);
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.pokaYokePrompt ??
                                    'I verify and acknowledge this permanent action.',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: onContainerColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _emitLog(false);
                            Navigator.of(context).pop(false);
                          },
                          child: Text(widget.cancelLabel),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          style: isHighAlert
                              ? FilledButton.styleFrom(
                                  backgroundColor: colorScheme.error,
                                  foregroundColor: colorScheme.onError,
                                )
                              : null,
                          onPressed: _isAcknowledged
                              ? () {
                                  _emitLog(true);
                                  Navigator.of(context).pop(true);
                                }
                              : null,
                          child: Text(widget.confirmLabel),
                        ),
                      ],
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

/// Fluid Mobile-First Bottom Sheet overlay expanding on phone viewports.
class _ActionBottomSheetWrapper<T> extends StatefulWidget {
  final String title;
  final Widget content;
  final String confirmLabel;
  final String cancelLabel;
  final ModalAlertLevel alertLevel;
  final String? pokaYokePrompt;
  final String? userSessionId;
  final void Function(ModalValidationRecord record)? onValidationLog;

  const _ActionBottomSheetWrapper({
    Key? key,
    required this.title,
    required this.content,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.alertLevel,
    this.pokaYokePrompt,
    this.userSessionId,
    this.onValidationLog,
  }) : super(key: key);

  @override
  State<_ActionBottomSheetWrapper<T>> createState() =>
      _ActionBottomSheetWrapperState<T>();
}

class _ActionBottomSheetWrapperState<T>
    extends State<_ActionBottomSheetWrapper<T>> {
  bool _isAcknowledged = false;

  @override
  void initState() {
    super.initState();
    _isAcknowledged = widget.alertLevel != ModalAlertLevel.highAlertCritical;
  }

  void _emitLog(bool isConfirmed) {
    final now = DateTime.now();
    final record = ModalValidationRecord(
      validationType: 'BottomSheetAction_${widget.alertLevel.name}',
      validationResult: isConfirmed ? 'ActionConfirmed' : 'ActionDismissed',
      errorMessages: [],
      validationTimestamp: now,
      validationLog: 'User ${isConfirmed ? "accepted" : "declined"} sheet: ${widget.title}',
      completionStatus: isConfirmed ? 'Pass' : 'Fail',
      actionTimestamp: now,
      userSessionId: widget.userSessionId,
    );
    widget.onValidationLog?.call(record);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHighAlert = widget.alertLevel == ModalAlertLevel.highAlertCritical;

    return Semantics(
      modal: true,
      label: '${widget.title} bottom sheet',
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: isHighAlert
              ? colorScheme.errorContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isHighAlert
                      ? colorScheme.onErrorContainer
                      : colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: widget.content,
                ),
              ),
              if (isHighAlert) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Switch.adaptive(
                      value: _isAcknowledged,
                      activeColor: colorScheme.error,
                      onChanged: (val) {
                        setState(() => _isAcknowledged = val);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.pokaYokePrompt ??
                            'I acknowledge and confirm this operation.',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _emitLog(false);
                      Navigator.of(context).pop(false);
                    },
                    child: Text(widget.cancelLabel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: isHighAlert
                        ? FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                          )
                        : null,
                    onPressed: _isAcknowledged
                        ? () {
                            _emitLog(true);
                            Navigator.of(context).pop(true);
                          }
                        : null,
                    child: Text(widget.confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
