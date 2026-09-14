// FIEVR-034-A07 — Molecular Form Layout Elements & Input Field Group.
// Standardized molecular form container enforcing Material 3 spacing increments,
// focus background shading transitions, child validation propagation, and accessibility semantics.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Model representing telemetry and audit data captured for form operations.
class FormStepAuditMetadata {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String? userId;

  const FormStepAuditMetadata({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    this.userId,
  });

  Map<String, dynamic> toMap() => {
        'stepExecutionId': stepExecutionId,
        'executionStatus': executionStatus,
        'executionTimestamp': executionTimestamp.toIso8601String(),
        'stepOutcome': stepOutcome,
        'userId': userId,
      };
}

/// Signature for child validation state listener.
typedef ValidationChangeCallback = void Function(bool isValid, String? errorText);

/// Standardized Material 3 spacing increments (8dp grid).
class FormGridSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double fieldMinHeight = 56.0;
}

/// Molecular form layout element wrapping child input atoms with unified
/// focus transitions, error indication, accessibility labeling, and validation propagation.
class InputFieldGroupFievr034A07 extends StatefulWidget {
  final String label;
  final String? helperText;
  final String? tooltip;
  final bool isRequired;
  final Widget Function(BuildContext context, FocusNode focusNode, FormFieldState<String> state) builder;
  final String? Function(String?)? validator;
  final String? initialValue;
  final ValidationChangeCallback? onValidationChanged;
  final ValueChanged<FormStepAuditMetadata>? onAuditLogged;
  final String? userId;
  final String stepExecutionId;
  final double verticalSpacing;

  const InputFieldGroupFievr034A07({
    super.key,
    required this.label,
    required this.builder,
    required this.stepExecutionId,
    this.helperText,
    this.tooltip,
    this.isRequired = false,
    this.validator,
    this.initialValue,
    this.onValidationChanged,
    this.onAuditLogged,
    this.userId,
    this.verticalSpacing = FormGridSpacing.md,
  });

  @override
  State<InputFieldGroupFievr034A07> createState() => _InputFieldGroupFievr034A07State();
}

class _InputFieldGroupFievr034A07State extends State<InputFieldGroupFievr034A07> {
  late final FocusNode _internalFocusNode;
  bool _hasFocus = false;
  String? _errorMessage;
  bool _isValid = true;

  @override
  void initState({
    super.initState();
    _internalFocusNode = FocusNode();
    _internalFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _hasFocus = _internalFocusNode.hasFocus;
      });

      if (_hasFocus) {
        // Smoothly adjust scroll offset for dynamic soft-keyboard presentation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _internalFocusNode.context != null) {
            Scrollable.ensureVisible(
              _internalFocusNode.context!,
              alignment: 0.35,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    }
  }

  void _emitAudit(String outcome, String status) {
    if (widget.onAuditLogged != null) {
      final audit = FormStepAuditMetadata(
        stepExecutionId: widget.stepExecutionId,
        executionStatus: status,
        executionTimestamp: DateTime.now().toUtc(),
        stepOutcome: outcome,
        userId: widget.userId,
      );
      widget.onAuditLogged!(audit);
    }
  }

  void _handleValidation(String? value) {
    final error = widget.validator != null ? widget.validator!(value) : null;
    final valid = error == null || error.isEmpty;

    if (_errorMessage != error || _isValid != valid) {
      setState(() {
        _errorMessage = error;
        _isValid = valid;
      });

      widget.onValidationChanged?.call(_isValid, _errorMessage);
      _emitAudit(
        valid ? 'ValidationSuccess' : 'ValidationError: $error',
        valid ? 'Complete' : 'Failed',
      );
    }
  }

  @override
  void dispose() {
    _internalFocusNode.removeListener(_handleFocusChange);
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Subtle container background shade transition on focus
    final Color containerColor = _hasFocus
        ? colorScheme.surfaceContainerHighest.withOpacity(0.65)
        : colorScheme.surfaceContainerLow.withOpacity(0.4);

    final Color borderColor = !_isValid
        ? colorScheme.error
        : _hasFocus
            ? colorScheme.primary
            : colorScheme.outlineVariant;

    final String semanticLabel = widget.isRequired
        ? '${widget.label}, required field'
        : widget.label;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.verticalSpacing / 2),
      child: Semantics(
        label: semanticLabel,
        hint: widget.helperText,
        error: _errorMessage,
        focused: _hasFocus,
        container: true,
        child: FormField<String>(
          initialValue: widget.initialValue,
          validator: (val) {
            final err = widget.validator?.call(val);
            _handleValidation(val);
            return err;
          },
          builder: (formFieldState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Accessibility-linked header label with required marker
                Row(
                  children: [
                    Text(
                      widget.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: !_isValid
                            ? colorScheme.error
                            : _hasFocus
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (widget.isRequired) ...[
                      const SizedBox(width: FormGridSpacing.xs),
                      Text(
                        '*',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (widget.tooltip != null) ...[
                      const SizedBox(width: FormGridSpacing.xs),
                      Tooltip(
                        message: widget.tooltip!,
                        child: Icon(
                          Icons.info_outline,
                          size: 16,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: FormGridSpacing.sm),
                // Animated molecular container with shade transition
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  constraints: const BoxConstraints(
                    minHeight: FormGridSpacing.fieldMinHeight,
                  ),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: borderColor,
                      width: _hasFocus || !_isValid ? 1.8 : 1.0,
                    ),
                    boxShadow: _hasFocus
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.08),
                              blurRadius: 8.0,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: FormGridSpacing.md,
                    vertical: FormGridSpacing.xs,
                  ),
                  child: widget.builder(context, _internalFocusNode, formFieldState),
                ),
                // Animated error / helper description row
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  crossFadeState: !_isValid && _errorMessage != null
                      ? CrossFadeState.showFirst
                      : (widget.helperText != null ? CrossFadeState.showSecond : CrossFadeState.showSecond),
                  firstChild: Padding(
                    padding: const EdgeInsets.only(
                      top: FormGridSpacing.xs,
                      left: FormGridSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 14, color: colorScheme.error),
                        const SizedBox(width: FormGridSpacing.xs),
                        Expanded(
                          child: Text(
                            _errorMessage ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondChild: widget.helperText != null
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: FormGridSpacing.xs,
                            left: FormGridSpacing.xs,
                          ),
                          child: Text(
                            widget.helperText!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
