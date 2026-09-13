// FEBFL-037-A16 — Centralized Reusable Modal & Confirmation Dialog Repository.
// Delivers Material 3 responsive modal templates, scale-up entrance animations, WCAG 2.2 Level AA
// focus/exit traversal, Poka-Yoke safety confirmation switches, and validation telemetry collection.

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Priority level dictating styling, tonal backgrounds, and safety interlocks.
enum ModalAlertLevel {
  standard,
  warning,
  critical,
}

/// Layout presentation style adapting across device form factors.
enum ModalPresentationMode {
  adaptive,
  centeredDialog,
  fullScreenSheet,
}

/// Structured validation and interaction telemetry event data (FEBFL-037-A16).
@immutable
class ModalValidationTelemetry {
  final String validationType;
  final bool validationResult;
  final String completionStatus; // 'Pass' or 'Fail'
  final List<String> errorMessages;
  final DateTime validationTimestamp;
  final DateTime actionTimestamp;
  final String validationLog;
  final String? userSessionId;

  const ModalValidationTelemetry({
    required this.validationType,
    required this.validationResult,
    required this.completionStatus,
    required this.errorMessages,
    required this.validationTimestamp,
    required this.actionTimestamp,
    required this.validationLog,
    this.userSessionId,
  });

  Map<String, dynamic> toMap() => {
        'validationType': validationType,
        'validationResult': validationResult,
        'completionStatus': completionStatus,
        'errorMessages': errorMessages,
        'validationTimestamp': validationTimestamp.toIso8601String(),
        'actionTimestamp': actionTimestamp.toIso8601String(),
        'validationLog': validationLog,
        'userSessionId': userSessionId,
      };

  @override
  String toString() => 'ModalValidationTelemetry(${toMap()})';
}

/// Centralized controller and launcher for accessible Action Modals.
class ActionModal {
  ActionModal._();

  /// Displays an adaptive Action Modal dialog or full-screen overlay sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String? subtitle,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    ModalAlertLevel alertLevel = ModalAlertLevel.standard,
    ModalPresentationMode presentationMode = ModalPresentationMode.adaptive,
    bool requirePokaYokeConfirmation = false,
    String? pokaYokePrompt,
    Future<bool> Function()? onConfirmValidation,
    void Function(ModalValidationTelemetry telemetry)? onTelemetryLogged,
    String? userSessionId,
    bool barrierDismissible = true,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final isCompactPhone = mediaQuery.size.shortestSide < 600;

    final resolvedPresentation =
        presentationMode == ModalPresentationMode.adaptive
            ? (isCompactPhone
                ? ModalPresentationMode.fullScreenSheet
                : ModalPresentationMode.centeredDialog)
            : presentationMode;

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.54),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return ActionModalScope(
          title: title,
          subtitle: subtitle,
          content: content,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          alertLevel: alertLevel,
          presentationMode: resolvedPresentation,
          requirePokaYokeConfirmation: requirePokaYokeConfirmation,
          pokaYokePrompt: pokaYokePrompt,
          onConfirmValidation: onConfirmValidation,
          onTelemetryLogged: onTelemetryLogged,
          userSessionId: userSessionId,
        );
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );

        if (resolvedPresentation == ModalPresentationMode.fullScreenSheet) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return SlideTransition(
            position: slideAnimation,
            child: child,
          );
        }

        return ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Stateful component handling accessibility focus bounds, scale-up entrance,
/// and Poka-Yoke interlocks for high-alert confirmation actions.
class ActionModalScope extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final String confirmLabel;
  final String cancelLabel;
  final ModalAlertLevel alertLevel;
  final ModalPresentationMode presentationMode;
  final bool requirePokaYokeConfirmation;
  final String? pokaYokePrompt;
  final Future<bool> Function()? onConfirmValidation;
  final void Function(ModalValidationTelemetry telemetry)? onTelemetryLogged;
  final String? userSessionId;

  const ActionModalScope({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.alertLevel,
    required this.presentationMode,
    required this.requirePokaYokeConfirmation,
    this.pokaYokePrompt,
    this.onConfirmValidation,
    this.onTelemetryLogged,
    this.userSessionId,
  });

  @override
  State<ActionModalScope> createState() => _ActionModalScopeState();
}

class _ActionModalScopeState extends State<ActionModalScope> {
  bool _pokaYokeConfirmed = false;
  bool _isProcessing = false;
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  final FocusNode _confirmButtonFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Default pokaYoke toggle to confirmed if requirement disabled
    _pokaYokeConfirmed = !widget.requirePokaYokeConfirmation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusScopeNode.requestFocus();
      }
    });
  }

  @override
  void dispose({
    super.dispose();
    _focusScopeNode.dispose();
    _confirmButtonFocus.dispose();
  }

  void _emitTelemetry({
    required String validationType,
    required bool result,
    required List<String> errors,
    required String logMessage,
  }) {
    if (widget.onTelemetryLogged == null) return;
    final now = DateTime.now().toUtc();
    final telemetry = ModalValidationTelemetry(
      validationType: validationType,
      validationResult: result,
      completionStatus: result ? 'Pass' : 'Fail',
      errorMessages: errors,
      validationTimestamp: now,
      actionTimestamp: now,
      validationLog: logMessage,
      userSessionId: widget.userSessionId,
    );
    widget.onTelemetryLogged!(telemetry);
  }

  Future<void> _handleConfirm() async {
    if (widget.requirePokaYokeConfirmation && !_pokaYokeConfirmed) {
      HapticFeedback.heavyImpact();
      _emitTelemetry(
        validationType: 'PokaYokeVerification',
        result: false,
        errors: ['High-alert execution triggered without verification toggle.'],
        logMessage: 'Execution prevented by Poka-Yoke interlock.',
      );
      return;
    }

    setState(() => _isProcessing = true);
    final startTime = DateTime.now().toUtc();

    try {
      bool isValid = true;
      if (widget.onConfirmValidation != null) {
        isValid = await widget.onConfirmValidation!();
      }

      if (!mounted) return;

      if (isValid) {
        _emitTelemetry(
          validationType: 'ModalSubmission',
          result: true,
          errors: const [],
          logMessage: 'Action confirmed and validated successfully in ${DateTime.now().toUtc().difference(startTime).inMilliseconds}ms.',
        );
        HapticFeedback.lightImpact();
        Navigator.of(context).pop(true);
      } else {
        _emitTelemetry(
          validationType: 'ModalSubmission',
          result: false,
          errors: ['Custom validation rule rejected submission.'],
          logMessage: 'Submission validation failed.',
        );
        HapticFeedback.vibrate();
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (!mounted) return;
      _emitTelemetry(
        validationType: 'ModalSubmissionException',
        result: false,
        errors: [e.toString()],
        logMessage: 'Exception during modal confirmation execution: $e',
      );
      setState(() => _isProcessing = false);
    }
  }

  void _handleCancel() {
    _emitTelemetry(
      validationType: 'ModalDismissal',
      result: true,
      errors: const [],
      logMessage: 'User exited modal dialog via cancel trigger.',
    );
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Material 3 tonal container colors based on alert level
    final Color containerColor;
    final Color contentColor;
    final Color confirmBtnColor;
    final Color confirmBtnTextColor;

    switch (widget.alertLevel) {
      case ModalAlertLevel.critical:
        containerColor = colorScheme.errorContainer;
        contentColor = colorScheme.onErrorContainer;
        confirmBtnColor = colorScheme.error;
        confirmBtnTextColor = colorScheme.onError;
        break;
      case ModalAlertLevel.warning:
        containerColor = colorScheme.tertiaryContainer;
        contentColor = colorScheme.onTertiaryContainer;
        confirmBtnColor = colorScheme.tertiary;
        confirmBtnTextColor = colorScheme.onTertiary;
        break;
      case ModalAlertLevel.standard:
      default:
        containerColor = colorScheme.surface;
        contentColor = colorScheme.onSurface;
        confirmBtnColor = colorScheme.primary;
        confirmBtnTextColor = colorScheme.onPrimary;
        break;
    }

    final isFullScreen = widget.presentationMode == ModalPresentationMode.fullScreenSheet;
    final mediaQuery = MediaQuery.of(context);

    final modalBody = FocusScope(
      node: _focusScopeNode,
      child: Container(
        width: isFullScreen ? double.infinity : 480,
        padding: EdgeInsets.fromLTRB(
          24.0,
          24.0,
          24.0,
          isFullScreen ? mediaQuery.viewPadding.bottom + 24.0 : 24.0,
        ),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: isFullScreen
              ? const BorderRadius.vertical(top: Radius.circular(24.0))
              : BorderRadius.circular(28.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24.0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: isFullScreen ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isFullScreen)
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: contentColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            // Title header with WCAG focus announcement
            Semantics(
              header: true,
              focused: true,
              child: Text(
                widget.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: contentColor,
                ),
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: contentColor.withOpacity(0.8),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Content region
            Flexible(
              fit: isFullScreen ? FlexFit.tight : FlexFit.loose,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: widget.content,
              ),
            ),
            const SizedBox(height: 20),
            // Mistake-Proofing (Poka-Yoke) confirmation toggle
            if (widget.requirePokaYokeConfirmation) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _pokaYokeConfirmed
                        ? colorScheme.primary
                        : contentColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Switch.adaptive(
                      value: _pokaYokeConfirmed,
                      onChanged: _isProcessing
                          ? null
                          : (value) {
                              HapticFeedback.selectionClick();
                              setState(() => _pokaYokeConfirmed = value);
                            },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        label: widget.pokaYokePrompt ??
                            'Confirm to unlock final execution button',
                        child: Text(
                          widget.pokaYokePrompt ??
                              'I confirm and authorize this transaction.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: contentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Action trigger buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isProcessing ? null : _handleCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: contentColor.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(widget.cancelLabel),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  focusNode: _confirmButtonFocus,
                  onPressed:
                      (_isProcessing || (widget.requirePokaYokeConfirmation && !_pokaYokeConfirmed))
                          ? null
                          : _handleConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: confirmBtnColor,
                    foregroundColor: confirmBtnTextColor,
                    disabledBackgroundColor: confirmBtnColor.withOpacity(0.38),
                    disabledForegroundColor: confirmBtnTextColor.withOpacity(0.38),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(confirmBtnTextColor),
                          ),
                        )
                      : Text(widget.confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: isFullScreen
              ? Align(alignment: Alignment.bottomCenter, child: modalBody)
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: modalBody,
                ),
        ),
      ),
    );
  }
}
